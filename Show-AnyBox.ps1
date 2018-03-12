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
		The path to an image file, or a base64 string representation of an image. See 'ConvertTo-Base64'.
	.PARAMETER Message
		One or more messages to display in the window.
	.PARAMETER Prompt
		One or more [AnyBox.Prompt] objects used to accept user input.
	.PARAMETER Buttons
		One or more buttons to show at the bottom of the window.
	.PARAMETER CancelButton
		The name of the button to designate as the 'Cancel' button. This button will not validate input,
		and will be selected if the user presses the 'ESC' key.
	.PARAMETER DefaultButton
		The name of the button to designate as the 'Default' button. This button will be selected
		if the user presses the 'ENTER' key. The 'Default' button, as with all other non-Cancel buttons,
		will validate user input before closing the window.
	.PARAMETER ShowCopyButton
		If specified, a special button named 'Copy' will appear, and allow users to copy the provided
		message to the clipboard.
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
	[cmdletbinding()]
	param(
		[ValidateSet($null, 'Information', 'Warning', 'Error', 'Question')]
		[string]$Icon,
		[string]$Title,
		[string]$Image,
		[string[]]$Message,
		[AnyBox.Prompt[]]$Prompt,
		[string[]]$Buttons,
		[string]$CancelButton,
		[string]$DefaultButton,
		[switch]$ShowCopyButton,
		[ValidateScript({$_ -gt 0})]
		[uint16]$ButtonRows = 1,
		[string[]]$Comment,
		[ValidateSet('Left', 'Center')]
		[string]$ContentAlignment = 'Center',

		[ValidateNotNullOrEmpty()]
		[string]$FontFamily = 'Segoe UI',
		[ValidateScript({$_ -gt 0})]
		[uint16]$FontSize = 13,
		[ValidateNotNullOrEmpty()]
		[string]$FontColor = 'Black',
		[string]$BackgroundColor,
		[ValidateSet('None', 'SingleBorderWindow', 'ThreeDBorderWindow', 'ToolWindow')]
		[System.Windows.WindowStyle]$WindowStyle = 'SingleBorderWindow',
		[ValidateSet('NoResize', 'CanMinimize', 'CanResize', 'CanResizeWithGrip')]
		[System.Windows.ResizeMode]$ResizeMode = 'CanMinimize',
		[switch]$NoResize,
		[ValidateScript({$_ -gt 0})]
		[uint16]$MinHeight = 50,
		[ValidateScript({$_ -gt 0})]
		[uint16]$MinWidth = 50,
		[switch]$Topmost,
		[switch]$HideTaskbarIcon,
		[uint32]$Timeout,
		[switch]$Countdown,
		[System.Windows.Window]$ParentWindow = $null,

		[array]$GridData,
		[switch]$GridAsList,
		[ValidateSet('SingleCell', 'MultiCell', 'SingleRow', 'MultiRow')]
		[string]$SelectionMode = 'SingleCell',
		[switch]$HideGridSearch
	)

	if ($NoResize -or ($HideTaskbarIcon -and $ResizeMode -ne 'NoResize' -and @('None', 'ToolWindow') -notcontains $WindowStyle)) {
		# No minimize button
		$ResizeMode = 'NoResize'
	}

	$form = @{'Result'=@{}} # [hashtable]::Synchronized(@{ 'Result' = @{})

	[string[]]$action_btns = @()

	if ($GridData -and -not $HideGridSearch) {
		$action_btns += @('Explore', 'Save')
	}

	if ($ShowCopyButton -and $Message) {
		$action_btns += 'Copy'
	}

	if ($Buttons -or $action_btns) {
		if (-not $Buttons) {
			$Buttons = @($action_btns)
		}
		else {
			$Buttons | ForEach-Object { $form.Result.Add($_, $false) }

			if ($action_btns) {
				[System.Collections.ArrayList]$Buttons = [System.Collections.ArrayList]$Buttons
				$Buttons.InsertRange(1, $action_btns)
			}
			$Buttons = $Buttons | Select-Object -Unique
		}
	}

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

			<StackPanel Name="highStack" Grid.Column="0" Grid.Row="0" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0"/>

			<DataGrid Name='data_grid' Grid.Column="0" Grid.Row="1" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0" Visibility="Collapsed"/>

			<StackPanel Name="lowStack" Grid.Column="0" Grid.Row="2" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="0"/>
		</Grid>
	</Border>
</Window>
"@

	$form.Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
	$xaml.SelectNodes('//*[@Name]').Name | ForEach-Object { $form.Add($_, $form.Window.FindName($_)) }
	$xaml = $null

	if ($WindowStyle -eq 'None') {
		$form.Window.BorderBrush = 'Black'
		$form.Window.BorderThickness = '1'
	}

	if ($Title) { $form.Window.Title = $Title }
	if ($FontColor) { $form.Window.Foreground = $FontColor }
	if ($BackgroundColor) {
		$form.Window.Background = $BackgroundColor
	}

	if ($Icon) {
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
		WindowStyle = 'None'
		ResizeMode = 'NoResize'
		NoResize = $true
		MinHeight = 25
		MinWidth = 25
		HideTaskbarIcon = $true
		Topmost = $true
		Buttons = 'OK'
		DefaultButton = 'OK'
		ParentWindow = $form.Window
	}

	if ($ParentWindow) {
		$form.Window.Owner = $ParentWindow
		$form.Window.WindowStartupLocation = 'CenterOwner'
		$form.Window.Topmost = $false
	}
	else {
		$form.Window.Owner = $null
		$form.Window.WindowStartupLocation = 'CenterScreen'
	}

	if ($Image) {
		$img = New-Object System.Windows.Controls.Image

		if ($Image.Length -gt 260 -and $Image.Length % 4 -eq 0) {
			# 260 is max path-length and base64 is a multiple of 4.
			$img.Source = $bmp | ConvertTo-BitmapImage
		}
		elseif (Test-Path $Image) {
			$img.Source = $Image
		}
		elseif (Test-Path "$PSScriptRoot\$Image") {
			$img.Source = "$PSScriptRoot\$Image"
		}

		if (-not $img.Source) {
			$img = $null
			$Image = $null
		}
		else {
			$img.Margin = "0, 10, 0, 0"
			$img.MaxWidth = $img.Source.Width
			$img.MaxHeight = $img.Source.Height
			$img.HorizontalAlignment = 'Center'
			$img.VerticalAlignment = 'Center'
			$form.highStack.AddChild($img)
		}
	}

	function New-TextBlock ($text, $name) {
		if ($text -and -not [string]::IsNullOrEmpty($text.Trim())) {
			$txtBlk = New-Object System.Windows.Controls.TextBlock
			$txtBlk.Text = $text
			$txtBlk.FontFamily = $FontFamily
			$txtBlk.TextWrapping = 'Wrap'
			$txtBlk.FontSize = $FontSize
			$txtBlk.Margin = "0, 10, 0, 0"
			$txtBlk.VerticalAlignment = 'Center'
			$txtBlk.HorizontalAlignment = $ContentAlignment
			$txtBlk.TextAlignment = $ContentAlignment

			if ($name) {
				$txtBlk.Name = $name
				$form.Add($txtBlk.Name, $txtBlk)
			}

			return $txtBlk
		}

		return $null
	}

	# Add message textblocks.
	if (($txtMsg = New-TextBlock -text $($Message -join [environment]::NewLine) -name 'txt_Message')) {
		$form.highStack.AddChild($txtMsg)
	}

	# Add prompt-message textblocks and input textboxes.
	for ($i = 0; $i -lt $Prompt.Length; $i++) {

		$inPanel = $null

		if ($Prompt[$i].MessagePosition -eq [AnyBox.MessagePosition]::Left) {
			$inPanel = New-Object System.Windows.Controls.DockPanel
			$inPanel.LastChildFill = $true
		}

		if ($Prompt[$i].ValidateSet)
		{	# Combo box
			if (($inPrmpt = New-TextBlock $Prompt[$i].Message)) {
				if ($Prompt[$i].MessagePosition -eq [AnyBox.MessagePosition]::Left) {
					$inPrmpt.Margin = "0, 10, 5, 0"
					$inPanel.AddChild($inPrmpt)
				}
				else {
					$form.highStack.AddChild($inPrmpt)
				}
			}
			# Combo box
			$inBox = New-Object System.Windows.Controls.ComboBox
			$inBox.Name = "Input_$i"
			$inBox.MinHeight = 25
			$inBox.Margin = "0, 10, 0, 0"
			$inBox.IsReadOnly = $true
			$inBox.HorizontalAlignment = $ContentAlignment
			$inBox.HorizontalContentAlignment = $ContentAlignment
			$inBox.VerticalAlignment = 'Center'
			$inBox.VerticalContentAlignment = 'Center'
			$inBox.ItemsSource = $Prompt[$i].ValidateSet
			if ($Prompt[$i].DefaultValue) {
				$inBox.SelectedItem = $Prompt[$i].DefaultValue
			}
			else {
				$inBox.SelectedIndex = 0
			}
		}
		elseif ($Prompt[$i].InputType -eq [AnyBox.InputType]::Checkbox)
		{
			# Check box
			$inBox = New-Object System.Windows.Controls.CheckBox
			$inBox.Name = "Input_$i"
			$inBox.Margin = "0, 10, 0, 0"
			$inBox.Content = $Prompt[$i].Message
			$inBox.IsChecked = $($Prompt[$i].DefaultValue -eq [bool]::TrueString)
			$inBox.HorizontalAlignment = $ContentAlignment
			$inBox.HorizontalContentAlignment = 'Left'
		}
		elseif ($Prompt[$i].InputType -eq [AnyBox.InputType]::Password)
		{
			if (($inPrmpt = New-TextBlock $Prompt[$i].Message)) {
				if ($Prompt[$i].MessagePosition -eq [AnyBox.MessagePosition]::Left) {
					$inPrmpt.Margin = "0, 10, 5, 0"
					$inPanel.AddChild($inPrmpt)
				}
				else {
					$form.highStack.AddChild($inPrmpt)
				}
			}
			# Password box
			$inBox = New-Object System.Windows.Controls.PasswordBox
			$inBox.MinHeight = 25
			$inBox.Name = "Input_$i"
			$inBox.Padding = '3, 0, 0, 0'
			$inBox.Margin = "0, 10, 0, 0"
			$inBox.HorizontalAlignment = 'Stretch'
			$inBox.HorizontalContentAlignment = $ContentAlignment
			$inBox.VerticalContentAlignment = 'Center'
			$inBox.VerticalAlignment = 'Center'
			$inBox.FontStyle = 'Normal'
			$inBox.FontSize = $FontSize
			$inBox.Background = 'WhiteSmoke'
		}
		elseif ($Prompt[$i].InputType -eq [AnyBox.InputType]::Date)
		{	# Date picker
			if (($inPrmpt = New-TextBlock $Prompt[$i].Message)) {
				if ($Prompt[$i].MessagePosition -eq [AnyBox.MessagePosition]::Left) {
					$inPrmpt.Margin = "0, 10, 5, 0"
					$inPanel.AddChild($inPrmpt)
				}
				else {
					$form.highStack.AddChild($inPrmpt)
				}
			}

			$inBox = New-Object System.Windows.Controls.DatePicker
			$inBox.Name = "Input_$i"
			$inBox.Margin = "0, 10, 0, 0"
			$inBox.HorizontalAlignment = $ContentAlignment
			$inBox.HorizontalContentAlignment = $ContentAlignment
			$inBox.VerticalAlignment = 'Center'
			$inBox.DisplayDate = [datetime]::Today
			$inBox.DisplayDateStart = [datetime]::MinValue
			$inBox.DisplayDateEnd = [datetime]::MaxValue
			$inBox.SelectedDateFormat = [System.Windows.Controls.DatePickerFormat]::Short
			$inBox.Text = $Prompt[$i].DefaultValue
			$inBox.Background = 'WhiteSmoke'
		}
		elseif ($Prompt[$i].InputType -eq [AnyBox.InputType]::Link)
		{
			# Hyperlink
			$inBox = New-TextBlock -text $Prompt[$i].Message
			$inBox.Name = "Input_$i"
			$inBox.FontSize = $FontSize
			$inBox.Foreground = 'Blue'
			$inBox.TextDecorations = 'Underline'
			$inBox.Cursor = 'Hand'
			$inBox.Tooltip = $Prompt[$i].DefaultValue
			[string]$onClick = "`$_.Source.Foreground = 'Navy'; "
			if ($Prompt[$i].DefaultValue) {
				$onClick += "start '$($Prompt[$i].DefaultValue)'"
			}
			else {
				$onClick += "start '$($Prompt[$i].Message)'"
			}
			$inBox.add_MouseLeftButtonDown([scriptblock]::Create($onClick))
		}
		else
		{	# Text box
			if (($inPrmpt = New-TextBlock $Prompt[$i].Message)) {
				if ($Prompt[$i].MessagePosition -eq [AnyBox.MessagePosition]::Left) {
					$inPrmpt.Margin = "0, 10, 5, 0"
					$inPanel.AddChild($inPrmpt)
				}
				else {
					$form.highStack.AddChild($inPrmpt)
				}
			}

			$inBox = New-Object System.Windows.Controls.TextBox
			$inBox.Name = "Input_$i"
			$inBox.MinHeight = 25
			$inBox.MinWidth = 50
			$inBox.Padding = '3, 0, 0, 0'
			$inBox.Margin = "0, 10, 0, 0"
			$inBox.HorizontalAlignment = 'Stretch'
			$inBox.HorizontalContentAlignment = $ContentAlignment
			$inBox.TextAlignment = $ContentAlignment
			$inBox.VerticalContentAlignment = 'Center'
			$inBox.VerticalAlignment = 'Center'
			$inBox.AcceptsTab = $false
			$inBox.FontSize = $FontSize
			$inBox.TextWrapping = 'NoWrap'
			$inBox.Background = 'WhiteSmoke'

			if ($Prompt[$i].DefaultValue -ne $null) {
				$inBox.Text = $Prompt[$i].DefaultValue
			}

			if ($Prompt[$i].LineHeight -gt 1)
			{
				$inBox.AcceptsReturn = $true
				$inBox.TextWrapping = 'Wrap'
				$inBox.MinWidth = 75
				$inBox.MaxHeight = 25 * $Prompt[$i].LineHeight
				$inBox.Height = $inBox.MaxHeight
			}
			else
			{
				$inBox.MaxHeight = 25 * @($Prompt[$i].DefaultValue -split "`n").Count
				$inBox.Height = $inBox.MaxHeight
			}

			$inBox.add_GotFocus({$_.Source.SelectAll()})

			##############################################

			if ($Prompt[$i].InputType -eq [AnyBox.InputType]::FileOpen -or $Prompt[$i].InputType -eq [AnyBox.InputType]::FileSave) {
				$filePanel = New-Object System.Windows.Controls.DockPanel
				$filePanel.LastChildFill = $true

				$fileBtn = New-Object System.Windows.Controls.Button
				$fileBtn.Name = "btn_Input_$i"
				$fileBtn.Height = 25
				$fileBtn.Width = 25
				$fileBtn.Margin = "0, 5, 0, 0"

				$inBox.Margin = "0, 5, 0, 0"
				$inBox.Padding = "0, 0, $($fileBtn.Width.ToString()), 0"

				$fileBtn.ToolTip = 'Browse'
				$fileBtn.Content = '...'

				if ($Prompt[$i].InputType -eq [AnyBox.InputType]::FileOpen)
				{
					$fileBtn.add_Click({
						[string]$inBoxName = $_.Source.Name.Replace('btn_','')
						$opnWin = New-Object Microsoft.Win32.OpenFileDialog
						$opnWin.Title = 'Open File'
						$opnWin.CheckFileExists = $true
						if ($opnWin.ShowDialog()) {
							if (-not (Test-Path $opnWin.FileName)) {
								Show-AnyBox @childWinParams -Message 'File not found.'
							}
							else {
								$form[$inBoxName].Text = $opnWin.FileName
							}
						}
					})
				}
				else
				{ # if ($Prompt[$i].InputType -eq [AnyBox.InputType]::FileSave) {
					$fileBtn.add_Click({
						[string]$inBoxName = $_.Source.Name.Replace('btn_','')
						$savWin = New-Object Microsoft.Win32.SaveFileDialog
						$savWin.Title = 'Save File'
						$savWin.OverwritePrompt = $false
						if ($savWin.ShowDialog() -and $savWin.FileName) {
							$form[$inBoxName].Text = $savWin.FileName
						}
					})
				}

				$filePanel.AddChild($fileBtn)
				$filePanel.AddChild($inBox)
				
				$form.Add($fileBtn.Name, $fileBtn)
			}

			##############################################

		}

		$inBox.FontSize = $FontSize

		if ($Prompt[$i].ReadOnly) {
			$inBox.IsReadOnly = $true
			$inBox.IsEnabled = $false
		}

		if ($filePanel) {
			if ($inPanel) {
				$inPanel.AddChild($filePanel)
				$form.highStack.AddChild($inPanel)
			}
			else {
				$form.highStack.AddChild($filePanel)
			}
			$filePanel = $null
		}
		elseif ($inPanel) {
			$inPanel.AddChild($inBox)
			$form.highStack.AddChild($inPanel)
		}
		else {
			$form.highStack.AddChild($inBox)
		}

		$form.Add($inBox.Name, $inBox)

		$inBox = $null
	}

	# Add comment textblocks.
	if (($txtMsg = New-TextBlock -text $($Comment -join [environment]::NewLine) -name 'txt_Explain')) {
		$txtMsg.FontStyle = 'Italic'
		$txtMsg.FontWeight = 'Normal'
		$form.highStack.AddChild($txtMsg)
	}

	if ($GridData)
	{
		# $dataGrid = New-Object System.Windows.Controls.DataGrid
		# $dataGrid.Name = 'data_grid'

		$dataGrid = $form['data_grid']

		if ($GridAsList) {
			$GridData = $GridData | ConvertTo-Long
		}

		$dataGrid.ItemsSource = $GridData

		$dataGrid.Visibility = 'Visible'

		if ($SelectionMode -like 'Multi*') {
			$dataGrid.SelectionMode = 'Extended'
		}
		else {
			$dataGrid.SelectionMode = 'Single'
		}

		if ($SelectionMode -like '*Row') {
			$dataGrid.SelectionUnit = 'FullRow'
		}
		else {
			$dataGrid.SelectionUnit = 'Cell'
		}

		$dataGrid.ClipboardCopyMode = 'ExcludeHeader'
		$dataGrid.Margin = "0, 10, 0, 0"
		$dataGrid.IsReadOnly = $true
		$dataGrid.AutoGenerateColumns = $true
		$dataGrid.VerticalScrollBarVisibility = 'Auto'
		$dataGrid.HorizontalScrollBarVisibility = 'Auto'
		$dataGrid.HorizontalAlignment = 'Stretch'
		$dataGrid.HorizontalContentAlignment = 'Stretch'
		$dataGrid.VerticalContentAlignment = 'Stretch'
		$dataGrid.VerticalAlignment = 'Stretch'
		# $dataGrid.MaxHeight = [System.Windows.SystemParameters]::WorkArea.Height - 250
		# $dataGrid.MaxWidth = $form.Window.MaxWidth - 20 # 10px border on each side.
		$dataGrid.HeadersVisibility = 'Column'
		$dataGrid.AlternatingRowBackground = 'WhiteSmoke'
		$dataGrid.CanUserSortColumns = $true
		$dataGrid.CanUserResizeColumns = $true
		$dataGrid.CanUserResizeRows = $false
		$dataGrid.CanUserReorderColumns = $false
		$dataGrid.CanUserDeleteRows = $true
		$dataGrid.GridLinesVisibility = 'All'
		$dataGrid.FontSize = 12

		if (-not $HideGridSearch) {
			$gridMsg = New-TextBlock -text $('{0} Results' -f $GridData.Count) -name 'txt_Grid'
			$form.highStack.AddChild($gridMsg)

			[scriptblock]$filterGrid = {
				if (-not $form.filterText.Text) {
					$form.data_grid.ItemsSource = $GridData
					$form['txt_Grid'].Text = '{0} Results' -f $GridData.Count
				}
				elseif ($form.filterBy.SelectedItem) {
					[string]$filterBy = $form.filterBy.SelectedItem.ToString()
					[string]$filter = $form.filterText.Text

					switch ($form.filterMatch.SelectedItem)
					{
						'contains' {
							$filter = [System.Text.RegularExpressions.Regex]::Escape($filter)
							$form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -match $filter)
							break
						}
						'not contains' {
							$filter = [System.Text.RegularExpressions.Regex]::Escape($filter)
							$form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -notmatch $filter)
							break
						}
						'starts with' {
							$form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -like "$filter*")
							break
						}
						'ends with' {
							$form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -like "*$filter")
							break
						}
						'equals' {
							$form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -eq $filter)
							break
						}
						'not equals' {
							$form.data_grid.ItemsSource = @($GridData | Where-Object $filterBy -ne $filter)
							break
						}
						Default {
							$form.data_grid.ItemsSource = $GridData
						}
					}

					$form['txt_Grid'].Text = '{0} / {1} Results' -f ([Collections.Generic.IEnumerable``1[object]]$form.data_grid.ItemsSource).Count, $GridData.Count
				}
			}
			
			$fltrBy = New-Object System.Windows.Controls.ComboBox
			$fltrBy.Name = 'filterBy'
			$fltrBy.FontSize = $FontSize
			$fltrBy.Margin = "0, 10, 0, 0"
			$fltrBy.MinHeight = 25
			$fltrBy.IsReadOnly = $true
			$fltrBy.HorizontalAlignment = 'Left'
			$fltrBy.HorizontalContentAlignment = 'Left'
			$fltrBy.VerticalAlignment = 'Center'
			$fltrBy.VerticalContentAlignment = 'Center'
			$fltrBy.add_SelectionChanged({& $filterGrid})

			$fltrMatch = New-Object System.Windows.Controls.ComboBox
			$fltrMatch.Name = 'filterMatch'
			$fltrMatch.FontSize = $FontSize
			$fltrMatch.Margin = "0, 10, 0, 0"
			$fltrMatch.MinHeight = 25
			$fltrMatch.IsReadOnly = $true
			$fltrMatch.HorizontalAlignment = 'Left'
			$fltrMatch.HorizontalContentAlignment = 'Left'
			$fltrMatch.VerticalAlignment = 'Center'
			$fltrMatch.VerticalContentAlignment = 'Center'
			$fltrMatch.ItemsSource = @('contains', 'not contains', 'starts with', 'ends with', 'equals', 'not equals')
			$fltrMatch.SelectedIndex = 0
			$fltrMatch.add_SelectionChanged({& $filterGrid})

			$fltrBox = New-Object System.Windows.Controls.TextBox
			$fltrBox.Name = 'filterText'
			$fltrBox.Padding = '3, 0, 0, 0'
			$fltrBox.Margin = "0, 10, 0, 0"
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
			$fltrBox.add_TextChanged({& $filterGrid})
			$fltrBox.add_GotFocus({$_.Source.SelectAll()})
			
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
		
		# $form.highStack.AddChild($dataGrid)
		# $form.Add($dataGrid.Name, $dataGrid)
	}

	# Add comment textblocks.
	if (($txtMsg = New-TextBlock -text $($Comment -join [environment]::NewLine) -name 'txt_Explain')) {
		$txtMsg.FontStyle = 'Italic'
		$txtMsg.FontWeight = 'Normal'
		$form.highStack.AddChild($txtMsg)
	}
	
	if ($Timeout -and $Timeout -gt 0 -and $Countdown) {
		# Create countdown textblock.
		$txtTime = New-TextBlock '---'
		$txtTime.Name = 'txt_Countdown'
		$form.highStack.AddChild($txtTime)
		$form.Add($txtTime.Name, $txtTime)
	}

	if ($Buttons.Count -gt 0) {
		[scriptblock]$validate = {
			[bool]$valid = $true
			for ($i = 0; $i -lt $Prompt.Length; $i++) {
				if ($form["Input_$i"] -is [System.Windows.Controls.TextBox]) {
					[string]$msg = $null

					if ($Prompt[$i].ValidateNotEmpty -and -not $form["Input_$i"].Text) {
						if ($Prompt[$i].Message) {
							$msg = "Please provide input for '{0}'" -f $Prompt[$i].Message.TrimEnd(':')
						}
						else {
							$msg = "Please provide input for required fields."
						}
					}
					elseif ($Prompt[$i].ValidateScript -and -not ($form["Input_$i"].Text | ForEach-Object -Process $Prompt[$i].ValidateScript)) {
						if ($Prompt[$i].Message) {
							$msg = "Invalid input for '{0}'" -f $Prompt[$i].Message.TrimEnd(':')
						}
						else {
							$msg = "Invalid input provided."
						}
					}

					if ($msg) {
						$null = Show-AnyBox @childWinParams -Message $msg
						$null = $form["Input_$i"].Focus()
						$valid = $false
						break
					}
				}
				elseif ($Prompt[$i].ValidateNotEmpty) {
					if ($form["Input_$i"] -is [System.Windows.Controls.PasswordBox] -and $form["Input_$i"].SecurePassword.Length -eq 0) {
						$null = Show-AnyBox @childWinParams -Message "Please provide a password."
						$null = $form["Input_$i"].Focus()
						$valid = $false
						break
					}
					elseif ($form["Input_$i"] -is [System.Windows.Controls.DatePicker] -and -not $form["Input_$i"].Text) {
						$null = Show-AnyBox @childWinParams -Message "Please select a date."
						$null = $form["Input_$i"].Focus()
						$valid = $false
						break
					}
					elseif ($form["Input_$i"] -is [System.Windows.Controls.TextBlock] -and $form["Input_$i"].Foreground.Color -ne '#FF000080') { # -ne Navy
						$null = Show-AnyBox @childWinParams -Message $("Please click the link '{0}'." -f $form["Input_$i"].Text)
						$valid = $false
						break
					}
				}
			}
			$valid
		}

		[int]$btn_per_row = [math]::Ceiling($Buttons.Count / ([double]$ButtonRows))

		[uint16]$c = 0

		1..$ButtonRows | foreach {
			# Create a horizontal stack-panel for buttons and populate it.
			$btnStack = New-Object System.Windows.Controls.StackPanel
			$btnStack.Orientation = 'Horizontal'
			$btnStack.HorizontalAlignment = 'Center'
			$btnStack.Margin = "0, 10, 0, 0"

			for ($i = 0; $i -lt $btn_per_row -and $c -lt $Buttons.Count; $i++) {
				$btn = New-Object System.Windows.Controls.Button
				$btn.MinHeight = 35
				$btn.MinWidth = 75
				$btn.FontSize = $FontSize
				$btn.Margin = "10, 0, 10, 0"
				$btn.VerticalContentAlignment = 'Center'
				$btn.HorizontalContentAlignment = 'Center'
				$btn.Content = '_' + $Buttons[$c]

				if ($Buttons[$c] -eq 'Explore') {
					$btn.ToolTip = 'Explore data in a separate grid window.'
					$btn.add_Click({ $form.data_grid.Items | Select-Object * | Out-GridView -Title ' ' })
				}
				elseif ($Buttons[$c] -eq 'Copy') {
					$btn.ToolTip = 'Copy the message to the clipboard.'
					$btn.add_Click({
						if ($form.txt_Message.Text) {
							try {
								[System.Windows.Clipboard]::SetDataObject($form.txt_Message.Text, $true)
							}
							catch {
								$null = Show-AnyBox @childWinParams -Message "Error accessing clipboard"
							}
						}
					})
				}
				elseif ($Buttons[$c] -eq 'Save') {
					$btn.ToolTip = 'Save data to a CSV file.'
					$btn.add_Click({
						try {
							$savWin = New-Object Microsoft.Win32.SaveFileDialog
							$savWin.InitialDirectory = "$env:USERPROFILE\Desktop"
							$savWin.FileName = 'data.csv'
							$savWin.Filter = 'CSV File (*.csv)|*.csv'
							$savWin.OverwritePrompt = $true
							if ($savWin.ShowDialog()) {
								$form.data_grid.Items | Export-Csv -Path $savWin.FileName -NoTypeInformation -Encoding ASCII -Force
								Start-Process -FilePath $savWin.FileName
							}
						}
						catch {
							$null = Show-AnyBox @childWinParams -Message $_.Exception.Message
						}
					})
				}
				else {
					if ($CancelButton -eq $Buttons[$c]) {
						$btn.add_Click({
							[string]$btn_name = $_.Source.Content.TrimStart('_')
							$form.Result[$btn_name] = $true; $form.Window.Close()
						})
					}
					else {
						$btn.add_Click({ if ($(& $validate)) {
							[string]$btn_name = $_.Source.Content.TrimStart('_')
							$form.Result[$btn_name] = $true; $form.Window.Close()
						}})
					}

					if (-not $NoKeyNav) {
						if ($DefaultButton -eq $Buttons[$c]) {
							$btn.IsDefault = $true
						}
						elseif($CancelButton -eq $Buttons[$c]) {
							$btn.IsCancel = $true
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
		$_.Source.Opacity = 0.0

		if ($form.Window.Owner) {
			$form.Window.Owner.Opacity = 0.4
		}

		if ($GridData) {
			if (-not $HideGridSearch) {
				$form.filterBy.ItemsSource = @($form.data_grid.Columns.Header)
				$form.filterBy.SelectedIndex = 0
			}
			
			$form.data_grid.Columns | ForEach-Object {
				$_.CanUserSort = $true
				$_.SortMemberPath = $_.Header.ToString()
				$_.SortDirection = "Ascending"
			}
		}
	
		if ($Prompt) {
			[bool]$focused = $false
			for ($i = 0; $i -lt $Prompt.Length; $i++) {
				if (($form["Input_$i"] -is [System.Windows.Controls.TextBox] -and [string]::IsNullOrEmpty($form["input_$i"].Text)) -or `
						($form["Input_$i"] -is [System.Windows.Controls.PasswordBox] -and $form["input_$i"].SecurePassword.Length -eq 0)) {
					$null = $form["Input_$i"].Focus()
					$form["Input_$i"].SelectAll()
					$focused = $true
					break
				}
			}
			if (-not $focused -and $form["Input_0"] -is [System.Windows.Controls.TextBox]) {
				$null = $form["Input_0"].Focus()
				$form["Input_0"].SelectAll()
			}
		}
	})

	$form.Window.add_ContentRendered({
		$form.Window.SizeToContent = 'Manual'

		$form.Window.Opacity = 1.0

		if ($Timeout -and $Timeout -gt 0)
		{
			$form.Result.Add('TimedOut', $false)

			$timer = New-Object System.Windows.Threading.DispatcherTimer
			$timer.Interval = [timespan]::FromSeconds(1.0)
			[datetime]$script:end_at = [datetime]::Now.AddSeconds($Timeout)

			$timer.Add_Tick({
				if ([datetime]::Now -lt $script:end_at) {
					if ($Countdown) { $form.txt_Countdown.Text = $script:end_at.Subtract([datetime]::now).ToString('hh\:mm\:ss') }
				}
				else {
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
		if ($Timeout -gt 0 -and $form['Timer'].IsEnabled) {
			$form['Timer'].Stop()
			$form['Timer'] = $null
		}

		$form.GetEnumerator() | ForEach-Object {
			if ($_.Name -match 'Input_\d+') {
				if ($_.Value -is [System.Windows.Controls.TextBox]) {
					$form.Result.Add($_.Name, $_.Value.Text)
				}
				elseif ($_.Value -is [System.Windows.Controls.TextBlock]) {
					$form.Result.Add($_.Name, $($_.Value.Foreground.Color -eq '#FF000080')) # -eq Navy
				}
				elseif ($_.Value -is [System.Windows.Controls.PasswordBox]) {
					$form.Result.Add($_.Name, $_.Value.SecurePassword)
				}
				elseif ($_.Value -is [System.Windows.Controls.CheckBox]) {
					$form.Result.Add($_.Name, $_.Value.IsChecked)
				}
				elseif ($_.Value -is [System.Windows.Controls.ComboBox]) {
					$form.Result.Add($_.Name, $_.Value.SelectedItem)
				}
				elseif ($_.Value -is [System.Windows.Controls.DatePicker]) {
					$form.Result.Add($_.Name, $_.Value.Text)
				}
			}
			elseif ($_.Name -eq 'data_grid' -and ($form['data_grid'].SelectedCells.Count -gt 0 -or $form['data_grid'].SelectedItems.Count -gt 0)) {
				$selection = $null

				switch ($SelectionMode)
				{
					'SingleCell' {
						[string]$selection = $form['data_grid'].SelectedCells[0].Item.ToString()
					}
					<#'MultiCell' {
						[string[]]$selection = @($form.data_grid.SelectedCells.Item.Value)
					}#>
					'SingleRow' {
						[psobject]$selection = $form['data_grid'].SelectedItem
					}
					'MultiRow' {
						[psobject[]]$selection = @($form['data_grid'].SelectedItems)
					}
				}

				$form.Result.Add('grid_select', $selection)
			}
		}

		if ($form.Window.Owner) {
			$form.Window.Owner.Opacity = 1.0
			$form.Window.Owner.Activate()
		}
	})

	$null = $form.Window.ShowDialog()

	$form.Result
	
	$form = $null
}
