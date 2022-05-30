function ConvertTo-BitmapImage
{
    <#
    .SYNOPSIS
        Converts a base64 string to a BitmapImage object.
    .DESCRIPTION
        Used by 'Show-AnyBox' to convert a base64 string into a [System.Windows.Media.Imaging.BitmapImage].
    .PARAMETER base64
        The base64 string representing an image.
    .INPUTS
        The base64 string representing an image.
    .OUTPUTS
        A [System.Windows.Media.Imaging.BitmapImage] object.
    #>
    param([
        Parameter(ValueFromPipeline = $true)]
        [string[]]$base64
    )

    process
    {
        foreach ($str in $base64)
        {
            $bmp = [System.Drawing.Bitmap]::FromStream((New-Object System.IO.MemoryStream (@(, [Convert]::FromBase64String($base64)))))

            $memory = New-Object System.IO.MemoryStream
            $null = $bmp.Save($memory, [System.Drawing.Imaging.ImageFormat]::Png)
            $memory.Position = 0

            $img = New-Object System.Windows.Media.Imaging.BitmapImage
            $img.BeginInit()
            $img.StreamSource = $memory
            $img.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $img.EndInit()
            $img.Freeze()

            $memory.Close()

            $img
        }
    }
}