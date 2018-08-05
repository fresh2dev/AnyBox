
# [Introducing the AnyBox](https://www.donaldmellenbruch.com/post/introducing-the-anybox/)

# [New in v0.3.0](https://www.donaldmellenbruch.com/post/anybox-v0.3/)

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [v0.3.1] - 2018-08-05

### Changed

- Minor bugfixes (see [issue 2](https://github.com/dm3ll3n/AnyBox/issues/2))
- Corrections to examples.

## [v0.3.0](https://www.donaldmellenbruch.com/post/anybox-v0.3/) - 2018-03-04

### Added

Added `New-Prompt` as an alias for `New-AnyBoxPrompt`. New parameters include:
  - `-Tab`: show prompts in a tab control view.
  - `-Group`: group prompts in a group box.
  - `-FontSize`, `-FontFamily`, `-FontColor`, `-Alignment`: allows the ability to have prompts of different sizes, colors, etc.
  - `-ShowSetAs`: controls how a set (specified by `-ValidateSet` is displayed). The default is a dropdown (combo) box, but users can specify 'Radio' or 'Radio_Wide'.
  - `-RadioGroup`: When `-ShowSetAs` is one of 'Radio' or 'Radio_Wide', each set of options in `-ValidateSet` is in one group. Use `-RadioGroup` to designate the group to which a set of radio buttons belongs.
  - `-ShowSeparator`: When specified, a horizontal line is shown beneath the prompt.
  - `-Collapsible`: When specified, the prompt is shown within a collapsible expander control.

New parameters for `Show-AnyBox` include:
  - `-MaxHeight`, `-MaxWidth`: used to control the maximum size of the window.
  - `-CollapsibleGroups`: if specified and prompt group(s) are specified, the groups are placed in a collapsible expander control, rather than a group box.
  - `-AccentColor`: controls the color of lines in group boxes, expander boxes, and separator lines.
  - `-PrepScript`: accepts a script block to run before the window is shown.

New function `New-AnyBoxButton` (alias `New-Button`) to wrap around the new object type `AnyBox.Button`. Parameters for this function include:
  - `-Name`: the unique key name for the button.
  - `-Text`: the text to display on the button. If `-Name` is not specified, the value for `-Text` serves as the key.
  - `-IsCancel`: designates the button to serve as the *cancel* button.
  - `-IsDefault`: designates the button to serve as the *default* button.
  - `-OnClick`: accepts a script block to run when the button is clicked.

### Changed

  - `-ContentAlignment` now defaults to 'Left'.
  - `-FontSize` now defaults to '12'.

## v0.2.1 - 2018-03-12

### Added

- Extended `AnyBox.Prompt` class to include `Name` property to use as an identifier in the output (defaults to "Input_#").
- Added `-Name` parameter to the `AnyBox.Prompt` wrapper function `New-AnyBoxPrompt`.

## v0.2 - 2018-03-11

### Added

- `New-AnyBoxPrompt` function wrapper around the `AnyBox.Prompt` class. It includes a new parameter, `-MessagePosition`, which specifies whether to print the prompt message above or beside the input control (default='Top').
- When `-GridData` is provided, DataGrid now fills all available space when window is resized.
- `-GridAsList` parameter as a shortcut for `ConvertTo-Long`.

## v0.1 - 2018-03-06

- Initial release
