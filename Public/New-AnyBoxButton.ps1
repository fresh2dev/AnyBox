function New-AnyBoxButton
{
	[cmdletbinding()]
	param(
		[ValidateNotNull()]
		[string]$Text,
		[string]$Name,
		[string]$ToolTip,
		[switch]$IsCancel,
		[switch]$IsDefault,
		[System.Management.Automation.ScriptBlock]$OnClick
	)

	if ($Name -and $Name -notmatch '^[A-Za-z_]+[A-Za-z0-9_]*$') {
		Write-Warning "Name must start with a letter or the underscore character (_), and must contain only letters, digits, or underscores."
		$Name = $null
	}

	$b = New-Object AnyBox.Button

	$b.Name = $Name
	$b.Text = $Text
	$b.ToolTip = $ToolTip
	$b.IsCancel = $IsCancel -as [bool]
	$b.IsDefault = $IsDefault -as [bool]
	$b.OnClick = $OnClick

	return($b)
}

Set-Alias -Name 'New-Button' -Value 'New-AnyBoxButton' -Description 'New-AnyBoxButton' -Scope 'Global'