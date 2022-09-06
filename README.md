# AnyBox
> The easiest way to develop apps for Windows.

AnyBox provides a declarative interface for creating graphical user interfaces. That means you don't roll up your sleeves and build a form, you just tell AnyBox what you want. AnyBox abstracts away the complexities of WPF and .NET and make it sooo easy to develop simple applications for Windows using Powershell.

## Quick Start
Open a Powershell terminal. Any version from v3+, including Powershell Core (Windows only).

Install AnyBox from the [Powershell Gallery](https://www.powershellgallery.com/packages/AnyBox):
```PowerShell
# install
Install-Module -Name AnyBox -Scope CurrentUser -Force

# import
Import-Module AnyBox
```

Or, clone from GitHub:
```PowerShell
git clone https://github.com/fresh2dev/AnyBox.git

cd AnyBox

Import-Module .\AnyBox.psd1
```

Now, create something:
```PowerShell
Show-AnyBox -Message 'Hello World' -Buttons 'No', 'Yes'
```

Or, even more succinctly using aliases:
```PowerShell
anybox -m 'Wicked cool?' -b 'No', 'Yes'
```

AnyBox will build and display this form:
![quick-start-01.png](/img/quick-start-01.png)

The window exits when a button is clicked, returning a hashtable that contains user input. Each button is a key in the table. A value of `True` indicates the button was clicked, else `False`.

```PowerShell
> $response = Show-AnyBox -Message 'Wicked cool?' -Buttons 'No', 'Yes'
> $response

Name   Value
----   -----
No     False
Yes    True
```

Take action based on inputs:
```PowerShell
# prompt for input
$response = anybox -m 'Wicked cool?' -b 'No', 'Yes'

# set message accordingly
if ($response.Yes)
{
    $msg = 'Right on'
}
else
{
    $msg = 'Tough crowd'
}

# display message
anybox -m $msg -b 'OK'
```

If you made the correct choice, AnyBox will present:
![quick-start-02.png](/img/quick-start-02.png)

This example demonstrates the pattern that AnyBox was built for:
```
       (AnyBox)        (Code)       (AnyBox)
          │               │             │
          ▼               ▼             ▼
  ┌──► Inputs  ────►  Actions ────►  Outputs ────►
  │                                              │
  └──────────────────────────────────────────────┘
```
1.  Obtain **inputs** with AnyBox
2.  Perform **actions** with your code
3.  Display **outputs** with AnyBox

With a variety of input types and customization options, AnyBox empowers the developer to go beyond basic dialog boxes, and well into desktop app development for Windows.


## Messages
Let's start with the simplest example; the standard message box:
```PowerShell
Show-AnyBox -Title 'AnyBox Demo' -Message 'Hello world' -Buttons 'Hi' -MinWidth 300
```

![messages-standard.png](/img/messages-standard.png)

The `-Message` parameter accepts an array of strings to print, each separated by a new line.

```PowerShell
Show-AnyBox -Icon 'Question' -Title 'AnyBox Demo' -Message 'Hello world', 'Are you ready?' -Buttons 'No', 'Yes' -MinWidth 300
```

![messages-array-input.png](/img/messages-array-input.png)

Similar to `-Message` is `-Comment`, which will include a text block in italics near the bottom of the AnyBox.

```powershell
Show-AnyBox -Message 'Provide your name:' -Prompt '' -Comment 'First name only' -Buttons 'OK'
```

![messages-comment.png](/img/messages-comment.png)


## Prompts
This is where things get interesting, but a bit more tricky; I hope some examples will simplify things.

As seen in the definition, the following types of `AnyBox.InputType`s are allowed:
-   Text  _(default)_
-   FileOpen
-   FileSave
-   FolderOpen
-   Checkbox
-   Password
-   Date
-   Link

The options provided to each prompt type include:
-   Name
-   InputType
-   Message
-   MessagePosition
-   DefaultValue
-   LineHeight
-   ReadOnly
-   ValidateNotEmpty
-   ValidateSet
-   ValidateScript

Similar to buttons, the hashtable returned by the AnyBox will contain key-value pairs for each prompt and the user input. If no  `Name`  is provided for the prompt, it will be auto-assigned with  `Input_#`, where  `#`  is the index of the prompt,  _starting from zero_.

Since v0.3.0, prompts are now even easier to create. Instead of using  `New-AnyBoxPrompt`, you can just pass a string containing the prompt message, similar to how buttons are specified. Of course,  `New-AnyBoxPrompt`  opens you up to more options.

### InputType.Text

`Text`  is the default input type, so the simplest example is:

```PowerShell
Show-AnyBox -Prompt '' -Buttons 'Submit'
```

![prompt-text-simplest.png](/img/prompt-text-simplest.png)

```
Name		Value
----		-----
Input_0		Hello world
Submit		True
```

Here is an example use a  `DefaultValue`  and the  `LineHeight`  property set to 5

```PowerShell
[string]$default_qry = @"
SELECT
  Name, COUNT(*) [Total]
FROM Table
WHERE Value < 10
GROUP BY Name
ORDER BY Timestamp
"@

[AnyBox.Prompt]$prompt = @{
  Message = 'Enter your query:'
  DefaultValue = $default_qry
  LineHeight = 5
  ValidateNotEmpty = $true
}

Show-AnyBox -Prompt $prompt -Buttons 'Cancel', 'Execute' -CancelButton 'Cancel' `
  -ContentAlignment 'Left' -MinWidth 300
```

![prompt-text-multiline.png](/img/prompt-text-multiline.png)

#### Validate
Getting user input is not the only struggle. Often, a bigger struggle is validating the user input we get. AnyBox aims to make that simpler by use of any of three prompt options:
- ValidateNotEmpty
- ValidateSet
- ValidateScript

`-ValidateNotEmpty`  is the simplest; the AnyBox will not proceed until  _some_  input is entered (or the specified  _cancel_  button is selected).

`-ValidateSet`  has some interesting behavior; it will replace the text box with a combo box to ensure whatever the user selects is in the given set.

```PowerShell
$prompt = New-AnyBoxPrompt -Name 'fav_sport' `
  -Message 'What is your favorite sport?' `
  -ValidateSet @('Basketball', 'Football', 'Baseball', 'Soccer', 'Hockey', 'Other') `
  -DefaultValue 'Baseball'

Show-AnyBox -Icon 'Question' -Prompt $prompt -Buttons 'OK'
```

![prompt-validate-dropdown.png](/img/prompt-validate-dropdown.png)

```
Name                           Value
----                           -----
OK                             True
fav_sport                      Baseball
```

By default, when options are provided to  `-ValidateSet`, the options are presented as a dropdown box. Sets can now be presented as radio buttons using the  `-ShowSetAs`  parameter and specifying one of "Radio" or "Radio_Wide".

```PowerShell
$prompts = @(New-Prompt -Message 'Default Combo' -ValidateSet 'one', 'two', 'three' -ShowSeparator)
$prompts += @(New-Prompt -Message 'Radio' -ValidateSet 'one', 'two', 'three' -ShowSetAs 'Radio' -ShowSeparator)
$prompts += @(New-Prompt -Message 'Radio Wide' -ValidateSet 'one', 'two', 'three' -ShowSetAs 'Radio_Wide' -ShowSeparator)

Show-AnyBox -Prompts $prompts -Buttons 'one', 'two', 'three'
```

![prompt-validate-radio-buttons.png](/img/prompt-validate-radio-buttons.png)

With  `-ValidateScript`, the options are endless. If the script block you provide returns  `$true`, the user input is considered valid.

```PowerShell
$prompt = New-AnyBoxPrompt -Message 'Enter any number between 0 and 100:' `
  -ValidateScript { [int]$_ -ge 0 -and [int]$_ -le 100 }

Show-AnyBox -Prompt $prompt -Buttons 'Submit'
```

![prompt-validate-script.png](/img/prompt-validate-script.png)

### InputType.File\[Open|Save\]
The input types  `FileOpen`  and  `FileSave`  are similar to  `Text`, with the addition of a button to the left of the textbox that opens either a  [OpenFileDialog](https://i-msdn.sec.s-msft.com/dynimg/IC394014.jpeg)  or  [SaveFileDialog](https://i-msdn.sec.s-msft.com/dynimg/IC394015.jpeg)  window, respectively.

```PowerShell
Show-AnyBox -MinWidth 350 -Buttons 'Cancel', 'Submit' -Prompt @(
  (New-AnyBoxPrompt -InputType 'FileOpen' -Message 'Open File:' -ReadOnly),
  (New-AnyBoxPrompt -InputType 'FileSave' -Message 'Save File:' -ReadOnly),
  (New-AnyBoxPrompt -InputType 'FolderOpen' -Message 'Open Folder:' -ReadOnly)
)
```

![prompt-file-input.png](/img/prompt-file-input.png)

### InputType.Password
When the  `Password`  input type is specified, the user is presented a  [PasswordBox](https://msdn.microsoft.com/en-us/library/system.windows.controls.passwordbox%28v=vs.110%29.aspx)  instead of a  [TextBox](https://msdn.microsoft.com/en-us/library/system.windows.controls.textbox%28v=vs.110%29.aspx), so the password is masked and returned as a security string.

```PowerShell
Show-AnyBox -Buttons 'Cancel', 'Login' -Prompt @(
  (New-AnyBoxPrompt -InputType 'Text' -Message 'User Name:' -ValidateNotEmpty),
  (New-AnyBoxPrompt -InputType 'Password' -Message 'Password:' -ValidateNotEmpty)
)
```

![prompt-password-field.png](/img/prompt-password-field.png)

```
Name	Value
----	-----
Cancel	False
Input_0	donald
Input_1	System.Security.SecureString
Login	True
```

### InputType.CheckBox
The  `Checkbox`  input is straightforward:

```PowerShell
Show-AnyBox -Icon 'Question' -Buttons 'Cancel', 'Ignore' `
	-Message 'An error occurred. (Code=123)' `
	-Prompts (New-AnyBoxPrompt -InputType 'Checkbox' -Message "Don't ask again." -DefaultValue $true)
```

![prompt-checkbox.png](/img/prompt-checkbox.png)

### InputType.Date
The  `Date`  input is also fairly straightforward:

```PowerShell
$p = New-AnyBoxPrompt -InputType 'Date' -Message 'Show all events after:' `
  -DefaultValue ((Get-Date).AddDays(-7)) -ValidateNotEmpty

Show-AnyBox -Buttons 'OK' -Prompt $p
```

![prompt-date-input.png](/img/prompt-date-input.png)

![prompt-date-input-calendar.png](/img/prompt-date-input-calendar.png)

### InputType.Link
The last of the available input types is  `Link`. This type has some unique, useful behavior that is unlike the others. When specified, the user is presented with a link that, when clicked, can open a web url, a directory, or launch a program.

The provided  `Message`  is the link text. The provided  `DefaultValue`  is the link destination. The result of the AnyBox will show whether or not the link was clicked.

```PowerShell
Show-AnyBox -Buttons 'OK' -MinWidth 200 -Prompt @(
    (New-AnyBoxPrompt -InputType 'Link' -Message 'My Files' -DefaultValue $env:USERPROFILE),
    (New-AnyBoxPrompt -InputType 'Link' -Message 'Reddit' -DefaultValue 'www.reddit.com' -ValidateNotEmpty),
    (New-AnyBoxPrompt -InputType 'Link' -Message 'Notepad' -DefaultValue 'notepad.exe')
)
```

```
Name      Value
----      -----
Input_2   False
OK        True
Input_0   False
Input_1   True
```

![prompt-link-input.png](/img/prompt-link-input.png)

If  `-ValidateNotEmpty`  is specified, the user will be forced to click the link before proceeding.

![prompt-link-input-validate.png](/img/prompt-link-input-validate.png)

### Prompt Example
Prompts can be built dynamically. Here is a quick example:

```PowerShell
$prompts = 1..7 | foreach {
  $type = [AnyBox.InputType]$_
  New-AnyBoxPrompt -InputType $type -Name "$type`_input" -Message "$type Input:"
}

$buttons = 1..6 | foreach {
  "Button $_"
}

$answer = Show-AnyBox -Prompt $prompts -Buttons $buttons -ButtonRows 2 -MinWidth 400
```

![prompt-example.png](/img/prompt-example.png)

```PowerShell
PS C:\> $answer

Name                           Value
----                           -----
Button 6                       False
Button 4                       True
FileOpen_input                 C:\Temp\Logs\old.log
Password_input                 System.Security.SecureString
Button 5                       False
Text_input                     hello world
Checkbox_input                 True
Date_input                     3/12/2018
Button 2                       False
Link_input                     False
Button 3                       False
Button 1                       False
FileSave_input                 C:\Temp\Logs\new.log
```

```powershell
PS C:\> $prompts | select Name, Message, @{Name='UserInput';Expression={ $answer[$_.Name] }}

Name           Message         UserInput
----           -------         ---------
Text_input     Text Input:     hello world
FileOpen_input FileOpen Input: C:\Temp\Logs\old.log
FileSave_input FileSave Input: C:\Temp\Logs\new.log
Checkbox_input Checkbox Input: True
Password_input Password Input: System.Security.SecureString
Date_input     Date Input:     3/12/2018
Link_input     Link Input:     False
```

### Prompt Grouping/Collapsing
Prompts are collapsible since v0.3.0.

```PowerShell
$prompts = @(New-Prompt -Message 'This')
$prompts += @(New-Prompt -Message 'That' -Collapsible)
$prompts += @(New-Prompt -Message 'The other' -Collapsible)

Show-AnyBox -Prompts $prompts -Buttons 'OK'
```

![prompt-collapsable.png](/img/prompt-collapsable.png)

AnyBox v0.3.0 introduces several ways to separate and/or group prompts. The most basic way is to specify the  `-ShowSeparator`  switch which, when specified, prints a horizontal line below the prompt. The  `-Group`  switch accepts a string and groups prompts that have the same group name. If the provided group name contains no word characters (e.g., only digits), the group name is not printed; otherwise, it will be printed. Similarly,  `-Tab`  accepts a string and shows prompts with the same tab name in the specified tab. Here’s an example showcasing each of these new options.

```PowerShell
$prompts = @(New-Prompt -Message 'Prompt 1:' -ShowSeparator)
$prompts += @(New-Prompt -Group 1 -Message 'Prompt 2:' -ShowSeparator)
$prompts += @(New-Prompt -Group 1 -Message 'Prompt 3' -InputType 'Checkbox' -Alignment 'Center')
$prompts += @(New-Prompt -Group 'MyGroup' -Message 'Prompt 4:' -InputType 'Date' -ShowSeparator)
$prompts += @(New-Prompt -Group 'MyGroup' -Message 'Prompt 5:' -InputType 'FileOpen' -ReadOnly -ShowSeparator)
$prompts += @(New-Prompt -Group 'MyGroup' -Message 'Prompt 6:' -InputType 'FileSave' -ReadOnly -Collapsible)
$prompts += @(New-Prompt -Tab 'ThisTab' -Message 'Prompt 7:' -ShowSeparator)
$prompts += @(New-Prompt -Tab 'ThisTab' -Message 'Prompt 8:')
$prompts += @(New-Prompt -Tab 'ThatTab' -Message 'Prompt 9:' -ShowSeparator)
$prompts += @(New-Prompt -Tab 'ThatTab' -Message 'Prompt 10:')

Show-AnyBox -Prompts $prompts -Buttons 'Cancel', 'Continue' -AccentColor 'Gray'
```

![prompt-show-separator.png](/img/prompt-show-separator.png)

Notice the use of  `-AccentColor`  in the call to  `Show-AnyBox`. This parameter can be used to specify the color of the lines for the separator lines, group box lines, etc.

Similar to the  `-Collapsible`  switch for a prompt, an entire prompt group can be made collapsible by specifying  `-CollapsibleGroups`  to  `Show-AnyBox`.

```PowerShell
Show-AnyBox -Prompts $prompts -Buttons 'Cancel', 'Continue' -AccentColor 'CornflowerBlue' -CollapsibleGroups
```

![prompt-accent-color.png](/img/prompt-accent-color.png)


## Buttons
Any number of buttons can be added using the `-Buttons` parameter like so:

```powershell
Show-AnyBox -Message 'Select one:' -Buttons 'This', 'That', 'Other'
```

![simple-btns.png](/img/simple-btns.png)

The result returned from an AnyBox is a hashtable that contains what input was received. For buttons, the name of the key in the hashtable is the name of the button; the value indicates whether or not that button was selected.

```text
Name	Value
----	-----
That	True
This	False
Other	False
```

The button layout can also be altered using the `-ButtonRows` parameter.

```powershell
Show-AnyBox -Title 'AnyBox Demo' -Message 'Select a number:' -Buttons @(1..9) -ButtonRows 3
```

![num-btn-rows.png](/img/num-btn-rows.png)

As you will soon see, user input can be validated within the AnyBox, and the user will be unable to proceed until valid input is entered. The `-CancelButton` parameter accepts a single button name to designate as the _cancel_ button. The cancel button closes the window without validating input. It is also selected if the user presses the 'ESC' key on the keyboard.

Similarly, the single button name provided to `-DefaultButton` indicates the button that will serve as the _default_ button. The default button is selected if the user presses the 'Enter' key on the keyboard.

```powershell
Show-AnyBox -Message 'Enter anything:' -Prompt (New-AnyBoxPrompt -ValidateNotEmpty) `
  -Buttons 'Cancel', 'Submit' -CancelButton 'Cancel' -DefaultButton 'Submit'
```

![cancel-default-btn.png](/img/cancel-default-btn.png)

New to v0.3.0, using `New-AnyBoxButton` (a.k.a. `New-Button`) to create the button, you can specify `-Name` which allows you to create a unique identifier for the button, instead of relying only on the button's content for this. Button content is specified with `-Text`, and a button can be designated as the cancel/default button using `-IsCancel` or `-IsDefault`, respectively. Simple enough. However, a very powerful option is the new `-OnClick` parameter, which accepts and runs a provided script block when the button is clicked. This way, you don't have to wait for the window to close before receiving and acting on user input. User input is accessible in the `-OnClick` script via the variable `$_`.

~~Lastly, `-ShowCopyButton` will include a special button that will copy the provided message to the clipboard.~~

All default buttons have been removed, but they can be easily replicated with the new `-Template` option of `New-AnyBoxButton`. The code below replicates the functionality of the obsolete `-ShowCopyButton` parameter and gives a good example of the new ability:

```powershell
$copy_btn = New-AnyBoxButton -Template CopyMessage

Show-AnyBox -Message 'Error code: 987654321' -Buttons @('Cancel', $copy_btn, 'Continue')
```

Another example of `-OnClick`:

```powershell
$p = New-Prompt -Name 'UserName' -Message 'What is your name?' -ValidateNotEmpty

$b = @(New-Button -Text 'Exit' -IsCancel)

$b += @(New-Button -Name 'Greeting' -Text 'Get Greeting' -OnClick {
  $input_test = Test-ValidInput -Prompts $Prompts -Inputs $_
  if (-not $input_test.Is_Valid) {
    $null = Show-AnyBox @childWinParams -Message $input_test.Message -Buttons 'OK'
  }
  else {
    $null = Show-AnyBox @childWinParams -Message $('Hello {0}.' -f $_.UserName) -Buttons 'Hi'
  }
})

$null = Show-AnyBox -Prompts $p -Buttons $b
```

![onclick-btn.png](/img/onclick-btn.png)

Two noteworthy mentions, shown in the code above, are:

-   `Test-ValidInput`: this enforces validation specified on the prompts, such as `-ValidateNotEmpty` and `-ValidateScript`. The return value is an object with two properties: `Is_Valid` and `Message`. `Is_Valid` will be a boolean value reflecting whether the input conforms to the given constraints. `Message` is a string that can be presented to the user when `Is_Valid` is `$false`.
-   `@childWinParams`: provided for convenience, contains passes parameters that are common of a child window. It is defined as:

```powershell
[hashtable]$childWinParams = @{
  FontFamily = $FontFamily
  FontSize = $FontSize
  FontColor = $FontColor
  BackgroundColor = $BackgroundColor
  NoGridSearch = $true
  WindowStyle = 'None'
  ResizeMode = 'NoResize'
  MinHeight = 25
  MinWidth = 25
  HideTaskbarIcon = $true
  Topmost = $true
  ParentWindow = $form.Window
}
```


## Grid
The AnyBox also has the ability to display data to a user in a DataGrid. All you need to do is pass an array to the `-GridData` parameter.

```powershell
Show-AnyBox -Title 'Powershell Processes' -Buttons 'OK' -GridData @(
  Get-Process -Name 'powershell' |
  select Id, Name, TotalProcessorTime, Path
)
```

![grid-data.png](/img/grid-data.png)

You may notice a few useful additions that are included automatically. Above the data grid is a message indicating how many items are in the grid, and a text box that allows users to filter the grid items. This can be disabled using the `-NoGridSearch` parameter.

~~Beneath the grid are two unique buttons, 'Explore' and 'Save'. The 'Explore' button will open the data grid items in the default Powershell grid view using `Out-GridView` where more sophisticated filtering can be done. The 'Save' button will prompt the user for a path to save the grid items to a CSV file.~~

All default grid-related buttons, including 'Save' and 'Explore', have been removed, but they can be easily replicated with the new `-Template` option of `New-AnyBoxButton`:

```powershell
$sav_btn = New-AnyBoxButton -Template SaveGrid
$exp_btn = New-AnyBoxButton -Template ExploreGrid

Show-AnyBox -Title 'Powershell Processes' -Buttons @($exp_btn, $sav_btn) -GridData @(
  Get-Process -Name 'powershell' | select Id, Name, TotalProcessorTime, Path
)
```

![grid-data-btns.png](/img/grid-data-btns.png)

The parameter `-SelectionMode` is available for the data grid and controls how grid cells are selected. Selected grid items are made available in the AnyBox output via the 'grid_select' key.

```powershell
Show-AnyBox -Title 'Select processes to kill' `
-NoGridSearch -SelectionMode 'MultiRow' -Buttons 'Cancel', 'Kill' `
-GridData @(Get-Process -Name '*note*' | select Id, Name, TotalProcessorTime, Path)
```

![grid-select.png](/img/grid-select.png)

```
Name             Value
----            -----
Cancel          False
grid_select     {@{Id=2680; Name=powershell;...
Kill            True
```

Sometimes, you may find that you only have one object with many properties to display. By default, the AnyBox will display this object with one row and many columns. It may be more appropriate to _melt_ the object to a long format. The AnyBox function includes a parameter, `-GridAsList`, that makes this simple.

```powershell
Show-AnyBox -Title 'Wide (as-is)' -Buttons 'OK' -NoGridSearch -GridData $car
```

![grid-wide.png](/img/grid-wide.png)

```powershell
Show-AnyBox -Buttons 'OK' -NoGridSearch -GridData $car -GridAsList
```

![grid-long.png](/img/grid-long.png)


## Personalization
### Image & Colors
Brand your AnyBox with an image. The `-Image` parameter accepts either:

1.  The path to an accessible image file (.png, .jpg, etc.)
2.  The base64 encoded string representing an image.

Additionally, `-FontFamily`, `-FontColor`, and `-BackgroundColor` allow you to

```powershell
[hashtable]$font = @{ FontFamily = 'Courier New'; FontColor = 'CornflowerBlue'; FontSize=20 }

Show-AnyBox @font -WindowStyle 'None' -Message 'Hello World', 'Are you ready?' -Buttons 'Yes' `
  -BackgroundColor 'Black' -Image '.\banner.png'
```

![personal-box.png](/img/personal-box.png)

By using a base64 string representing the image, you can save and reuse the string without worrying about whether or not the image file is accessible. For convenience, the AnyBox module includes a function `ConvertTo-Base64` which accepts the path to an image file as input, and returns the base64 representation of it.

### Window Style

Since AnyBox uses the default Windows modal, all of the `System.Window.WindowStyle` options are available:
-   None

![style-none.png](/img/style-none.png)

-   Single Border Window

![style-singleborder.png](/img/style-singleborder.png)

-   3D Border Window

See: [https://stackoverflow.com/a/7482728](https://stackoverflow.com/a/7482728)

![style-threeD.png](/img/style-threeD.png)

-   Tool Window

![style-tool.png](/img/style-tool.png)

Similarly, all `System.Windows.ResizeMode` options are available (detailed [here](https://msdn.microsoft.com/en-us/library/system.windows.window.resizemode%28v=vs.110%29.aspx)). ~~However, because the AnyBox works by using a `StackPanel` to stack the controls atop one another, no vertical resizing is possible; only horizontal resizing. For this reason, it may be best to stick with `NoResize` or `CanMinimize`, since maximizing the window will look odd. Also, consider using the `ToolWindow` style, which omits all but the ‘exit’ button.~~

> **EDIT**: the above no longer applies since v0.2; a window can now be fully maximized.

A few notes on `-ResizeMode`… Maximizing and Minimizing is considered “resizing”. Thus:

-   “NoResize” will hide the minimize and maximize buttons, and will not allow users to resize the window.
-   “CanMinimize” will show the minimize button, but disable the maximize button and will not allow users to resize the window.
-   “CanResize” and “CanResizeWithGrip” will show the minimize and maximize buttons, and allow users to resize the window.

### Timeout
Lastly, the AnyBox has a timeout feature that will close the window after the specified number of seconds. It is configured using the `-Timeout` and, when specified, the AnyBox output will include a key named `TimedOut` to indicate if the timeout was reached.

The switch parameter `-Countdown` will show a countdown in the AnyBox.

![countdown.png](/img/countdown.png)

```
Name         Value
----          -----
I feel fine   False
TimedOut      True
```

### Scripting Options
Users can provide their own options and more via the use of the `-PrepScript` parameter. Pass a script block here, and it will be ran before the window is shown. The advantage is that all of the form variables, stored in the variable `$_`, are accessible. The options with `-PrepScript` are endless, so I’ll just provide this example, which exports all variables to a grid view prior to showing the window:

```powershell
Show-AnyBox -Message 'Testing' -PrepScript {
  Get-Variable | Out-GridView -Title 'AnyBox Vars'
}
```


## Examples
An example AnyBox-driven app, Process Mgr, can be found in the [Examples folder](./Examples/). The app will prompt you for a computer name and filter. It will return all matching processes, giving you the option to kill selected processes. It will then confirm and kill the selected processes, and loop back to the start.