Import-Module '.\AnyBox.psd1'

function Test-Assertion
{
    param (
        [Parameter(Mandatory = $true)]
        [Alias('o')]
        [object]$Observed,
        [Alias('e')]
        [object]$Expected = $true,
        [Parameter(Mandatory = $false)]
        [Alias('m')]
        [string]$Message
    )

    [bool]$eq = $Expected -eq $Observed

    if (-not $eq -and $Message)
    {
        foreach ($v in @($Expected, $Observed))
        {
            if ($null -eq $v)
            {
                $v = 'null'
            }
        }

        [string]$msg = $Message + ([environment]::NewLine * 2) + `
            'Expected: ' + $Expected.ToString() + ([environment]::NewLine * 2) + `
            'Observed: ' + $Observed.ToString()

        [hashtable]$resp = Show-AnyBox `
            -Icon 'Error' `
            -Title 'Failed Assertion' `
            -Message $msg `
            -Buttons @('Abort', 'Retry')
        
        if (-not $resp['Retry'])
        {
            exit 1
        }
    }

    return $eq
}

function Test-All
{
    param ([bool[]]$Arr)

    return $Arr.Length -eq ($Arr | Where-Object { $_ -eq $true }).Length
}

New-Alias -Name 'assert' -Value 'Test-Assertion' -Force

[hashtable]$params = @{
    MinWidth = 300
}

[hashtable]$resp = $null

# begin
do
{
    [string]$msg = 'Click the button to begin testing.'
    
    $resp = Show-AnyBox @params `
        -Title 'Begin Testing' `
        -Message $msg `
        -GridData ([pscustomobject]$PSVersionTable) `
        -GridAsList `
        -NoGridSearch `
        -Buttons 'GO'

} while (-not (
        Test-All (assert -m $msg -o $resp['GO'])
    )
)

assert -o $false -e $false
assert -o $true -e $true

# -Buttons
do
{
    [string[]]$btns = ' ', 'CLICK ME', '  '
    
    $resp = Show-AnyBox @params `
        -Message 'Click the button' `
        -Buttons $btns
    
    [string[]]$clicked = $resp.GetEnumerator() |
        Where-Object { $btns -contains $_.Key -and $_.Value -eq $true } |
        Select-Object -ExpandProperty Key
} while (-not (
        Test-All `
        (assert -m '# buttons clicked.' -o $clicked.Length -e 1), `
        (assert -m 'Button clicked' -o $clicked[0] -e 'CLICK ME')
    )
)

# -DefaultButton
do
{
    [string[]]$btns = ' ', '  ', '   '
    
    $resp = Show-AnyBox @params `
        -Message "Keyboard press 'Enter'" `
        -Buttons $btns `
        -DefaultButton $btns[1]
    
    [string[]]$clicked = $resp.GetEnumerator() |
        Where-Object { $btns -contains $_.Key -and $_.Value -eq $true } |
        Select-Object -ExpandProperty Key
} while (-not (
        Test-All `
        (assert -m '# buttons clicked.' -o $clicked.Length -e 1), `
        (assert -m 'Button clicked' -o $clicked[0] -e $btns[1])
    )
)

# -CancelButton
do
{
    [string[]]$btns = ' ', '  ', '   '
    
    $resp = Show-AnyBox @params `
        -Message "Keyboard press 'Esc'" `
        -Buttons $btns `
        -CancelButton $btns[2]
    
    [string[]]$clicked = $resp.GetEnumerator() |
        Where-Object { $btns -contains $_.Key -and $_.Value -eq $true } |
        Select-Object -ExpandProperty Key
} while (-not (
        Test-All `
        (assert -m '# buttons clicked.' -o $clicked.Length -e 1), `
        (assert -m 'Button clicked' -o $clicked[0] -e $btns[2])
    )
)

# -Topmost
do
{
    [string]$msg = 'Is this window topmost?'
    
    $resp = Show-AnyBox @params `
        -Message $msg `
        -Buttons 'No', 'Yes' `
        -Topmost

} while (-not (
        Test-All (assert -m $msg -o $resp['Yes'])
    )
)

# -WindowStartupLocation
do
{
    $resp = Show-AnyBox @params `
        -Message 'Am I bottom-right?' `
        -Buttons 'No', 'Yes' `
        -WindowStartupLocation 'BottomRight'
} while (-not (
        Test-All (assert -m $msg -o $resp['Yes'])
    )
)

# -HideTaskbarIcon
do
{
    [string]$msg = 'Is the tray icon visible?'
    
    $resp = Show-AnyBox @params `
        -Message $msg `
        -Buttons 'No', 'Yes' `
        -HideTaskbarIcon

} while (-not (
        Test-All (assert -m $msg -o $resp['No'])
    )
)

# -Prompts
do
{
    [string]$title = 'hello world'
    [string]$msg = 'Type the title text in the prompt below'

    $resp = Show-AnyBox @params `
        -Title $title `
        -Prompt $msg `
        -Buttons 'OK'

} while (-not (
        Test-All `
        (assert -m 'prompt exists' -o ('Input_0' -in $resp.Keys)),
        (assert -m 'user input' -o $resp['Input_0'] -e $title)
    )
)

# -ValidateSet
do
{
    [string]$msg = 'Select the value'

    [string]$expected = 'SELECT ME'

    [string[]]$choices = @('ignore me', 'ignore me too', $expected)
    $choices = @($choices | Get-Random -Count $choices.Length)
    $choices = @(' ') + $choices
    
    $resp = Show-AnyBox @params `
        -Buttons 'OK' `
        -Prompt (
        New-AnyBoxPrompt `
            -Message $msg `
            -ValidateSet $choices `
            -DefaultValue $choices[0]
    )

} while (-not (
        Test-All `
        (assert -m 'Icon displayed' -o $resp['Input_0'] -e $expected)
    )
)

# -Icon
do
{
    [string]$msg = 'Which icon is displayed?'

    [string[]]$choices = @('Information', 'Question', 'Exclamation')
    $choices = @($choices | Get-Random -Count $choices.Length)
    $choices = @(' ') + $choices

    [string]$expected = $choices | Select-Object -Last 1

    $resp = Show-AnyBox @params `
        -Title "icon: $expected" `
        -Icon $expected `
        -Prompt (
        New-AnyBoxPrompt `
            -Message $msg `
            -ValidateSet $choices `
            -DefaultValue $choices[0]
    ) `
        -Buttons 'OK'

} while (-not (
        Test-All `
        (assert -m 'Icon displayed' -o $resp['Input_0'] -e $expected)
    )
)

# -FontColor, -BackgroundColor
do
{
    [string[]]$choices = @('Red', 'Green', 'White')
    $choices = @($choices | Get-Random -Count $choices.Length)
    $choices = @(' ') + $choices

    [string]$expected = $choices | Select-Object -Last 1

    [string[]]$choices_bg = @('Black', 'Purple', 'Blue')
    $choices_bg = @($choices_bg | Get-Random -Count $choices_bg.Length)
    $choices_bg = @(' ') + $choices_bg

    [string]$expected_bg = $choices_bg | Select-Object -Last 1

    $resp = Show-AnyBox @params `
        -FontColor $expected `
        -BackgroundColor $expected_bg `
        -Buttons 'OK' `
        -Prompt @(
        New-AnyBoxPrompt `
            -Message 'Which color is the text?' `
            -ValidateSet $choices `
            -DefaultValue $choices[0]
        New-AnyBoxPrompt `
            -Message 'Which color is the background?' `
            -ValidateSet $choices_bg `
            -DefaultValue $choices_bg[0]
    )

} while (-not (
        Test-All `
        (assert -m 'Font color' -o $resp['Input_0'] -e $expected),
        (assert -m 'Background color' -o $resp['Input_1'] -e $expected_bg)
    )
)

# aliases, -Timeout, -Countdown 
anybox -Timeout 10 -Countdown `
    -i 'Information' `
    -t 'Success' `
    -m 'All tests passed :)' `
    -b 'Hooray!' `
