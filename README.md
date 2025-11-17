# Directory Bookmark Script

A lightweight helper to create and use directory “bookmarks” via `bookmark` and its alias `bm`.

## Installation

### Linux (Bash)

1. Copy the Bash `bookmark` function and `alias bm=bookmark` into `~/.bashrc`.
2. Reload your shell:

```bash
source ~/.bashrc
```

### macOS (zsh)

1. Copy the zsh `bookmark` function and `alias bm='bookmark'` into `~/.zshrc`.
2. Reload your shell:

```zsh
source ~/.zshrc
```

> If you use Bash on macOS, follow the Linux (Bash) instructions instead.

### Windows (PowerShell)

1. Open your PowerShell profile:

```powershell
notepad $PROFILE
```

2. Paste the PowerShell `bookmark` function and `Set-Alias bm bookmark` into that file, then save.
3. Reload the profile:

```powershell
. $PROFILE
```

## Features

* Save any directory as a bookmark.
* Jump to a directory using its bookmark name.
* List all bookmark names.
* Remove bookmarks.
* Rejects duplicate names and names containing spaces.

## Usage

### Create a bookmark

```bash
bookmark ./               # current directory
bookmark ./path/to/dir/   # specific directory
bookmark ../              # parent directory
```

You will be prompted:

```text
[Bookmark Title]: sample_title
[SUCCESS] - bookmark sample_title has been created
```

Errors:

* Existing title:

  ```text
  [ERROR] - bookmark sample_title already exists
  ```

* Title with spaces:

  ```text
  [ERROR] - bookmark sample title has spaces
  ```

### Jump to a bookmark

```bash
bookmark sample_title
bm sample_title
```

### List all bookmarks

```bash
bookmark ls
bm ls
```

(Printed horizontally, e.g. `proj docs src`)

### Remove a bookmark

```bash
bookmark rm sample_title
bm rm sample_title
```

Output:

```text
[SUCCESS] - sample_title removed
# or
[ERROR] - sample_title doesn't exist
```

## Notes

* Bookmark titles must not contain spaces.
* Bookmarks are stored in `~/.dir_bookmarks`.
* `bm` is a shorthand alias for `bookmark`.
