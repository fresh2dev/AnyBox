Add-Type -TypeDefinition @"
namespace AnyBox {
	public enum InputType {
		None, Text, FileOpen, FileSave, FolderOpen, Checkbox, Password, Date, Link
	};
	
	public enum MessagePosition { Top, Left };
	public enum SetPresentation { ComboBox, Radio, Radio_Wide };

	public class Prompt
	{
		public string Name;
		public string Tab;
		public string Group;
		public InputType InputType = InputType.Text;
		public string Message;
		public MessagePosition MessagePosition = MessagePosition.Top;
		public string Alignment;
		public System.UInt16 FontSize;
		public string FontFamily;
		public string FontColor;
		public string DefaultValue;
		public System.UInt16 LineHeight = 1;
		public bool ReadOnly = false;
		public string[] ValidateSet;
		public SetPresentation ShowSetAs = SetPresentation.ComboBox;
		public string RadioGroup;
		public bool ValidateNotEmpty = false;
		public System.Management.Automation.ScriptBlock ValidateScript;
		public bool ShowSeparator = false;
		public bool Collapsible = false;
		public bool Collapsed = false;
	}

	public class Button
	{
		public string Name;
		public string Text;
		public string ToolTip;
		public bool IsCancel = false;
		public bool IsDefault = false;
		public System.Management.Automation.ScriptBlock OnClick;
	}
}
"@
