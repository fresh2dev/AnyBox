function Get-Base64
{
    <#
    .SYNOPSIS
        Converts an image to its base64 string representation.
    .DESCRIPTION
        A base64 string can be passed to 'Show-Anybox' to show an image, which eliminates
        the reliance on the external file, making the script more easily portable.
        Purposefully renamed from `ConvertTo-Base64` to `Get-Base64` to avoid conflicts w/ other pkgs.
    .PARAMETER ImagePath
        Specifies a path to one or more locations.
    .PARAMETER ImagePath
        Specifies a path to one or more locations.
    .EXAMPLE
        [string]$base64 = 'C:\Path\to\img.png' | Get-Base64
        Show-AnyBox -Image $base64 -Message 'Hello World'
    .INPUTS
        The path to an image file.
    .OUTPUTS
        The base64 string representation of the image at $ImagePath.
    #>
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$ImagePath,
        [ValidateNotNullOrEmpty()]
        [System.Drawing.Imaging.ImageFormat]$ImageFormat = [System.Drawing.Imaging.ImageFormat]::Png
    )

    process
    {
        foreach ($img in $ImagePath)
        {
            $bmp = [System.Drawing.Bitmap]::FromFile($img)

            $memory = New-Object System.IO.MemoryStream
            $null = $bmp.Save($memory, $ImageFormat)

            [byte[]]$bytes = $memory.ToArray()

            $memory.Close()

            [System.Convert]::ToBase64String($bytes)
        }
    }
}