# Updater tools
This directory has two main tools for helping maintain the dictionary database.

- `grabLatest.sh`: This downloads the latest version of the Wikipedia page
    <http://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings/For_machines>,
    extracts the revision ID, preprocesses the data lines, and saves
    them to a file named `wikipedia-REVISION.txt`.

  - Requires `wget`, GNU `sed`, and `grep`.

- `updateData.lua`: This script loads zero or more codespell dictionary
    database files, optionally performs additional operations on the
    combined database, then writes the data back out. The rest of this
    README primarily deals with this script.

  - Requires Lua 5.1.x, [lua-penlight][], and its optional dependency
      [LuaFileSystem][]. On Debian, try something like `sudo apt-get
      install lua5.1 lua-penlight lua-filesystem` on newer versions, or
      on older versions use LuaRocks in two steps: `sudo apt-get install
      lua5.1 luarocks` then `luarocks --local install penlight luafilesystem`

The other tools, `findReasons.sh` and `preprocessWikipediaContent.sh`,
(as well as the test script `CorrectionUtilsTest.lua`) have comments
that explain how and why you'd use them.

[lua-penlight]:https://github.com/stevedonovan/Penlight
[LuaFileSystem]:http://keplerproject.github.com/luafilesystem/manual.html

## *tl;dr:* Typical usage for dictionary update
To grab the latest Wikipedia and merge it in, these commands will
suffice. If you want to know what they mean/do, read the rest of this
doc.

Note that you should verify the diff before you commit it (ideally
testing it to identify any potential false-positives). `findReasons.sh`
in particular is useful in "proofreading" the database after
modification. In your commit message, be sure to mention the page
revision merged in. (This is in the filename that `grabLatest.sh`
creates.)

```sh
./grabLatest.sh
./updateData.lua -i ../data/dictionary.txt wikipedia-*.txt -e exclusionfile.txt
```

## Examples

Download the newest version of the wikipedia page:

```sh
./grabLatest.sh
```

For the rest of the examples, we'll be assuming we got revision
499817117 above.

Merge the original dictionary and Wikipedia into `outputdict.txt`, disabling "ok->OK" by default:

```sh
./updateData.lua ../data/dictionary.txt wikipedia-499817117.txt -r ok "lowercase variable names are nice"
```

Or, alternately, we can update in-place (using the first input file as
the output file):

```sh
./updateData.lua -i ../data/dictionary.txt wikipedia-499817117.txt -r ok "lowercase variable names are nice"
```

If we wanted to just completely remove "ok->OK" from the dictionary, we
could do this once:

```sh
./updateData.lua -i ../data/dictionary.txt -d ok
```

Or, since when merging with Wikipedia it will come back, but we don't
even really want to prompt about it, we can make a file
`exclusionfile.txt` with `ok` (and any other exclusions) on a line of
their own, and run:

```sh
./updateData.lua -i ../data/dictionary.txt -e exclusionfile.txt
```

## Usage text

```
Usage for ./updateData.lua

All additional arguments will be treated as input files.

Options:

  --add,-a  DATABASELINE
    Adds a quoted misspelling line to the database before writing.

  --inplace,-i
    Sets the output filename to be equal to the first input filename

  --reason,-r  MISSPELLING  REASON
    Disable automatic replacement of a misspelling by specifying both the misspelling and a quoted reason.

  --help,-h
    Shows this help screen

  --output,-o  OUTFILE
    Sets the output filename (defaults to outputdict.txt)

  --exclusions,-e  EXCLUSIONFILE
    Specifies a file where each line is a misspelling to delete.

  --delete,-d  MISSPELLING
    Deletes a misspelling from the database before writing.

  --quiet,-q
    Silences status output.

```
