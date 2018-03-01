## lic

An over-engineered way to add a license to your project.

## Usage

```
Usage: lic [-y <year>] [-a <author>] [-l <file>] [-g] [-h] <license>

Options:
  -a <author>  specify author for copyright [defaults to `git config user.name`]
  -g           commit license to git repository
  -h           show this message
  -l <file>    specify output filename [defaults to LICENSE]
  -y <year>    specify year for copyright [defaults to `date +"%Y"`]

Available licenses: AGPL3, Apache, BSD2, BSD3, GPL2, GPL3, LGPL3, MIT, Mozilla, Unlicense
```

Common operations:

* `lic MIT` - add MIT license
* `lic -a "John Doe" -y 2000 MIT` - add MIT license, copyright 2000 John Doe
* `lic -l license.txt MIT` - add MIT license using license.txt as the filename
* `lic -g MIT` - add MIT license, and then immediately commit it to the current
  git repository

## Tab Completion

If you use zsh, add the directory containing `lic` to `$path`, and add the
directory containing `_lic` to `$fpath`, you can get tab completion. The
completion will work for all of the available licenses, as well as the options
if you enter the `-`.

## Templates

Lic comes with templates for many popular licenses, but you can add others. Just
drop them in the `templates/` directory, and (optionally) add placeholders for
year (`{{year}}`) and author (`{{author}}`).

## Testing

The included `test.sh` contains a test suite that can be run using
[shunit2](https://github.com/kward/shunit2).

## License

BSD 2-clause
