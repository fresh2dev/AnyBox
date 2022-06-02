using System.Management.Automation;
using System.Windows.Media;
using System.Drawing;

namespace AnyBox
{
    public enum InputType {
        None, Text, FileOpen, FileSave, FolderOpen, Checkbox, Password, Date, Link
    };
    
    public enum MessagePosition { Top, Left };
    public enum SetPresentation { ComboBox, Radio, Radio_Wide };
    public enum DataGridSelectionMode { None, SingleCell, SingleRow, MultiRow };

    public enum WindowStartupLocation { Center, Top, TopLeft, TopRight, Bottom, BottomLeft, BottomRight };

    public class AnyBox
    {
        public string Icon;
        public string Title;
        public string Image;
        public string[] Message;
        public object[] Prompts;
        public object[] Buttons;
        public string CancelButton;
        public string DefaultButton;
        public System.UInt16 ButtonRows = 1;
        public string[] Comment;
        public string ContentAlignment = "Left";
        public bool CollapsibleGroups;
        public bool CollapsedGroups;
        public System.Management.Automation.ScriptBlock PrepScript;
        public System.Windows.Media.FontFamily FontFamily = new System.Windows.Media.FontFamily("Segoe UI");
        public System.UInt16 FontSize = 12;
        public System.Windows.Media.Brush FontColor = System.Windows.Media.Brushes.Black;
        public System.Windows.Media.Brush BackgroundColor;
        public System.Windows.Media.Brush AccentColor = System.Windows.Media.Brushes.Gainsboro;
        public System.Windows.WindowStyle WindowStyle = System.Windows.WindowStyle.SingleBorderWindow;
        public System.Windows.ResizeMode ResizeMode = System.Windows.ResizeMode.CanMinimize;
        public bool NoResize;
        public System.UInt16 MinHeight = 50;
        public System.UInt16 MinWidth = 50;
        public System.UInt16 MaxHeight = 0;
        public System.UInt16 MaxWidth = 0;
        public bool Topmost;
        public bool HideTaskbarIcon;
        public System.UInt32 Timeout;
        public bool Countdown;
        public bool ProgressBar;
        public System.Management.Automation.ScriptBlock While;
        public WindowStartupLocation WindowStartupLocation = WindowStartupLocation.Center;
        public System.Windows.Window ParentWindow;
        public object[] GridData;
        public bool GridAsList;
        public DataGridSelectionMode SelectionMode = DataGridSelectionMode.SingleCell;
        public bool NoGridSearch;
    }

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