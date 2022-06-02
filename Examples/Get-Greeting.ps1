Import-Module '.\AnyBox.psd1'

function Get-Greeting
{
    param(
        [ValidateSet('Hello', 'Get it together', 'Buzz off')]
        [string]$Greeting = 'Hello',
        [ValidateNotNullOrEmpty()]
        [string]$Subject = 'World',
        [switch]$Exclaim
    )

    [string]$msg = $Greeting + ' ' + $Subject
    
    if ($Exclaim)
    {
        $msg = $msg.ToUpper() + '!' 
    }
    else
    {
        $msg += '.'
    }

    return $msg
}


[string]$func_name = 'Get-Greeting'

[hashtable]$style = @{
    Title = $func_name
    Button = 'OK'
    MinWidth = 300
}

[hashtable]$resp = Show-AnyBox @style -PromptsFromFunc $func_name

if ($resp['OK'])
{
    [hashtable]$func_params = Get-DictSubset -Source $resp -KeyStartsWith 'param_' -Trim

    [string]$msg = & (Get-Command $func_name).ScriptBlock @func_params

    $null = Show-AnyBox @style -Message $msg
}
