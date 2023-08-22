# print_tree

`print_tree` is a command-line tool written in Python that prints a directory tree structure with options to avoid certain directories and filter files by their extensions.

## Installation

1. Clone the repository or download the files `print_tree.py` and `print_tree_config.json`.
2. Make the script executable by running `chmod +x print_tree.py`.

## Usage

### Basic Usage

```bash
python ./print_tree.py <directory>
```

### With Configuration File

You can provide a `print_tree_config.json` file to specify default directories to avoid and file extensions to omit.

Example configuration:

```json
{
	"avoid": ["node_modules", ".git"],
	"omit_extensions": ["tmp", "log", "svg"]
}
```

### Command-line Arguments

- `directory`: The root directory (required).
- `--only`: Only include files with specific extensions without leading dot. Example: `--only py txt`.
- `--avoid`: Additional directories to avoid. Example: `--avoid .git .vscode`.
- `--omit`: Additional file extensions to omit without leading dot. Example: `--omit log tmp`.
- `--output`: Output file path. Example: `--output output.txt`.

### Example

```bash
python ./print_tree.py /path/to/folder --only py txt --avoid .git .vscode --omit log tmp --output output.txt
```
