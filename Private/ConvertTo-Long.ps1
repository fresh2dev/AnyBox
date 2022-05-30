function ConvertTo-Long
{
    <#
    .SYNOPSIS
        "Melts" object(s) into an array of key-value pairs.
    .DESCRIPTION
        Converts object(s) wide objects into a long array object for better display.
    .PARAMETER obj
        The object(s) to melt.
    .PARAMETER KeyName
        The name of the resulting key column; defaults to "Name".
    .PARAMETER obj
        The name of the resulting value column; defaults to "Value".
    .INPUTS
        One or more objects.
    .OUTPUTS
        An array of objects with properties "$KeyName" and "$ValueName".
    #>
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object[]]$obj,
        [ValidateNotNullOrEmpty()]
        [string]$KeyName = 'Name',
        [ValidateNotNullOrEmpty()]
        [string]$ValueName = 'Value'
    )
    
    process
    {
        foreach ($o in $obj)
        {
            $o.psobject.Properties | ForEach-Object { [pscustomobject]@{ $KeyName = $_.Name; $ValueName = $_.Value } }
        }
    }
}