function Show-AnyBox
{
    <#
    .SYNOPSIS
        A multi-purpose window to make script input/output easier for developers and more presentable to users.
    .DESCRIPTION
        ...
    .NOTES
        All parameters without a 'Validate...' attribute are optional.
    .PARAMETER Icon
        The icon shown in the top-left corner of the window.
    .PARAMETER Title
        The window title.
    .PARAMETER Image
        The path to an image file, or a base64 string representation of an image. See 'Get-Base64'.
    .PARAMETER Message
        One or more messages to display in the window.
    .PARAMETER Prompts
        One or more [AnyBox.Prompt] objects used to accept user input.
        New in v0.3: Prompts also accepts one or more strings, from which AnyBox will
        create text box input prompts, using the given strings as prompt messages.
    .PARAMETER Buttons
        One or more buttons to show at the bottom of the window.
    .PARAMETER CancelButton
        The name of the button to designate as the 'Cancel' button. This button will not validate input,
        and will be selected if the user presses the 'ESC' key.
    .PARAMETER DefaultButton
        The name of the button to designate as the 'Default' button. This button will be selected
        if the user presses the 'ENTER' key. The 'Default' button, as with all other non-Cancel buttons,
        will validate user input before closing the window.
    .PARAMETER ButtonRows
        The number of rows used when adding the buttons.
    .PARAMETER Comment
        Similar to 'Message', but shown in italics near the bottom of the window.
    .PARAMETER ContentAlignment
        Specifies whether the window contents will be left-aligned or center-aligned; default is 'Center'.
    .PARAMETER FontFamily
        The text font type; defaults to 'Segoe UI'.
    .PARAMETER FontSize
        An integer specifying the size of the text.
    .PARAMETER FontColor
        The text color as a name (e.g., 'Black') or hex code (e.g., '#000000').
    .PARAMETER BackgroundColor
        The color of the window background as a name (e.g., 'Black') or hex code (e.g., '#000000').
    .PARAMETER WindowStyle
        The window style. caSee https://msdn.microsoft.com/en-us/library/system.windows.window.windowstyle(v=vs.110).aspx.
    .PARAMETER ResizeMode
        The resize mode of the window. Note that this parameter also affects whether the minimize and maximize
        buttons are present.
    .PARAMETER NoResize
        A simpler way to prevent window resizing.
    .PARAMETER MinHeight
        The minimum height of the resulting window, in pixels.
    .PARAMETER MinWidth
        The minimum width of the resulting window, in pixels.
    .PARAMETER Topmost
        If specified, the window will show atop all other windows.
    .PARAMETER HideTaskbarIcon
        Hides the program icon from the taskbar. If specified, the minimize button will not be shown.
    .PARAMETER Timeout
        If provided, the window will automatically close after the specified number of seconds.
    .PARAMETER Countdown
        If 'Timeout' is provided, specifies whether a countdown is shown in the window.
    .PARAMETER ParentWindow
        A [System.Windows.Window] object to use as the parent window.
    .PARAMETER GridData
        An array of objects to be shown in a DataGrid within the window.
    .PARAMETER SelectionMode
        Alters how cells in the DataGrid are selected (e.g. single cell, full row)
    .PARAMETER HideGridSearch
        Suppresses the search controls that are automatically displayed above the DataGrid.
        Also suppresses the automatic 'Explore' and 'Save' buttons that appear when 'GridData' is provided.
    .EXAMPLE
        ...
    .INPUTS
        A combination of parameters defining the window's content and appearance.
    .OUTPUTS
        A hashtable of key-value pairs containing what input was received (e.g., text input, button clicked).
    #>
    [cmdletbinding(DefaultParameterSetName = 'obj')]
    param(
        [Parameter(ParameterSetName = 'obj', ValueFromPipeline = $true)]
        [AnyBox.AnyBox]$AnyBox,
        [Parameter(ParameterSetName = 'create')]
        [Alias('i')]
        [string]$Icon,
        [Parameter(ParameterSetName = 'create')]
        [Alias('t')]
        [string]$Title,
        [Parameter(ParameterSetName = 'create')]
        [string]$Image,
        [Parameter(ParameterSetName = 'create')]
        [Alias('m')]
        [string[]]$Message,
        [Parameter(ParameterSetName = 'create')]
        [Alias('p', 'Prompt')]
        [object[]]$Prompts,
        [Parameter(ParameterSetName = 'create')]
        [Alias('f', 'From')]
        [string]$PromptsFromFunc,
        [scriptblock]$PromptsFromScriptblock,
        [Parameter(ParameterSetName = 'create')]
        [Alias('b', 'Button')]
        [object[]]$Buttons,
        [Parameter(ParameterSetName = 'create')]
        [string]$CancelButton,
        [Parameter(ParameterSetName = 'create')]
        [string]$DefaultButton,
        [Parameter(ParameterSetName = 'create')]
        [ValidateScript({ $_ -gt 0 })]
        [uint16]$ButtonRows = 1,
        [Parameter(ParameterSetName = 'create')]
        [Alias('c')]
        [string[]]$Comment,
        [Parameter(ParameterSetName = 'create')]
        [ValidateSet('Left', 'Center')]
        [Alias('Alignment')]
        [string]$ContentAlignment = 'Left',
        [Parameter(ParameterSetName = 'create')]
        [switch]$CollapsibleGroups,
        [Parameter(ParameterSetName = 'create')]
        [switch]$CollapsedGroups,
        [Parameter(ParameterSetName = 'create')]
        [scriptblock]$PrepScript,
        [Parameter(ParameterSetName = 'create')]
        [ValidateNotNullOrEmpty()]
        [System.Windows.Media.FontFamily]$FontFamily = 'Segoe UI',
        [Parameter(ParameterSetName = 'create')]
        [ValidateScript({ $_ -gt 0 })]
        [uint16]$FontSize = 12,
        [Parameter(ParameterSetName = 'create')]
        [ValidateNotNullOrEmpty()]
        [Alias('fg')]
        [System.Windows.Media.Brush]$FontColor = 'Black',
        [Parameter(ParameterSetName = 'create')]
        [Alias('bg')]
        [System.Windows.Media.Brush]$BackgroundColor,
        [Parameter(ParameterSetName = 'create')]
        [System.Windows.Media.Brush]$AccentColor = 'Gainsboro',
        [Parameter(ParameterSetName = 'create')]
        [System.Windows.WindowStyle]$WindowStyle = 'SingleBorderWindow',
        [Parameter(ParameterSetName = 'create')]
        [System.Windows.ResizeMode]$ResizeMode = 'CanMinimize',
        [Parameter(ParameterSetName = 'create')]
        [switch]$NoResize,
        [Parameter(ParameterSetName = 'create')]
        [ValidateScript({ $_ -gt 0 })]
        [uint16]$MinHeight = 50,
        [Parameter(ParameterSetName = 'create')]
        [ValidateScript({ $_ -gt 0 })]
        [uint16]$MinWidth = 50,
        [Parameter(ParameterSetName = 'create')]
        [uint16]$MaxHeight = 0,
        [Parameter(ParameterSetName = 'create')]
        [uint16]$MaxWidth = 0,
        [Parameter(ParameterSetName = 'create')]
        [switch]$Topmost,
        [Parameter(ParameterSetName = 'create')]
        [switch]$HideTaskbarIcon,
        [Parameter(ParameterSetName = 'create')]
        [Alias('sec')]
        [uint32]$Timeout,
        [Parameter(ParameterSetName = 'create')]
        [Alias('count')]
        [switch]$Countdown,
        [Parameter(ParameterSetName = 'create')]
        [Alias('pb')]
        [switch]$ProgressBar,
        [Parameter(ParameterSetName = 'create')]
        [scriptblock]$While,
        [Parameter(ParameterSetName = 'create')]
        [AnyBox.WindowStartupLocation]$WindowStartupLocation = 'Center',
        [Parameter(ParameterSetName = 'create')]
        [System.Windows.Window]$ParentWindow = $null,
        [Parameter(ParameterSetName = 'create')]
        [Alias('d')]
        [object[]]$GridData,
        [Parameter(ParameterSetName = 'create')]
        [switch]$GridAsList,
        [Parameter(ParameterSetName = 'create')]
        [AnyBox.DataGridSelectionMode]$SelectionMode = 'SingleCell',
        [Parameter(ParameterSetName = 'create')]
        [Alias('HideGridSearch')]
        [switch]$NoGridSearch
    )

    if ($AnyBox)
    {
        $AnyBox.psobject.properties | ForEach-Object {
            Set-Variable -Name $_.Name -Value $_.Value -Force
        }
    }

    if ($NoResize -or ($HideTaskbarIcon -and $ResizeMode -ne 'NoResize' -and @('None', 'ToolWindow') -notcontains $WindowStyle))
    {
        # No minimize button
        $ResizeMode = 'NoResize'
    }

    $form = @{'Result' = [hashtable]::Synchronized(@{}) }

    [xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    AllowsTransparency="False" WindowStartupLocation="CenterScreen" SizeToContent="WidthAndHeight" ShowActivated="True"
    Topmost="$($Topmost -as [bool])" ShowInTaskbar="$(-not ($HideTaskbarIcon -as [bool]))" MinWidth="$MinWidth" MinHeight="$MinHeight"
    WindowStyle="$WindowStyle" ResizeMode="$ResizeMode">
    <Border Name="padBorder" Padding="10, 0, 10, 10">
        <Grid Name="grid" Width="Auto" Height="Auto" ShowGridLines="False">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" />
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto" />
                <RowDefinition Height="*" />
                <RowDefinition Height="Auto" />
            </Grid.RowDefinitions>

            <ScrollViewer VerticalScrollBarVisibility="Auto">
                <StackPanel Name="highStack" Grid.Column="0" Grid.Row="0" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0"/>
            </ScrollViewer>
            
            <DataGrid Name='data_grid' Grid.Column="0" Grid.Row="1" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0" Visibility="Collapsed"/>

            <StackPanel Name="lowStack" Grid.Column="0" Grid.Row="2" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0"/>
        </Grid>
    </Border>
</Window>
"@

    $form.Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
    $xaml.SelectNodes('//*[@Name]').Name | ForEach-Object { $form.Add($_, $form.Window.FindName($_)) }
    $xaml = $null

    if ($PromptsFromFunc)
    {
        $PromptsFromScriptblock = (Get-Command $PromptsFromFunc).ScriptBlock
    }

    if ($PromptsFromScriptblock)
    {
        [AnyBox.Prompt[]]$sb_prompts = ConvertTo-AnyBoxPrompts -ScriptBlock $PromptsFromScriptblock

        foreach ($p in $sb_prompts)
        {
            $p.MessagePosition = [AnyBox.MessagePosition]::Left
        }

        if (-not $Prompts)
        {
            $Prompts = @()
        }

        $Prompts += $sb_prompts

        if (-not $Title)
        {
            $Title = $PromptsFromScriptblock.Ast.Name
        }

        if (-not $Buttons)
        {
            $Buttons = @('Run')
        }
    }

    if ($MaxHeight -ge $MinHeight)
    {
        $form.Window.MaxHeight = $MaxHeight
    }

    if ($MaxWidth -ge $MinWidth)
    {
        $form.Window.MaxWidth = $MaxWidth
    }

    if ($WindowStyle -eq 'None')
    {
        $form.Window.BorderBrush = 'Black'
        $form.Window.BorderThickness = '1'
    }

    if ($Title)
    {
        $form.Window.Title = $Title 
    }
    if ($FontColor)
    {
        $form.Window.Foreground = $FontColor 
    }
    if ($BackgroundColor)
    {
        $form.Window.Background = $BackgroundColor
    }

    if ($Icon)
    {
        # https://stackoverflow.com/a/2572771
        $form.Window.Icon = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(([System.Drawing.SystemIcons]::$Icon).Handle, `
                [System.Windows.Int32Rect]::Empty, `
                [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions())
    }

    [hashtable]$childWinParams = @{
        FontFamily = $FontFamily
        FontSize = $FontSize
        FontColor = $FontColor
        BackgroundColor = $BackgroundColor
        NoGridSearch = $true
        WindowStyle = 'None'
        ResizeMode = 'NoResize'
        NoResize = $true
        MinHeight = 25
        MinWidth = 25
        HideTaskbarIcon = $true
        Topmost = $true
        ParentWindow = $form.Window
    }

    if ($ParentWindow)
    {
        $form.Window.Owner = $ParentWindow
        $form.Window.WindowStartupLocation = 'CenterOwner'
        $form.Window.Topmost = $false
    }

    if ($Image)
    {
        $img = New-Object System.Windows.Controls.Image

        if ($Image.Length -gt 260 -and $Image.Length % 4 -eq 0)
        {
            # 260 is max path-length and base64 is a multiple of 4.
            $img.Source = $Image | ConvertTo-BitmapImage
        }
        elseif (Test-Path $Image)
        {
            $img.Source = $Image
        }
        elseif (Test-Path "$PSScriptRoot\$Image")
        {
            $img.Source = "$PSScriptRoot\$Image"
        }

        if (-not $img.Source)
        {
            $img = $null
            $Image = $null
        }
        else
        {
            $img.Margin = '0, 10, 0, 0'
            $img.MaxWidth = $img.Source.Width
            $img.MaxHeight = $img.Source.Height
            $img.HorizontalAlignment = 'Center'
            $img.VerticalAlignment = 'Center'
            $form.highStack.AddChild($img)
        }
    }

    # Add message textblocks.
    if (($txtMsg = New-TextBlock -RefForm ([ref]$form) -Text $($Message -join [environment]::NewLine) -Name 'Message' -FontFamily $FontFamily -FontSize $FontSize -FontColor $FontColor -ContentAlignment $ContentAlignment))
    {
        $form.highStack.AddChild($txtMsg)
    }

    [uint16]$i = 0

    [scriptblock]$addMsgBox = {
        param($p)

        if (($inPrmpt = New-TextBlock -RefForm ([ref]$form) -Text $p.Message -FontFamily $p.FontFamily -FontSize $p.FontSize -FontColor $p.FontColor -ContentAlignment $p.Alignment))
        {
            if ($p.Collapsible)
            {
                $inPrmpt.Margin = 0
                $expander.Header = $inPrmpt
            }
            elseif ($p.MessagePosition -eq [AnyBox.MessagePosition]::Left)
            {
                $inPrmpt.Margin = '0, 10, 5, 0'
                $inPanel.AddChild($inPrmpt)
            }
            elseif ($group_stack)
            {
                $group_stack.AddChild($inPrmpt)
            }
            else
            {
                $form.highStack.AddChild($inPrmpt)
            }
        }
    }

    $tab_panel = $null
    if ($Prompts | Where-Object { $_.Tab })
    {
        $tab_panel = New-Object System.Windows.Controls.TabControl
        $tab_panel.HorizontalAlignment = 'Stretch'
        $tab_panel.VerticalAlignment = 'Stretch'
        $tab_panel.Margin = '0, 10, 0, 0'
        $tab_panel.Padding = '5, 0, 5, 10'
        $tab_panel.Background = 'Transparent'
        $form.Add('Tabs', $tab_panel)
    }

    $Prompts | Group-Object -Property 'Tab' | Sort-Object Name | ForEach-Object {
        $tabName = $_.Values[0]

        $tab_stack = $null

        if ($tab_panel)
        {
            $tab_stack = New-Object System.Windows.Controls.StackPanel
            $tab_stack.HorizontalAlignment = 'Stretch'
            $tab_stack.VerticalAlignment = 'Stretch'
            $tab_stack.Margin = '5, 0, 5, 0'
        }

        $_.Group | Group-Object -Property 'Group' | Sort-Object Name | ForEach-Object {

            $groupName = $_.Values[0]

            $group_stack = $null

            if ($tab_panel -or $groupName)
            {
                $group_stack = New-Object System.Windows.Controls.StackPanel
                $group_stack.HorizontalAlignment = 'Stretch'
                $group_stack.VerticalAlignment = 'Stretch'
                $group_stack.Margin = '5, 0, 5, 0'
            }

            # Add prompt-message textblocks and input textboxes.
            foreach ($prmpt in $_.Group)
            {
                $inBox = $null
                $inPanel = $null # when 'MessagePosition' = 'Left'
                $expander = $null # when 'Collapsible' = $true

                if ($prmpt -is [string])
                {
                    $prmpt = New-AnyBoxPrompt -Name "Input_$i" -Message $prmpt
                    $Prompts[$i] = $prmpt
                }
                elseif (-not $prmpt.Name)
                {
                    $prmpt.Name = "Input_$i"
                }

                $form.Result.Add($prmpt.Name, $prmpt.DefaultValue)

                if (-not $prmpt.Alignment)
                {
                    $prmpt.Alignment = $ContentAlignment 
                }
                if (-not $prmpt.FontFamily)
                {
                    $prmpt.FontFamily = $FontFamily 
                }
                if (-not $prmpt.FontSize)
                {
                    $prmpt.FontSize = $FontSize 
                }
                if (-not $prmpt.FontColor)
                {
                    $prmpt.FontColor = $FontColor 
                }

                if ($prmpt.Collapsible)
                {
                    $expander = New-Object System.Windows.Controls.Expander
                    $expander.BorderThickness = 1
                    $expander.BorderBrush = $AccentColor
                    $expander.Padding = 3
                    $expander.IsExpanded = $(-not $prmpt.Collapsed)
                    $expander.VerticalAlignment = 'Center'
                    $expander.VerticalContentAlignment = 'Center'
                    $expander.HorizontalAlignment = 'Stretch'
                    $expander.HorizontalContentAlignment = 'Stretch'
                }
                elseif ($prmpt.MessagePosition -eq [AnyBox.MessagePosition]::Left)
                {
                    $inPanel = New-Object System.Windows.Controls.DockPanel
                    $inPanel.LastChildFill = $true
                }

                if ($prmpt.ValidateSet)
                {
                    & $addMsgBox $prmpt

                    if ($prmpt.ShowSetAs -eq [AnyBox.SetPresentation]::ComboBox)
                    {
                        $inBox = New-Object System.Windows.Controls.ComboBox
                        $inBox.MinHeight = 25
                        $inBox.IsReadOnly = $true
                        $inBox.HorizontalContentAlignment = $prmpt.Alignment
                        $inBox.VerticalAlignment = 'Center'
                        $inBox.VerticalContentAlignment = 'Center'

                        $prmpt.ValidateSet | ForEach-Object {
                            $null = $inBox.Items.Add((New-TextBlock -RefForm ([ref]$form) -Text $_ -FontFamily $prmpt.FontFamily -FontSize $prmpt.FontSize -FontColor 'Black' -Margin 0 -ContentAlignment $prmpt.Alignment))
                        }

                        if ($prmpt.DefaultValue)
                        {
                            $inBox.SelectedItem = $inBox.Items | Where-Object { $_.Text -eq $prmpt.DefaultValue } | Select-Object -First 1
                        }

                        $inBox.add_SelectionChanged({
                                $form.Result[$_.Source.Name] = $_.Source.SelectedItem.Text
                            })
                    }
                    else
                    {
                        # radio
                        $inBox = New-Object System.Windows.Controls.StackPanel
                        $inBox.HorizontalAlignment = $prmpt.Alignment
                        if ($prmpt.ShowSetAs -eq [AnyBox.SetPresentation]::Radio_Wide)
                        {
                            $inBox.Orientation = 'Horizontal'
                        }

                        $prmpt.ValidateSet | ForEach-Object {
                            $r = New-Object System.Windows.Controls.RadioButton
                            if ($prmpt.RadioGroup)
                            {
                                $r.GroupName = $prmpt.RadioGroup
                            }
                            else
                            {
                                $r.GroupName = "Group_$i"
                            }
                            $r.Content = $_
                            $r.Margin = '5, 5, 0, 0'
                            $r.Padding = 0
                            $r.IsChecked = $($_ -eq $prmpt.DefaultValue)
                            $r.FontSize = $prmpt.FontSize
                            $r.FontFamily = $prmpt.FontFamily
                            $r.Foreground = $prmpt.FontColor
                            # $r.VerticalAlignment = 'Center'
                            $r.VerticalContentAlignment = 'Center'
                            $r.HorizontalAlignment = 'Left'
                            $r.HorizontalContentAlignment = 'Left'

                            $r.add_Unchecked({
                                    if ($form.Result[$_.Source.Parent.Name] -eq $_.Source.Content)
                                    {
                                        $form.Result[$_.Source.Parent.Name] = $null
                                    }
                                })

                            $r.add_Checked({
                                    $form.Result[$_.Source.Parent.Name] = $_.Source.Content
                                })

                            $inBox.AddChild($r)
                        }
                    }
                }
                elseif ($prmpt.InputType -eq [AnyBox.InputType]::Checkbox)
                {
                    # Check box
                    $inBox = New-Object System.Windows.Controls.CheckBox
                    $inBox.Content = $prmpt.Message
                    $inBox.FontSize = $prmpt.FontSize
                    $inBox.FontFamily = $prmpt.FontFamily
                    $inBox.Foreground = $prmpt.FontColor
                    $inBox.IsChecked = $($prmpt.DefaultValue -eq [bool]::TrueString)
                    $inBox.HorizontalAlignment = $prmpt.Alignment
                    $inBox.HorizontalContentAlignment = 'Left'

                    # add with default value that is true boolean, not string
                    $form.Result[$prmpt.Name] = $inBox.IsChecked

                    $inBox.add_Click({
                            $form.Result[$_.Source.Name] = $_.Source.IsChecked
                        })
                }
                elseif ($prmpt.InputType -eq [AnyBox.InputType]::Password)
                {
                    # Password box
                    & $addMsgBox $prmpt

                    $inBox = New-Object System.Windows.Controls.PasswordBox
                    $inBox.MinHeight = 25
                    $inBox.Padding = '3, 0, 0, 0'
                    # $inBox.HorizontalAlignment = 'Stretch'
                    $inBox.HorizontalContentAlignment = $prmpt.Alignment
                    $inBox.VerticalContentAlignment = 'Center'
                    $inBox.VerticalAlignment = 'Center'
                    # $inBox.FontStyle = 'Normal'
                    $inBox.Background = 'WhiteSmoke'

                    $inBox.add_PasswordChanged({
                            $form.Result[$_.Source.Name] = $_.Source.SecurePassword
                        })
                }
                elseif ($prmpt.InputType -eq [AnyBox.InputType]::Date)
                {
                    # Date picker
                    & $addMsgBox $prmpt

                    $inBox = New-Object System.Windows.Controls.DatePicker
                    $inBox.HorizontalContentAlignment = $prmpt.Alignment
                    $inBox.DisplayDate = [datetime]::Today
                    $inBox.DisplayDateStart = [datetime]::MinValue
                    $inBox.DisplayDateEnd = [datetime]::MaxValue
                    $inBox.SelectedDateFormat = [System.Windows.Controls.DatePickerFormat]::Short
                    $inBox.Text = $prmpt.DefaultValue
                    $inBox.Background = 'WhiteSmoke'

                    $inBox.add_SelectedDateChanged({
                            $form.Result[$_.Source.Name] = $_.Source.Text
                        })
                }
                elseif ($prmpt.InputType -eq [AnyBox.InputType]::Link)
                {
                    # Hyperlink
                    $inBox = New-TextBlock -RefForm ([ref]$form) -Text $prmpt.Message -FontFamily $prmpt.FontFamily -FontSize $prmpt.FontSize -FontColor $prmpt.FontColor -ContentAlignment $prmpt.Alignment
                    $form.Result[$prmpt.Name] = $false
                    $inBox.TextDecorations = 'Underline'
                    $inBox.Cursor = 'Hand'
                    $inBox.Tooltip = $prmpt.DefaultValue
                    [string]$onClick = $null # "`$_.Source.Foreground = 'Navy'; "
                    if ($prmpt.DefaultValue)
                    {
                        $onClick = "`$form.Result[`$_.Source.Name] = `$true; start '$($prmpt.DefaultValue)'"
                    }
                    else
                    {
                        $onClick = "`$form.Result[`$_.Source.Name] = `$true; start '$($prmpt.Message)'"
                    }
                    $inBox.add_MouseLeftButtonDown([scriptblock]::Create($onClick))
                }
                else
                {
                    # Text box
                    & $addMsgBox $prmpt

                    $inBox = New-Object System.Windows.Controls.TextBox
                    $inBox.MinHeight = 25
                    $inBox.Padding = '3, 0, 0, 0'
                    $inBox.HorizontalContentAlignment = $prmpt.Alignment
                    $inBox.TextAlignment = $prmpt.Alignment
                    $inBox.VerticalContentAlignment = 'Center'
                    $inBox.AcceptsTab = $false
                    $inBox.TextWrapping = 'NoWrap'
                    $inBox.Background = 'WhiteSmoke'
                    $inBox.IsReadOnly = $prmpt.ReadOnly
                    $inBox.IsEnabled = (-not $prmpt.ReadOnly)

                    if ($prmpt.DefaultValue -ne $null)
                    {
                        $inBox.Text = $prmpt.DefaultValue
                    }

                    if ($prmpt.LineHeight -gt 1)
                    {
                        $inBox.AcceptsReturn = $true
                        $inBox.TextWrapping = 'Wrap'
                        $inBox.MinWidth = 75
                        $inBox.MaxHeight = 25 * $prmpt.LineHeight
                        $inBox.Height = $inBox.MaxHeight
                    }
                    else
                    {
                        $inBox.MaxHeight = 25 * @($prmpt.DefaultValue -split "`n").Count
                        $inBox.Height = $inBox.MaxHeight
                    }

                    $inBox.add_GotFocus({ $_.Source.SelectAll() })

                    $inBox.add_TextChanged({
                            $form.Result[$_.Source.Name] = $_.Source.Text
                        })

                    ##############################################

                    if (@([AnyBox.InputType]::FileOpen, [AnyBox.InputType]::FileSave, [AnyBox.InputType]::FolderOpen) -contains $prmpt.InputType)
                    {
                        $filePanel = New-Object System.Windows.Controls.DockPanel
                        $filePanel.LastChildFill = $true
                        $filePanel.Margin = '0, 10, 0, 0'
                        # $filePanel.HorizontalAlignment = 'Stretch'

                        $fileBtn = New-Object System.Windows.Controls.Button
                        $fileBtn.Name = 'btn_' + $prmpt.Name
                        $fileBtn.Height = 25
                        $fileBtn.Width = 25
                        # $fileBtn.Margin = "0, 5, 0, 0"

                        # $inBox.Margin = "0, 5, 0, 0"
                        $inBox.Padding = "0, 0, $($fileBtn.Width.ToString()), 0"

                        $fileBtn.ToolTip = 'Browse'
                        $fileBtn.Content = '...'

                        [string]$init_dir = $null

                        if ($prmpt.DefaultValue)
                        {
                            if (Test-Path $prmpt.DefaultValue -PathType Leaf)
                            {
                                $init_dir = Split-Path $prmpt.DefaultValue -Parent
                            }
                            elseif (Test-Path $prmpt.DefaultValue -PathType Container)
                            {
                                $init_dir = $prmpt.DefaultValue
                            }
                        }

                        if ($prmpt.InputType -eq [AnyBox.InputType]::FileOpen)
                        {
                            $fileBtn.add_Click({
                                    [string]$inBoxName = $_.Source.Name.Replace('btn_', '')
                                    $opnWin = New-Object Microsoft.Win32.OpenFileDialog
                                    $opnWin.Title = 'Open File'
                                    $opnWin.CheckFileExists = $true
                                
                                    if ($init_dir)
                                    {
                                        $opnWin.InitialDirectory = $init_dir
                                    }

                                    if ($opnWin.ShowDialog())
                                    {
                                        if (-not (Test-Path $opnWin.FileName))
                                        {
                                            Show-AnyBox @childWinParams -Message 'File not found.' -Buttons 'OK' -DefaultButton 'OK'
                                        }
                                        else
                                        {
                                            $form[$inBoxName].Text = $opnWin.FileName
                                        }
                                    }
                                })
                        }
                        elseif ($prmpt.InputType -eq [AnyBox.InputType]::FileSave)
                        {
                            $fileBtn.add_Click({
                                    [string]$inBoxName = $_.Source.Name.Replace('btn_', '')
                                    $savWin = New-Object Microsoft.Win32.SaveFileDialog
                                    $savWin.Title = 'Save File'
                                    $savWin.OverwritePrompt = $false

                                    if ($init_dir)
                                    {
                                        $savWin.InitialDirectory = $init_dir
                                    }

                                    if ($savWin.ShowDialog() -and $savWin.FileName)
                                    {
                                        $form[$inBoxName].Text = $savWin.FileName
                                    }
                                })
                        }
                        else
                        {
                            # [AnyBox.InputType]::FolderOpen
                            $fileBtn.add_Click({
                                    [string]$inBoxName = $_.Source.Name.Replace('btn_', '')
                                    $opnWin = New-Object System.Windows.Forms.FolderBrowserDialog
                                    $opnWin.Description = 'Select Folder'
                                    $opnWin.ShowNewFolderButton = $true

                                    if ($init_dir)
                                    {
                                        $opnWin.SelectedPath = $init_dir
                                    }

                                    if ($opnWin.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
                                    {
                                        if (-not (Test-Path $opnWin.SelectedPath))
                                        {
                                            Show-AnyBox @childWinParams -Message 'Folder not found.' -Buttons 'OK' -DefaultButton 'OK'
                                        }
                                        else
                                        {
                                            $form[$inBoxName].Text = $opnWin.SelectedPath
                                        }
                                    }
                                })
                        }

                        $filePanel.AddChild($fileBtn)
                        # $filePanel.AddChild($inBox)

                        $form.Add($fileBtn.Name, $fileBtn)
                    }

                    ##############################################
                }

                $inBox.Name = $prmpt.Name.ToString()

                $form.Add($inBox.Name, $inBox)

                if ($filePanel)
                {
                    $filePanel.AddChild($inBox)
                    $inBox = $filePanel
                    $filePanel = $null
                }

                $toAdd = $null

                if ($expander)
                {
                    $inBox.Margin = 0
                    $expander.Margin = '0, 10, 0, 0'
                    $expander.Content = $inBox
                    $toAdd = $expander
                    # $form.highStack.AddChild($expander)
                }
                else
                {
                    $inBox.Margin = '0, 10, 0, 0'

                    if ($inPanel)
                    {
                        $inPanel.AddChild($inBox)
                        $toAdd = $inPanel
                        # $form.highStack.AddChild($inPanel)
                    }
                    else
                    {
                        $toAdd = $inBox
                        # $form.highStack.AddChild($inBox)
                    }
                }

                if ($group_stack)
                {
                    $group_stack.AddChild($toAdd)
                }
                else
                {
                    $form.highStack.AddChild($toAdd)
                }

                if ($prmpt.ShowSeparator)
                {
                    $sep = New-Object System.Windows.Controls.Separator
                    $sep.Margin = '10, 10, 10, 0'
                    $sep.Background = $AccentColor

                    if ($group_stack)
                    {
                        $group_stack.AddChild($sep)
                    }
                    else
                    {
                        $form.highStack.AddChild($sep)
                    }
                }

                $inBox = $null
                $inPanel = $null
                $expander = $null
                $i++
            }
        

            if ($group_stack)
            {
                $group_box = $null
                if ($groupName)
                {
                    if ($CollapsibleGroups)
                    {
                        $group_box = New-Object System.Windows.Controls.Expander
                        $group_box.IsExpanded = $(-not $CollapsedGroups)
                    }
                    else
                    {
                        $group_box = New-Object System.Windows.Controls.GroupBox
                    }

                    if ($groupName -imatch '[a-z]')
                    {
                        $header = New-TextBlock -RefForm ([ref]$form) -text $groupName -FontFamily $FontFamily -FontSize $FontSize -FontColor $FontColor -ContentAlignment $ContentAlignment
                        $header.VerticalAlignment = 'Center'
                        $header.HorizontalAlignment = 'Left'
                        $header.Margin = 0
                        $group_box.Header = $header
                    }

                    $group_box.Margin = '0, 10, 0, 0'
                    $group_box.BorderThickness = 1
                    $group_box.BorderBrush = $AccentColor
                    $group_box.Padding = 3
                    $group_box.VerticalAlignment = 'Center'
                    $group_box.VerticalContentAlignment = 'Center'
                    $group_box.HorizontalAlignment = 'Stretch'
                    $group_box.HorizontalContentAlignment = 'Stretch'

                    $group_box.Content = $group_stack
                }

                if (-not $tabName)
                {
                    if ($groupName)
                    {
                        $form.highStack.AddChild($group_box)
                    }
                    else
                    {
                        $form.highStack.AddChild($group_stack)
                    }
                }
                else
                {
                    if ($groupName)
                    {
                        $tab_stack.AddChild($group_box)
                    }
                    else
                    {
                        $tab_stack.AddChild($group_stack)
                    }
                }
            }
        }

        if ($tab_panel)
        {
            $tab = New-Object System.Windows.Controls.TabItem
            $tab.Header = New-TextBlock -RefForm ([ref]$form) -text $tabName -FontFamily $FontFamily -FontSize $FontSize -FontColor $FontColor -margin 0 -ContentAlignment $ContentAlignment
            $tab.Content = $tab_stack

            $null = $tab_panel.Items.Add($tab)
        }
    }
    

    if ($tab_panel)
    {
        $form.highStack.AddChild($tab_panel)
    }

    if ($GridData)
    {
        $dataGrid = $form['data_grid']

        $form.Result.Add('grid_select', $null)

        if ($GridAsList)
        {
            $GridData = $GridData | ConvertTo-Long
        }

        $dataGrid.ItemsSource = $GridData

        $dataGrid.Visibility = 'Visible'

        if ($SelectionMode -eq 'None')
        {
            $dataGrid.IsEnabled = $false
        }
        else
        {
            if ($SelectionMode -like 'Multi*')
            {
                $dataGrid.SelectionMode = 'Extended'
            }
            else
            {
                $dataGrid.SelectionMode = 'Single'
            }

            if ($SelectionMode -like '*Row')
            {
                $dataGrid.SelectionUnit = 'FullRow'
            }
            else
            {
                $dataGrid.SelectionUnit = 'Cell'
            }
        }

        $dataGrid.ClipboardCopyMode = 'ExcludeHeader'
        $dataGrid.Margin = '0, 10, 0, 0'
        $dataGrid.IsReadOnly = $true
        $dataGrid.AutoGenerateColumns = $true
        $dataGrid.VerticalScrollBarVisibility = 'Auto'
        $dataGrid.HorizontalScrollBarVisibility = 'Auto'
        $dataGrid.HorizontalAlignment = 'Stretch'
        $dataGrid.HorizontalContentAlignment = 'Stretch'
        $dataGrid.VerticalContentAlignment = 'Stretch'
        $dataGrid.VerticalAlignment = 'Stretch'
        $dataGrid.HeadersVisibility = 'Column'
        $dataGrid.AlternatingRowBackground = 'WhiteSmoke'
        $dataGrid.CanUserSortColumns = $true
        $dataGrid.CanUserResizeColumns = $true
        $dataGrid.CanUserResizeRows = $false
        $dataGrid.CanUserReorderColumns = $false
        $dataGrid.CanUserDeleteRows = $true
        $dataGrid.GridLinesVisibility = 'All'
        $dataGrid.FontSize = 12

        if ($SelectionMode -eq 'SingleCell')
        {
            $form['data_grid'].add_SelectedCellsChanged({
                    $selection = $null

                    if ($form['data_grid'].SelectedCells.Count -gt 0)
                    {
                        [psobject]$selection = @($form['data_grid'].SelectedCells | ForEach-Object { ([System.Windows.Controls.TextBlock]$_.Column.GetCellContent($_.Item)).Text })[0]
                    }
                
                    $form.Result['grid_select'] = $selection
                })
        }
        else
        {
            $form['data_grid'].add_SelectionChanged({			
                    $selection = $null

                    if ($form['data_grid'].SelectedItems.Count -gt 0)
                    {
                        switch ($SelectionMode)
                        {
                            'SingleRow'
                            {
                                [psobject]$selection = $form['data_grid'].SelectedItem
                            }
                            'MultiRow'
                            {
                                [psobject[]]$selection = @($form['data_grid'].SelectedItems)
                            }
                        }
                    }
                
                    $form.Result['grid_select'] = $selection
                })
        }

        if (-not $NoGridSearch)
        {
            $gridMsg = New-TextBlock -RefForm ([ref]$form) -Text $('{0} Results' -f $GridData.Count) -Name 'txt_Grid' -FontFamily $FontFamily -FontSize $FontSize -FontColor $FontColor -ContentAlignment $ContentAlignment
            $form.highStack.AddChild($gridMsg)
            
            [scriptblock]$filterGrid = {
                if (-not $form.filterText.Text)
                {
                    $form.data_grid.ItemsSource = $GridData
                    $form['txt_Grid'].Text = '{0} Results' -f $GridData.Count
                }
                elseif ($form.filterBy.SelectedItem)
                {
                    [string]$filterBy = $form.filterBy.SelectedItem.ToString()
                    [string]$filter = $form.filterText.Text

                    switch ($form.filterMatch.SelectedItem)
                    {
                        'contains'
                        {
                            $filter = [System.Text.RegularExpressions.Regex]::Escape($filter)
                            $form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -Match $filter)
                            break
                        }
                        'not contains'
                        {
                            $filter = [System.Text.RegularExpressions.Regex]::Escape($filter)
                            $form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -NotMatch $filter)
                            break
                        }
                        'starts with'
                        {
                            $form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -Like "$filter*")
                            break
                        }
                        'ends with'
                        {
                            $form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -Like "*$filter")
                            break
                        }
                        'equals'
                        {
                            $form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -EQ $filter)
                            break
                        }
                        'not equals'
                        {
                            $form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -NE $filter)
                            break
                        }
                        Default
                        {
                            $form.data_grid.ItemsSource = $GridData
                        }
                    }

                    $form['txt_Grid'].Text = '{0} / {1} Results' -f ([Collections.Generic.IEnumerable``1[object]]$form.data_grid.ItemsSource).Count, $GridData.Count
                }
            }

            # $form['data_grid'].add_SourceUpdated($filterGrid)

            $fltrBy = New-Object System.Windows.Controls.ComboBox
            $fltrBy.Name = 'filterBy'
            $fltrBy.FontSize = $FontSize
            $fltrBy.Margin = '0, 10, 0, 0'
            $fltrBy.MinHeight = 25
            $fltrBy.IsReadOnly = $true
            $fltrBy.HorizontalAlignment = 'Left'
            $fltrBy.HorizontalContentAlignment = 'Left'
            $fltrBy.VerticalAlignment = 'Center'
            $fltrBy.VerticalContentAlignment = 'Center'
            $fltrBy.add_SelectionChanged($filterGrid)

            $fltrMatch = New-Object System.Windows.Controls.ComboBox
            $fltrMatch.Name = 'filterMatch'
            $fltrMatch.FontSize = $FontSize
            $fltrMatch.Margin = '0, 10, 0, 0'
            $fltrMatch.MinHeight = 25
            $fltrMatch.IsReadOnly = $true
            $fltrMatch.HorizontalAlignment = 'Left'
            $fltrMatch.HorizontalContentAlignment = 'Left'
            $fltrMatch.VerticalAlignment = 'Center'
            $fltrMatch.VerticalContentAlignment = 'Center'
            $fltrMatch.ItemsSource = @('contains', 'not contains', 'starts with', 'ends with', 'equals', 'not equals')
            $fltrMatch.SelectedIndex = 0
            $fltrMatch.add_SelectionChanged($filterGrid)

            $fltrBox = New-Object System.Windows.Controls.TextBox
            $fltrBox.Name = 'filterText'
            $fltrBox.Padding = '3, 0, 0, 0'
            $fltrBox.Margin = '0, 10, 0, 0'
            $fltrBox.MinWidth = 50
            $fltrBox.TextAlignment = 'Left'
            $fltrBox.MinHeight = 25
            $fltrBox.HorizontalAlignment = 'Stretch'
            $fltrBox.HorizontalContentAlignment = 'Center'
            $fltrBox.VerticalContentAlignment = 'Center'
            $fltrBox.VerticalAlignment = 'Center'
            $fltrBox.TextWrapping = 'Wrap'
            $fltrBox.FontSize = $FontSize
            $fltrBox.AcceptsReturn = $false
            $fltrBox.AcceptsTab = $false
            $fltrBox.add_TextChanged($filterGrid)
            $fltrBox.add_GotFocus({ $_.Source.SelectAll() })

            $fltrPanel = New-Object System.Windows.Controls.DockPanel
            $fltrPanel.LastChildFill = $true
            $fltrPanel.AddChild($fltrBy)
            $fltrPanel.AddChild($fltrMatch)
            $fltrPanel.AddChild($fltrBox)

            $form.Add($fltrBy.Name, $fltrBy)
            $form.Add($fltrMatch.Name, $fltrMatch)
            $form.Add($fltrBox.Name, $fltrBox)
            $form.highStack.AddChild($fltrPanel)
        }
    }

    if ($ProgressBar)
    {
        $pb = New-Object System.Windows.Controls.ProgressBar
        $pb.Name = 'progress_bar'
        $pb.IsIndeterminate = $true
        $pb.MinHeight = 25;
        $pb.HorizontalAlignment = 'Stretch'
        $pb.VerticalAlignment = 'Center'
        $pb.Margin = '0, 10, 0, 0'
        $form.Add('progress_bar', $pb)
        $form.lowStack.AddChild($pb)
    }

    # Add comment textblocks.
    if (($txtMsg = New-TextBlock -RefForm ([ref]$form) -text $($Comment -join [environment]::NewLine) -name 'txt_Explain' -FontFamily $FontFamily -FontSize $FontSize -FontColor $FontColor -ContentAlignment $ContentAlignment))
    {
        $txtMsg.FontStyle = 'Italic'
        $txtMsg.FontWeight = 'Normal'
        $form.lowStack.AddChild($txtMsg)
    }

    if ($Timeout -and $Timeout -gt 0 -and $Countdown)
    {
        # Create countdown textblock.
        $txtTime = New-TextBlock -RefForm ([ref]$form) -Text '---' -Name 'txt_Countdown' -FontFamily $FontFamily -FontSize $FontSize -FontColor $FontColor -ContentAlignment $ContentAlignment
        $form.lowStack.AddChild($txtTime)
    }

    if ($Buttons.Count -gt 0)
    {
        if ($Buttons.Count -eq 1)
        {
            if ($Buttons[0] -is [AnyBox.Button])
            {
                $Buttons[0].IsDefault = $true
            }
            else
            {
                # string
                $DefaultButton = $Buttons[0]
            }
        }

        $Buttons | Where-Object { $_ -is [string] -or -not $_.OnClick } | ForEach-Object {
            if ($_ -is [AnyBox.Button])
            {
                if ($_.Name)
                {
                    $form.Result.Add($_.Name, $false)
                }
                else
                {
                    $form.Result.Add($_.Text, $false)
                }
            }
            else
            {
                # string
                $form.Result.Add($_ -as [string], $false)
            }
        }

        [int]$btn_per_row = [math]::Ceiling($Buttons.Count / ([double]$ButtonRows))

        [uint16]$c = 0

        1..$ButtonRows | ForEach-Object {
            # Create a horizontal stack-panel for buttons and populate it.
            $btnStack = New-Object System.Windows.Controls.StackPanel
            $btnStack.Orientation = 'Horizontal'
            $btnStack.HorizontalAlignment = 'Center'
            $btnStack.Margin = '0, 10, 0, 0'

            for ($i = 0; $i -lt $btn_per_row -and $c -lt $Buttons.Count; $i++)
            {
                $btn = New-Object System.Windows.Controls.Button
                $btn.MinHeight = 35
                $btn.MinWidth = 75
                $btn.FontSize = $FontSize
                $btn.Margin = '10, 0, 10, 0'
                $btn.VerticalContentAlignment = 'Center'
                $btn.HorizontalContentAlignment = 'Center'

                if ($Buttons[$c] -is [AnyBox.Button])
                {
                    $btn.Name = $Buttons[$c].Name
                    $btn.Content = '_' + $Buttons[$c].Text
                    if ($Buttons[$c].ToolTip)
                    {
                        $btn.ToolTip = $Buttons[$c].ToolTip
                    }
                    $btn.IsCancel = $Buttons[$c].IsCancel
                    $btn.IsDefault = $Buttons[$c].IsDefault

                    if ($Buttons[$c].OnClick)
                    {
                        $btn.add_Click([scriptblock]::Create((@'
$form.Result | Foreach-Object -Process {{
{0}
}}
'@ -f $Buttons[$c].OnClick.ToString())))
                    }
                    elseif ($Buttons[$c].IsCancel)
                    {
                        $btn.add_Click({
                                [string]$btn_name = $null
                                if ($_.Source.Name)
                                {
                                    $btn_name = $_.Source.Name
                                }
                                else
                                {
                                    $btn_name = $_.Source.Content.TrimStart('_')
                                }

                                $form.Result[$btn_name] = $true
                                $form.Window.Close()
                            })
                    }
                    else
                    {
                        $btn.add_Click({
                                $input_test = Test-ValidInput -Prompts $Prompts -Inputs $form.Result
                                if (-not $input_test.Is_Valid)
                                {
                                    $null = Show-AnyBox @childWinParams -Message $input_test.Message -Buttons 'OK' -DefaultButton 'OK'
                                }
                                else
                                {
                                    [string]$btn_name = $null
                                    if ($_.Source.Name)
                                    {
                                        $btn_name = $_.Source.Name
                                    }
                                    else
                                    {
                                        $btn_name = $_.Source.Content.TrimStart('_')
                                    }

                                    $form.Result[$btn_name] = $true
                                    $form.Window.Close()
                                } })
                    }
                }
                else
                {
                    # $btn.Name = $Buttons[$c]
                    $btn.Content = '_' + ($Buttons[$c] -as [string])

                    if ($CancelButton -eq $Buttons[$c])
                    {
                        $btn.add_Click({
                                [string]$btn_name = $_.Source.Content.TrimStart('_')
                                $form.Result[$btn_name] = $true
                                $form.Window.Close()
                            })
                        $btn.IsCancel = $true
                    }
                    else
                    {
                        $btn.add_Click({
                                $input_test = Test-ValidInput -Prompts $Prompts -Inputs $form.Result
                                if (-not $input_test.Is_Valid)
                                {
                                    $null = Show-AnyBox @childWinParams -Message $input_test.Message -Buttons 'OK' -DefaultButton 'OK'
                                }
                                else
                                {
                                    [string]$btn_name = $_.Source.Content.TrimStart('_')
                                    $form.Result[$btn_name] = $true
                                    $form.Window.Close()
                                } })

                        if ($DefaultButton -eq $Buttons[$c])
                        {
                            $btn.IsDefault = $true
                        }
                    }
                }

                $btnStack.AddChild($btn)

                $c++
            }

            $form.lowStack.AddChild($btnStack)
        }
    }

    $form.Window.add_Loaded({
            if ($form.Window.Owner)
            {
                $form.Window.Owner.Opacity = 0.4
            }

            if ($PrepScript)
            {
                $null = $form | ForEach-Object -Process $PrepScript
            }

            if ($GridData)
            {
                if (-not $NoGridSearch)
                {
                    $form.filterBy.ItemsSource = @($form.data_grid.Columns.Header)
                    $form.filterBy.SelectedIndex = 0
                }

                $form.data_grid.Columns | ForEach-Object {
                    $_.CanUserSort = $true
                    $_.SortMemberPath = $_.Header.ToString()
                    $_.SortDirection = 'Ascending'
                }
            }

            if ($Prompts)
            {
                [bool]$focused = $false
                for ($i = 0; $i -lt $Prompts.Length; $i++)
                {
                    if (($form[$Prompts[$i].Name] -is [System.Windows.Controls.TextBox] -and [string]::IsNullOrEmpty($form[$Prompts[$i].Name].Text)) -or `
                        ($form[$Prompts[$i].Name] -is [System.Windows.Controls.PasswordBox] -and $form[$Prompts[$i].Name].SecurePassword.Length -eq 0))
                    {
                        $null = $form[$Prompts[$i].Name].Focus()
                        $form[$Prompts[$i].Name].SelectAll()
                        $focused = $true
                        break
                    }
                }

                if (-not $focused -and $form[$Prompts[0].Name] -is [System.Windows.Controls.TextBox])
                {
                    $null = $form[$Prompts[0].Name].Focus()
                    $form[$Prompts[0].Name].SelectAll()
                }
            }

            if ($WindowStartupLocation -ne [AnyBox.WindowStartupLocation]::Center)
            {
                $form.Window.WindowStartupLocation = 'Manual'

                switch ($WindowStartupLocation)
                {
                ([AnyBox.WindowStartupLocation]::Top)
                    {
                        $form.Window.Left = ([System.Windows.SystemParameters]::WorkArea.Width - $form.Window.ActualWidth) / 2.0
                        $form.Window.Top = 0
                        break
                    }
                ([AnyBox.WindowStartupLocation]::TopLeft)
                    {
                        $form.Window.Left = 0
                        $form.Window.Top = 0
                        break
                    }
                ([AnyBox.WindowStartupLocation]::TopRight)
                    {
                        $form.Window.Left = [System.Windows.SystemParameters]::WorkArea.Width - $form.Window.ActualWidth
                        $form.Window.Top = 0
                        break
                    }
                ([AnyBox.WindowStartupLocation]::Bottom)
                    {
                        $form.Window.Left = ([System.Windows.SystemParameters]::WorkArea.Width - $form.Window.ActualWidth) / 2.0
                        $form.Window.Top = [System.Windows.SystemParameters]::WorkArea.Bottom - $form.Window.ActualHeight
                        break
                    }
                ([AnyBox.WindowStartupLocation]::BottomLeft)
                    {
                        $form.Window.Left = 0
                        $form.Window.Top = [System.Windows.SystemParameters]::WorkArea.Bottom - $form.Window.ActualHeight
                        break
                    }
                ([AnyBox.WindowStartupLocation]::BottomRight)
                    {
                        $form.Window.Left = [System.Windows.SystemParameters]::WorkArea.Width - $form.Window.ActualWidth
                        $form.Window.Top = [System.Windows.SystemParameters]::WorkArea.Bottom - $form.Window.ActualHeight
                        break
                    }
                }
            }
        })

    $form.Window.add_ContentRendered({
            if ($While)
            {
                $_whilejob = Start-ThreadJob -ArgumentList $form, $While -ScriptBlock {
                    param([hashtable]$form, [scriptblock]$While)

                    while (-not $form['IsClosed'] -and (& $While))
                    {
                        Start-Sleep -Seconds 1
                    }

                    if (-not $form['IsClosed'])
                    {
                        $form.Window.Dispatcher.Invoke(
                            [action] { $form.Window.Close() },
                            'Normal'
                        )
                    }
                }

                $form.Add('job', $_whilejob)
            }

            if ($Timeout)
            {
                $timer = New-Object System.Windows.Threading.DispatcherTimer
                $timer.Interval = [timespan]::FromSeconds(1.0)
                [datetime]$script:end_at = [datetime]::Now.AddSeconds($Timeout + 1)

                $timer.Add_Tick({
                        [timespan]$remaining = $script:end_at.Subtract([datetime]::now)
                        if ($Countdown)
                        {
                            $form.txt_Countdown.Text = $remaining.ToString('hh\:mm\:ss') 
                        }
            
                        if ($remaining.TotalSeconds -le 0)
                        {
                            $form.Timer.Stop()
                            $form.Result.TimedOut = $true
                            $form.Window.Close()
                        }
                    })

                $form.Add('Timer', $timer)

                $timer.Start()
            }

            $form.Window.Activate()
        })

    $form.Window.add_Closed({
            if ($Timeout -gt 0 -and $form['Timer'].IsEnabled)
            {
                $form['Timer'].Stop()
                $form['Timer'] = $null
            }

            $form['IsClosed'] = $true

            if ($form.Window.Owner)
            {
                $form.Window.Owner.Opacity = 1.0
                $form.Window.Owner.Activate()
            }
        })

    $null = $form.Window.ShowDialog()

    if ($form['job'])
    {
        $null = $form['job'] | Receive-Job -Wait -AutoRemoveJob -ErrorAction Stop
    }

    $form.Result

    $form = $null
}

Set-Alias -Name 'anybox' -Value 'Show-AnyBox' -Description 'Show-AnyBox' -Scope 'Global'
Set-Alias -Name 'show' -Value 'Show-AnyBox' -Description 'Show-AnyBox' -Scope 'Global'
