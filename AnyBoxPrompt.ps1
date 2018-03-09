Add-Type -TypeDefinition @"
namespace AnyBox {
	public enum InputType {
		None, Text, FileOpen, FileSave, Checkbox, Password, Date, Link
	};

	public class Prompt
	{
		public string Message;
		public string DefaultValue;
		public InputType InputType = InputType.Text;
		public System.UInt16 LineHeight = 1;
		public bool ReadOnly = false;
		public string[] ValidateSet;
		public bool ValidateNotEmpty = false;
		public System.Management.Automation.ScriptBlock ValidateScript;
	}
}
"@
