[string]$ModuleRoot = $PSScriptRoot

if (-not $ModuleRoot)
{
    $ModuleRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path "$ModuleRoot\Public\*.ps1" -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path "$ModuleRoot\Private\*.ps1" -ErrorAction SilentlyContinue )
$Types = @( Get-ChildItem -Path "$ModuleRoot\Types\*.ps1" -ErrorAction SilentlyContinue )

#Dot source the files
foreach ($import in @($Public + $Private + $Types))
{
    try
    {
        Write-Verbose -Message "Importing $($import.fullname)"
        . $import.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import $($import.fullname): $_"
    }
}

Export-ModuleMember -Function ($Public | Select-Object -ExpandProperty BaseName)
