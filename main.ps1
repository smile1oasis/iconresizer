Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# -------------------------------
# WELCOME SCREEN (GUI + Console)
# -------------------------------
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "         // ICON RESIZER //          " -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Green
Write-Host "  1. Let you pick an image file"
Write-Host "  2. Ask for a prefix (e.g., logo)"
Write-Host "  3. Select target sizes OR enter custom sizes (comma separated: 1024,512,256)"
Write-Host "  4. Create resized images with the same format in the same folder"
Write-Host ""
Write-Host "Example output: logo_512x512.png, logo_256x256.png"
Write-Host ""
Write-Host "--------------------------------------"
Write-Host "Press 'Resize Image(s)' in the popup to start..."
Write-Host "--------------------------------------"

# -------------------------------
# MAIN FORM
# -------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Icon Resizer 1.0.1"
$form.Size = New-Object System.Drawing.Size(500, 600)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $true
$form.MinimizeBox = $true
$form.FormBorderStyle = "FixedSingle"   # Keeps min/max but prevents manual resize

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Welcome to Icon Resizer!"
$titleLabel.Font = New-Object System.Drawing.Font("Arial",16,[System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(120,20)
$form.Controls.Add($titleLabel)

# File selection button
$buttonSelect = New-Object System.Windows.Forms.Button
$buttonSelect.Text = "Select Image"
$buttonSelect.Location = New-Object System.Drawing.Point(50,70)
$buttonSelect.AutoSize = $true
$form.Controls.Add($buttonSelect)

# PictureBox for preview
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(128,128)
$pictureBox.Location = New-Object System.Drawing.Point(300,60)
$pictureBox.SizeMode = "Zoom"
$form.Controls.Add($pictureBox)

# Prefix Label + TextBox
$prefixLabel = New-Object System.Windows.Forms.Label
$prefixLabel.Text = "File Prefix:"
$prefixLabel.AutoSize = $true
$prefixLabel.Location = New-Object System.Drawing.Point(50,120)
$form.Controls.Add($prefixLabel)

$prefixBox = New-Object System.Windows.Forms.TextBox
$prefixBox.Size = New-Object System.Drawing.Size(150,20)
$prefixBox.Location = New-Object System.Drawing.Point(150,118)
$form.Controls.Add($prefixBox)

# Resolution Checkboxes
$resGroupLabel = New-Object System.Windows.Forms.Label
$resGroupLabel.Text = "Resolutions:"
$resGroupLabel.AutoSize = $true
$resGroupLabel.Location = New-Object System.Drawing.Point(50,160)
$form.Controls.Add($resGroupLabel)

$chkAll = New-Object System.Windows.Forms.CheckBox
$chkAll.Text = "All"
$chkAll.Location = New-Object System.Drawing.Point(150,160)
$form.Controls.Add($chkAll)

$chk512 = New-Object System.Windows.Forms.CheckBox
$chk512.Text = "512"
$chk512.Location = New-Object System.Drawing.Point(150,190)
$form.Controls.Add($chk512)

$chk256 = New-Object System.Windows.Forms.CheckBox
$chk256.Text = "256"
$chk256.Location = New-Object System.Drawing.Point(150,220)
$form.Controls.Add($chk256)

$chk96 = New-Object System.Windows.Forms.CheckBox
$chk96.Text = "96"
$chk96.Location = New-Object System.Drawing.Point(150,250)
$form.Controls.Add($chk96)

$chk48 = New-Object System.Windows.Forms.CheckBox
$chk48.Text = "48"
$chk48.Location = New-Object System.Drawing.Point(150,280)
$form.Controls.Add($chk48)

# Custom Resolution
$customLabel = New-Object System.Windows.Forms.Label
$customLabel.Text = "Custom (comma separated):"
$customLabel.AutoSize = $true
$customLabel.Location = New-Object System.Drawing.Point(50,320)
$form.Controls.Add($customLabel)

$customBox = New-Object System.Windows.Forms.TextBox
$customBox.Size = New-Object System.Drawing.Size(150,20)
$customBox.Location = New-Object System.Drawing.Point(230,318)
$form.Controls.Add($customBox)

# Event: Select Image
$global:selectedFile = $null
$buttonSelect.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.ico"
    if ($ofd.ShowDialog() -eq "OK") {
        $global:selectedFile = $ofd.FileName
        $pictureBox.Image = [System.Drawing.Image]::FromFile($global:selectedFile)
    }
})

# Event: All checkbox
$chkAll.Add_CheckedChanged({
    $state = $chkAll.Checked
    $chk512.Checked = $state
    $chk256.Checked = $state
    $chk96.Checked = $state
    $chk48.Checked = $state
})

# Resize Button
$resizeButton = New-Object System.Windows.Forms.Button
$resizeButton.Text = "Resize Image(s)"
$resizeButton.Location = New-Object System.Drawing.Point(150,370)
$resizeButton.AutoSize = $true
$form.Controls.Add($resizeButton)

# Event: Resize
$resizeButton.Add_Click({
    if (-not $global:selectedFile) {
        [System.Windows.Forms.MessageBox]::Show("Please select an image first.")
        return
    }

    $prefix = $prefixBox.Text
    $resolutions = @()
    if ($chk512.Checked) { $resolutions += 512 }
    if ($chk256.Checked) { $resolutions += 256 }
    if ($chk96.Checked)  { $resolutions += 96 }
    if ($chk48.Checked)  { $resolutions += 48 }

    # Parse custom field: allow comma/space separated list
    if (-not [string]::IsNullOrWhiteSpace($customBox.Text)) {
        $customValues = $customBox.Text -split '[, ]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
        $resolutions += $customValues
    }

    # Remove duplicates & sort
    $resolutions = $resolutions | Sort-Object -Unique

    if ($resolutions.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select or enter at least one resolution.")
        return
    }

    $img = [System.Drawing.Image]::FromFile($global:selectedFile)
    $dir = [System.IO.Path]::GetDirectoryName($global:selectedFile)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($global:selectedFile)
    $ext  = [System.IO.Path]::GetExtension($global:selectedFile)

    foreach ($res in $resolutions) {
        $bmp = New-Object System.Drawing.Bitmap $res, $res
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.DrawImage($img, 0, 0, $res, $res)
        $outputFile = Join-Path $dir ($prefix + "_" + $name + "_" + $res + $ext)
        $bmp.Save($outputFile, $img.RawFormat)
        $g.Dispose()
        $bmp.Dispose()
    }

    $img.Dispose()
    [System.Windows.Forms.MessageBox]::Show("Images resized successfully! Created: `n" + ($resolutions -join ', '))
})

# Show Form
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
