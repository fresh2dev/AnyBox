function Get-DictSubset {
    ### transforms this:
    # Name                           Value
    # ----                           -----
    # param_Exclaim                  True
    # OK                             True
    # param_Greeting                 Hello
    # param_Subject                  World
    ### into this:
    # Name                           Value
    # ----                           -----
    # Greeting                       Hello
    # Exclaim                        True
    # Subject                        World
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Source,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyStartsWith,
        [Parameter(Mandatory=$false)]
        [switch]$Trim
    )
    
    [hashtable]$subset = @{}
    
    $Source.GetEnumerator() |
        Where-Object { $_.Key.ToString().StartsWith($KeyStartsWith) } |
        ForEach-Object {
            [string]$param_name = $_.Key.ToString()
            if ($Trim)
            {
                $param_name = $param_name.Substring($KeyStartsWith.Length)
            }
            $subset.Add($param_name, $_.Value)
        }

    return $subset
}