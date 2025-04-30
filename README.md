# pdfpages-zsh

`pdfpages-zsh` provides an efficient, user-friendly command-line tool for counting the number of pages in PDF files, either individually or recursively in directories. It allows you to quickly calculate page counts for PDF files located in a single directory or spread across multiple directories, streamlining the process with color-coded output and clear error handling.

## Key Features

- **PDF Page Counting**: Quickly count pages in PDF files.
- **Recursive Mode**: Optionally process PDFs recursively within subdirectories.
- **Non-Recursive Mode**: Limit processing to the current directory.
- **Shell Autocomplete**: Tab-completion for files and directories.
- **Informative Output**: Clear, color-coded feedback for ease of use.
- **Customizable Options**: Easily enable or disable recursion with a simple flag (`-n` or `--no-recursive`).

## Installation

1. **Clone the Repository (or Download `pdfpages.zsh`)**
    Choose a location for the script (e.g., `~/.config/zsh/plugins/pdfpages-zsh`).

    ```bash
    # Option 1: Clone the repository
    git clone https://github.com/kgruiz/pdfpages-zsh.git ~/.config/zsh/plugins/pdfpages-zsh

    # Option 2: Create the directory and download the file
    mkdir -p ~/.config/zsh/plugins/pdfpages-zsh
    curl -o ~/.config/zsh/plugins/pdfpages-zsh/pdfpages.zsh https://raw.githubusercontent.com/kgruiz/pdfpages-zsh/main/pdfpages.zsh
    ```

2. **Source the Script in `.zshrc`**
    Add the following snippet to your `~/.zshrc` configuration file. Adjust `PDFPAGES_FUNC_PATH` to the actual location where you placed `pdfpages.zsh`.

    ```bash
    # init zsh completion
    autoload -Uz compinit
    compinit

    # load pdfpages-zsh
    PDFPAGES_FUNC_PATH="$HOME/.config/zsh/plugins/pdfpages-zsh/pdfpages.zsh"
    if [ -f "$PDFPAGES_FUNC_PATH" ]; then
        source "$PDFPAGES_FUNC_PATH" 2>/dev/null \
          || echo "Error: failed to source pdfpages.zsh" >&2
    else
        echo "Error: pdfpages.zsh not found at $PDFPAGES_FUNC_PATH" >&2
    fi
    ```

3. **Apply Changes**

    ```bash
    source ~/.zshrc
    ```

## Usage Guide

The `pdfpages` command allows you to count the pages in PDF files and directories, with flexible options for both recursive and non-recursive operations.

### 1. Counting Pages in PDFs

Run `pdfpages` with a file or directory path to count the pages in one or more PDFs. You can also process multiple files at once.

```bash
❯ pdfpages ~/Documents/*.pdf
example.pdf: 5 pages
another.pdf: 12 pages
```

### 2. Recursive Mode (Default)

By default, `pdfpages` will recurse into subdirectories to find and process PDFs. For example:

```bash
❯ pdfpages ~/Documents/Reports
example.pdf: 5 pages
another.pdf: 12 pages
subdir/example2.pdf: 7 pages
```

### 3. Non-Recursive Mode

Use the `-n` or `--no-recursive` flag to limit the processing to the specified directory, excluding any subdirectories.

```bash
❯ pdfpages -n ~/Documents/Reports
example.pdf: 5 pages
another.pdf: 12 pages
```

### 4. Handling Missing Arguments

If no input is provided or an argument is missing, the tool will provide a clear error message:

```bash
❯ pdfpages
Error: missing required argument '<input>'
Usage: pdfpages <file|dir> [options]
```

### 5. Unknown Option Handling

If an unknown option is provided, a professional error message is displayed:

```bash
❯ pdfpages -z
Error: unknown option '-z'. Use 'pdfpages --help'.
```

### 6. Displaying Help Information

View the command usage and options with `--help` or `-h`:

```bash
❯ pdfpages --help
pdfpages - Count the number of pages in PDF files

Usage:
  pdfpages <file|dir> [options]

Options:
  -n, --no-recursive   Do not recurse into subdirectories
  -h, --help           Show this help message and exit
```

## Configuration Details

- The `pdfpages` script is a self-contained Zsh function. No external dependencies are required, apart from `pdfinfo` from the `poppler-utils` package.
- By default, PDF files in directories are processed recursively unless the `-n` option is used.

## Contributing

Contributions, bug reports, and feature suggestions are welcome. Please refer to the repository's [issues tracker](https://github.com/kgruiz/pdfpages-zsh/issues) for ongoing development and discussion.

## License

Distributed under the **GNU GPL v3.0**. See [LICENSE](LICENSE) or <https://www.gnu.org/licenses/gpl-3.0.html> for details.
