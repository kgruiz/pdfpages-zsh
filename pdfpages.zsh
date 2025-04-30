# PDF Page Counter – `pdfpages` command

# color codes (only define if not already set)
if [[ -z $ESC ]]; then readonly ESC="\033"; fi
if [[ -z $RESET ]]; then readonly RESET="${ESC}[0m"; fi
if [[ -z $BOLD_CYAN ]]; then readonly BOLD_CYAN="${ESC}[1;36m"; fi
if [[ -z $DIM_WHITE ]]; then readonly DIM_WHITE="${ESC}[2;37m"; fi
if [[ -z $DIM_BLUE ]]; then readonly DIM_BLUE="${ESC}[2;34m"; fi
if [[ -z $GREEN ]]; then readonly GREEN="${ESC}[0;32m"; fi
if [[ -z $BOLD_RED ]]; then readonly BOLD_RED="${ESC}[1;31m"; fi
if [[ -z $YELLOW ]]; then readonly YELLOW="${ESC}[0;33m"; fi
if [[ -z $MAGENTA ]]; then readonly MAGENTA="${ESC}[0;35m"; fi

# show usage/help
function PDFPages_ShowHelp {
    printf "${BOLD_CYAN}Usage:${RESET} pdfpages ${BOLD_YELLOW}<file|dir>${RESET} ${MAGENTA}[options]${RESET}\n\n"
    printf "${BOLD_CYAN}Options:${RESET}\n"
    printf "  ${BOLD_MAGENTA}-n, --no-recursive${RESET}   Do not recurse into subdirectories\n"
    printf "  ${BOLD_MAGENTA}-h, --help${RESET}           Show this help message and exit\n"
}

# verify pdfinfo is installed
function CheckDependencies {
    if ! command -v pdfinfo >/dev/null 2>&1; then
        printf "${BOLD_RED}Error:${RESET} pdfinfo not found. ${YELLOW}Install poppler-utils or add pdfinfo to PATH.${RESET}\n" >&2
        return 1
    fi
    return 0
}

# return page count for one PDF
function GetPageCount {
    local file="$1" output pages

    output=$(pdfinfo "$file" 2>&1) || {
        printf "${BOLD_RED}Error:${RESET} pdfinfo failed for ${BOLD_YELLOW}'%s'${RESET}.\n" "$file" >&2
        return 1
    }

    pages=$(echo "$output" | awk '/^Pages:/ {print $2}')
    if ! [[ $pages =~ ^[0-9]+$ ]]; then
        printf "${BOLD_RED}Error:${RESET} could not parse page count for ${BOLD_YELLOW}'%s'${RESET}.\n" "$file" >&2
        return 1
    fi

    echo "$pages"
    return 0
}

# main entrypoint
function pdfpages {
    emulate -L zsh
    setopt extendedglob null_glob

    local total=0 attempted=0 processed=0 pages

    if ! CheckDependencies; then
        return 1
    fi

    if [[ $# -eq 0 ]]; then
        printf "${BOLD_RED}Error:${RESET} missing required argument ${BOLD_YELLOW}'<input>'${RESET}\n"
        printf "${BOLD_CYAN}Usage:${RESET} pdfpages ${BOLD_YELLOW}<file|dir>${RESET} ${MAGENTA}[options]${RESET}\n"
        return 1
    fi

    if [[ $1 == "-h" || $1 == "--help" ]]; then
        PDFPages_ShowHelp
        return 0
    fi

    local recursive=1
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -n | --no-recursive)
            recursive=0
            shift
            ;;
        -h | --help)
            PDFPages_ShowHelp
            return 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            printf "${BOLD_RED}Error:${RESET} unknown option ${BOLD_YELLOW}'%s'${RESET}. ${YELLOW}Use 'pdfpages --help'.${RESET}\n" "$1" >&2
            return 1
            ;;
        *)
            break
            ;;
        esac
    done

    for arg in "$@"; do
        if [[ -d $arg ]]; then
            if ((recursive)); then
                while IFS= read -r -d '' file; do
                    ((attempted++))
                    pages=$(GetPageCount "$file") || continue
                    printf "${BOLD_CYAN}%s:${RESET} ${DIM_WHITE}%s pages${RESET}\n" "$file" "$pages"
                    ((total += pages, processed++))
                done < <(find "$arg" -type f -iname '*.pdf' -print0)
            else
                for file in "$arg"/*.pdf; do
                    [[ -f $file ]] || continue
                    ((attempted++))
                    pages=$(GetPageCount "$file") || continue
                    printf "${BOLD_CYAN}%s:${RESET} ${DIM_WHITE}%s pages${RESET}\n" "$file" "$pages"
                    ((total += pages, processed++))
                done
            fi

        elif [[ -f $arg && $arg == *.pdf ]]; then
            ((attempted++))
            pages=$(GetPageCount "$arg") || continue
            printf "${BOLD_CYAN}%s:${RESET} ${DIM_WHITE}%s pages${RESET}\n" "$arg" "$pages"
            ((total += pages, processed++))

        else
            printf "${YELLOW}Warning:${RESET} '${BOLD_YELLOW}%s${RESET}' not found or not a PDF, skipping\n" "$arg" >&2
        fi
    done

    if ((processed > 1)); then
        printf -- "--------------------\n"
        local note=""
        ((attempted != processed)) && note=" (out of $attempted attempted)"
        printf "${MAGENTA}Total:${RESET} ${DIM_WHITE}%s pages${RESET}%s\n" "$total" "$note"
    fi

    if ((processed > 0)); then
        return 0
    fi

    printf "${BOLD_RED}Error:${RESET} no PDFs processed successfully\n" >&2
    return 1
}

# zsh completion for `pdfpages`
if [[ -n $ZSH_VERSION ]]; then
    _pdfpages() {
        _alternative \
            'files:pdf:_files -g "*.(#i)pdf"' \
            'dirs:directory:_files -/'
    }
    compdef _pdfpages pdfpages
fi
