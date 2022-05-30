function New-AnyBoxButton
{
    [cmdletbinding()]
    param(
        [string]$Text,
        [string]$Name,
        [string]$ToolTip,
        [switch]$IsCancel,
        [switch]$IsDefault,
        [System.Management.Automation.ScriptBlock]$OnClick,
        [ValidateSet($null, 'ExploreGrid', 'SaveGrid', 'CopyMessage')]
        [string]$Template
    )

    if ($Name -and $Name -notmatch '^[A-Za-z_]+[A-Za-z0-9_]*$')
    {
        Write-Warning "Name ($Name) must start with a letter or the underscore character (_), and must contain only letters, digits, or underscores."
        $Name = $null
    }

    $b = New-Object AnyBox.Button

    if ($Template)
    {
        $b.Name = $Template
        switch ($Template)
        {
            'ExploreGrid'
            {
                $b.Text = 'Explore'
                $b.ToolTip = 'Explore data in a separate grid window.'
                $b.OnClick = {
                    if ($form['data_grid'])
                    {
                        $form['data_grid'].Items | Select-Object * | Out-GridView -Title 'Data'
                    }
                }
                break
            }
            'SaveGrid'
            {
                $b.Text = 'Save'
                $b.ToolTip = 'Save data to a CSV file.'
                $b.OnClick = {
                    if ($form['data_grid'])
                    {
                        try
                        {
                            $savWin = New-Object Microsoft.Win32.SaveFileDialog
                            $savWin.InitialDirectory = "$env:USERPROFILE\Desktop"
                            $savWin.FileName = 'data.csv'
                            $savWin.Filter = 'CSV File (*.csv)|*.csv'
                            $savWin.OverwritePrompt = $true
                            if ($savWin.ShowDialog())
                            {
                                $form['data_grid'].Items | Export-Csv -Path $savWin.FileName -NoTypeInformation -Encoding ASCII -Force
                                Start-Process -FilePath $savWin.FileName
                            }
                        }
                        catch
                        {
                            $null = Show-AnyBox @childWinParams -Message $_.Exception.Message -Buttons 'OK'
                        }
                    }
                }
                break
            }
            'CopyMessage'
            {
                $b.Text = 'Copy'
                $b.ToolTip = 'Copy message to clipboard'
                $b.OnClick = {
                    try
                    {
                        if (-not $form['Message'].Text)
                        {
                            $null = Show-AnyBox @childWinParams -Message 'There is no message to copy.' -Buttons 'OK'
                        }
                        else
                        {
                            [System.Windows.Clipboard]::SetDataObject($form['Message'].Text, $true)
                            $null = Show-AnyBox @childWinParams -Message 'Successfully copied message to clipboard.' -Buttons 'OK'
                        }
                    }
                    catch
                    {
                        $err_msg = 'Error accessing clipboard:{0}{1}' -f [Environment]::NewLine, $_.Exception.Message
                        $null = Show-AnyBox @childWinParams -Message $err_msg -Buttons 'OK'
                    }
                }
                break
            }
        }
    }

    if ($Name)
    {
        $b.Name = $Name 
    }
    if ($Text)
    {
        $b.Text = $Text 
    }
    if ($ToolTip)
    {
        $b.ToolTip = $ToolTip 
    }
    if ($OnClick)
    {
        $b.OnClick = $OnClick 
    }
    $b.IsCancel = $IsCancel -as [bool]
    $b.IsDefault = $IsDefault -as [bool]

    return($b)
}

Set-Alias -Name 'New-Button' -Value 'New-AnyBoxButton' -Description 'New-AnyBoxButton' -Scope 'Global'