function New-TextBlock {
	Param(
		[ref]$RefForm,
		$text,
		$name,
		$FontFamily,
		$FontSize,
		$FontColor,
		$margin = "0, 10, 0, 0",
		$ContentAlignment
	)

	if ($text -and (-not [string]::IsNullOrEmpty($text.Trim()))) {
		$txtBlk = New-Object System.Windows.Controls.TextBlock
		$txtBlk.Text = $text
		$txtBlk.FontFamily = $FontFamily
		$txtBlk.FontSize = $FontSize
		$txtBlk.Foreground = $FontColor
		$txtBlk.TextWrapping = 'Wrap'
		$txtBlk.VerticalAlignment = 'Center'
		$txtBlk.HorizontalAlignment = $ContentAlignment
		$txtBlk.TextAlignment = $ContentAlignment

		if ($name) {
			$txtBlk.Name = $name
			$RefForm.Value.Add($txtBlk.Name, $txtBlk)
		}

		return $txtBlk
	}

	return $null
}