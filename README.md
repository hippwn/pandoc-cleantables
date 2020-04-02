# pandoc-cleantables

This filter overrides the way Pandoc writes LaTeX tables, especially their
alignment string which contains @-expressions to reduce the table's width. It
has been written in Lua to take advantage of its deep integration Pandoc.

One particular advantage is the ability to colorize your table withour having
the rows spreading out.

## Usage

Once you've [installed](#Installation) the filter in your environment, just run
your conversion like you would have with the `--lua-filter` option:

```bash
$ pandoc -s example.md -o example.pdf --lua-filter cleantables.lua
```

## Installation

Just download the Lua script and place it anywhere Pandoc can see it: either in
the current directory or your *data* folder.

```bash
$ pandoc --version | grep "directory:"
Default user data directory: .local/share/pandoc or .pandoc

$ mkdir -p .local/share/pandoc/filters

$ curl https://raw.githubusercontent.com/hippwn/pandoc-cleantables/master/cleantables.lua -o .local/share/pandoc/filters/cleantables.lua
```
