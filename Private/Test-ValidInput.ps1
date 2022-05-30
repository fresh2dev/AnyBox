function Test-ValidInput
{
    param(
        [object[]]$Prompts,
        [hashtable]$Inputs
    )

    [bool]$valid = $true
    [string]$err_msg = $null

    foreach ($prmpt in $Prompts)
    {
        if ($prmpt.ValidateNotEmpty -and -not $Inputs[$prmpt.Name])
        {
            if ($prmpt.ValidateSet)
            {
                $err_msg = 'Please make a selection.'
            }
            elseif ($prmpt.InputType -eq [AnyBox.InputType]::Link)
            {
                $err_msg = 'Please click the link.'
            }
            elseif ($prmpt.Message)
            {
                $err_msg = "Please provide input for '{0}'" -f $prmpt.Message.TrimEnd(':').Trim()
            }
            else
            {
                $err_msg = 'Please provide input for required fields.'
            }
        }
        elseif ($prmpt.ValidateScript -and -not ($Inputs[$prmpt.Name] | ForEach-Object -Process $prmpt.ValidateScript))
        {
            if ($prmpt.Message)
            {
                $err_msg = "Invalid input for '{0}'" -f $prmpt.Message.TrimEnd(':')
            }
            else
            {
                $err_msg = 'Invalid input provided.'
            }
        }

        if ($err_msg)
        {
            $valid = $false
            break
        }
    }

    return([PSCustomObject]@{
            Is_Valid = $valid
            Message = $err_msg
        })
}
