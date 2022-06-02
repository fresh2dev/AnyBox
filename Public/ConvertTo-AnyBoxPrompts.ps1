function ConvertTo-AnyBoxPrompts
{
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [string]$Key_Prefix = 'param_'
    )

    $ScriptBlock.Ast.Body.ParamBlock.Parameters | ForEach-Object {
        [string]$name = $_.Name.VariablePath.UserPath
        $attrs = @($_ | Select-Object -ExpandProperty Attributes)
        
        [bool]$mandatory = $false
        [bool]$not_null = $false
        [AnyBox.InputType]$input_type = [AnyBox.InputType]::Text
        [scriptblock]$validate_script = $null
        [array]$validate_set = $null
        
        foreach ($attr in $attrs)
        {
            if ($attr.TypeName.Name -eq 'Parameter')
            {
                foreach ($arg in $attr.NamedArguments)
                {
                    if ($arg.ArgumentName -eq 'Mandatory' -and $arg.Argument -eq $true -and -not $arg.ExpressionOmitted)
                    {
                        $mandatory = $true
                        continue
                    }
                }
            }
            elseif (@('ValidateNotNullOrEmpty', 'ValidateNotNull').Contains($attr.TypeName.Name))
            {
                $not_null = $true
            }
            elseif ($attr.TypeName.Name -eq 'ValidateScript')
            {
                $validate_script = $attr.PositionalArguments[0].SafeGetValue() #.ScriptBlock
            }
            elseif ($attr.TypeName.Name -eq 'ValidateSet')
            {
                $validate_set = @($attr.PositionalArguments.SafeGetValue())
            }
            elseif ($attr.TypeName.Name -eq 'bool' -or $attr.TypeName.Name -eq 'switch')
            {
                $input_type = [AnyBox.InputType]::Checkbox
            }
            elseif ($attr.TypeName.Name -eq 'datetime')
            {
                $input_type = [AnyBox.InputType]::Date
            }
        }

        $default = $attrs | Select-Object -ExpandProperty Parent -First 1 | Select-Object -ExpandProperty DefaultValue | Select-Object -ExpandProperty Value -EA 0
        
        $param_config = @{
            'InputType' = $input_type
            'Name' = $Key_Prefix + $name
            'Message' = $name + ":"
            'ValidateNotEmpty' = ($mandatory -or $not_null)
            'ValidateScript' = $validate_script
            'ValidateSet' = $validate_set
            'DefaultValue' = $default
        }

        New-AnyBoxPrompt @param_config
    }
}