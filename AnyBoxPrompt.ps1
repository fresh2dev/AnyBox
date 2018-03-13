Add-Type -TypeDefinition @"
namespace AnyBox {
	public enum InputType {
		None, Text, FileOpen, FileSave, Checkbox, Password, Date, Link
	};
	
	public enum MessagePosition { Top, Left };

	public class Prompt
	{
		public string Name;
		public InputType InputType = InputType.Text;
		public string Message;
		public MessagePosition MessagePosition = MessagePosition.Top;
		public string DefaultValue;
		public System.UInt16 LineHeight = 1;
		public bool ReadOnly = false;
		public string[] ValidateSet;
		public bool ValidateNotEmpty = false;
		public System.Management.Automation.ScriptBlock ValidateScript;
	}
}
"@

function New-AnyBoxPrompt
{
	[cmdletbinding()]
	param(
		[string]$Name,
		[ValidateNotNullOrEmpty()]
		[AnyBox.InputType]$InputType = [AnyBox.InputType]::Text,
		[string]$Message,
		[ValidateNotNullOrEmpty()]
		[AnyBox.MessagePosition]$MessagePosition = [AnyBox.MessagePosition]::Top,
		[string]$DefaultValue,
		[ValidateScript({$_ -gt 0})]
		[UInt16]$LineHeight = 1,
		[switch]$ReadOnly,
		[switch]$ValidateNotEmpty,
		[string[]]$ValidateSet,
		[System.Management.Automation.ScriptBlock]$ValidateScript
	)

	if ($Name -notmatch '^[A-Za-z_]+[A-Za-z0-9_]*$') {
		Write-Warning "Name must start with a letter or the underscore character (_), and must contain only letters, digits, or underscores."
		$Name = $null
	}

	if ($InputType -ne [AnyBox.InputType]::Text)
	{
		if ($InputType -eq [AnyBox.InputType]::None) {
			return($null)
		}

		if ($LineHeight -gt 1) {
			Write-Warning "'-LineHeight' parameter is only valid with text input."
		}

		if ($InputType -eq [AnyBox.InputType]::Checkbox) {
			if (-not $Message) {
				Write-Warning "Checkbox input requires a message."
				$Message = 'Message'
			}
		}
		elseif ($InputType -eq [AnyBox.InputType]::Password) {
			if ($DefaultValue) {
				Write-Warning 'Password input does not accept a default value.'
				$DefaultValue = $null
			}
		}
	}
	
	$p = New-Object AnyBox.Prompt

	$p.Name = $Name
	$p.InputType = $InputType
	$p.Message = $Message
	$p.MessagePosition = $MessagePosition
	$p.DefaultValue = $DefaultValue
	$p.LineHeight = $LineHeight
	$p.ValidateNotEmpty = $ValidateNotEmpty -as [bool]
	$p.ValidateSet = $ValidateSet
	$p.ValidateScript = $ValidateScript

	return($p)
}
