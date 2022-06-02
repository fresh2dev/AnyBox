[string[]]$ReferencedAssemblies = $null

if ($PSVersionTable.PSVersion.Major -lt 7)
{
    $ReferencedAssemblies = 'System.Management.Automation.dll', 'System.Drawing.dll', 'WPF\PresentationFramework.dll', 'WPF\PresentationCore.dll', 'WPF\WindowsBase.dll', 'System.Xaml.dll'
}
else  # if ($PSVersionTable.PSVersion.Major -ge 7)
{
    $ReferencedAssemblies = 'System.Management.Automation.dll', 'System.Drawing.dll', 'PresentationFramework.dll', 'PresentationCore.dll', 'WindowsBase.dll', 'System.Xaml.dll'
    if ($PSVersionTable.PSVersion.Minor -gt 0)
    {
        $ReferencedAssemblies = $ReferencedAssemblies | Foreach-Object { Join-Path $PSHOME $_ }
    }
}

Add-Type -ErrorAction 'Stop' `
    -ReferencedAssemblies $ReferencedAssemblies `
    -TypeDefinition $(Get-Content "$PSScriptRoot\AnyBox.cs" -Raw)