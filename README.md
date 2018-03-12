
# [Introducing the AnyBox](https://www.donaldmellenbruch.com/post/introducing-the-anybox/)

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 0.2 - 2018-03-12

### Added

- `New-AnyBoxPrompt` function wrapper around the `AnyBox.Prompt` class. It includes a new parameter, `-MessagePosition`, which specifies whether to print the prompt message above or beside the input control (default='Top').
- When `-GridData` is provided, DataGrid now fills all available space when window is resized.
- `-GridAsList` parameter as a shortcut for `ConvertTo-Long`.

## 0.1 - 2018-03-06

- Initial release
