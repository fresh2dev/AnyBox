function New-TextBlock
{
    param(
        [ref]$RefForm,
        $Text,
        $Name,
        $FontFamily,
        $FontSize,
        $FontColor,
        $ContentAlignment,
        $Margin = '0, 10, 0, 0'
    )

    $txtBlk = $null

    if ($text -and (-not [string]::IsNullOrEmpty($text.Trim())))
    {
        $txtBlk = New-Object System.Windows.Controls.TextBlock
        $txtBlk.Text = $Text
        $txtBlk.FontFamily = $FontFamily
        $txtBlk.FontSize = $FontSize
        $txtBlk.Foreground = $FontColor
        $txtBlk.TextWrapping = 'Wrap'
        $txtBlk.VerticalAlignment = 'Center'
        $txtBlk.HorizontalAlignment = $ContentAlignment
        $txtBlk.TextAlignment = $ContentAlignment
        $txtBlk.Margin = $Margin

        if ($name)
        {
            $txtBlk.Name = $Name
            $RefForm.Value.Add($txtBlk.Name, $txtBlk)
        }
    }

    return $txtBlk
}
