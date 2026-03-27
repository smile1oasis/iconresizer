<#
===========================================
 ICON RESIZER – Game Logo Converter (v1.2)
===========================================
#>

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# -------------------------------
# MAIN FORM SETUP
# -------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Icon Resizer 1.2.0"
$form.Size = New-Object System.Drawing.Size(550, 880)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"

# Title
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Icon Resizer"
$titleLabel.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(20, 10)
$titleLabel.AutoSize = $true
$form.Controls.Add($titleLabel)

# File Selection
$buttonSelect = New-Object System.Windows.Forms.Button
$buttonSelect.Text = "Select Image"
$buttonSelect.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($buttonSelect)

$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(100, 100)
$pictureBox.Location = New-Object System.Drawing.Point(400, 10)
$pictureBox.SizeMode = "Zoom"
$pictureBox.BorderStyle = "FixedSingle"
$form.Controls.Add($pictureBox)

# Prefix
$prefixLabel = New-Object System.Windows.Forms.Label
$prefixLabel.Text = "File Prefix (Optional):"
$prefixLabel.Location = New-Object System.Drawing.Point(20, 90)
$prefixLabel.AutoSize = $true
$form.Controls.Add($prefixLabel)

$prefixBox = New-Object System.Windows.Forms.TextBox
$prefixBox.Size = New-Object System.Drawing.Size(200, 20)
$prefixBox.Location = New-Object System.Drawing.Point(20, 110)
$form.Controls.Add($prefixBox)

# --- Android Adaptive Group ---
$groupAdaptive = New-Object System.Windows.Forms.GroupBox
$groupAdaptive.Text = "Android Adaptive Icons"
$groupAdaptive.Location = New-Object System.Drawing.Point(20, 150)
$groupAdaptive.Size = New-Object System.Drawing.Size(240, 210)
$form.Controls.Add($groupAdaptive)

$btnAllAdaptive = New-Object System.Windows.Forms.Button
$btnAllAdaptive.Text = "Select All"
$btnAllAdaptive.Size = New-Object System.Drawing.Size(70, 20)
$btnAllAdaptive.Location = New-Object System.Drawing.Point(160, 15)
$groupAdaptive.Controls.Add($btnAllAdaptive)

$resolutionsAdaptive = @(432, 324, 216, 162, 108, 81)
$chksAdaptive = @()
for ($i=0; $i -lt $resolutionsAdaptive.Count; $i++) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($resolutionsAdaptive[$i])x$($resolutionsAdaptive[$i])"
    $cb.Location = New-Object System.Drawing.Point(10, (35 + ($i * 25)))
    $cb.Tag = $resolutionsAdaptive[$i]
    $groupAdaptive.Controls.Add($cb)
    $chksAdaptive += $cb
}

# --- Android Legacy Group ---
$groupLegacy = New-Object System.Windows.Forms.GroupBox
$groupLegacy.Text = "Android Legacy Icons"
$groupLegacy.Location = New-Object System.Drawing.Point(280, 150)
$groupLegacy.Size = New-Object System.Drawing.Size(240, 210)
$form.Controls.Add($groupLegacy)

$btnAllLegacy = New-Object System.Windows.Forms.Button
$btnAllLegacy.Text = "Select All"
$btnAllLegacy.Size = New-Object System.Drawing.Size(70, 20)
$btnAllLegacy.Location = New-Object System.Drawing.Point(160, 15)
$groupLegacy.Controls.Add($btnAllLegacy)

$resolutionsLegacy = @(192, 144, 96, 72, 48, 36)
$chksLegacy = @()
for ($i=0; $i -lt $resolutionsLegacy.Count; $i++) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($resolutionsLegacy[$i])x$($resolutionsLegacy[$i])"
    $cb.Location = New-Object System.Drawing.Point(10, (35 + ($i * 25)))
    $cb.Tag = $resolutionsLegacy[$i]
    $groupLegacy.Controls.Add($cb)
    $chksLegacy += $cb
}

# --- Other Common Icons ---
$groupCommon = New-Object System.Windows.Forms.GroupBox
$groupCommon.Text = "Other Common Icons"
$groupCommon.Location = New-Object System.Drawing.Point(20, 370)
$groupCommon.Size = New-Object System.Drawing.Size(500, 65)
$form.Controls.Add($groupCommon)

$chk512 = New-Object System.Windows.Forms.CheckBox
$chk512.Text = "512x512"; $chk512.Location = New-Object System.Drawing.Point(10, 30); $chk512.Tag = 512
$groupCommon.Controls.Add($chk512)

$chk256 = New-Object System.Windows.Forms.CheckBox
$chk256.Text = "256x256"; $chk256.Location = New-Object System.Drawing.Point(120, 30); $chk256.Tag = 256
$groupCommon.Controls.Add($chk256)

# --- Custom Sizes ---
$customLabel = New-Object System.Windows.Forms.Label
$customLabel.Text = "Custom (comma separated, e.g. 1024, 128):"
$customLabel.Location = New-Object System.Drawing.Point(20, 450)
$customLabel.AutoSize = $true
$form.Controls.Add($customLabel)

$customBox = New-Object System.Windows.Forms.TextBox
$customBox.Size = New-Object System.Drawing.Size(500, 20)
$customBox.Location = New-Object System.Drawing.Point(20, 470)
$form.Controls.Add($customBox)

# -------------------------------
# LOGIC & EVENTS
# -------------------------------

$global:selectedFile = $null
$buttonSelect.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.ico"
    if ($ofd.ShowDialog() -eq "OK") {
        $global:selectedFile = $ofd.FileName
        $pictureBox.Image = [System.Drawing.Image]::FromFile($global:selectedFile)
    }
})

# Toggle logic for Adaptive
$btnAllAdaptive.Add_Click({
    $isAnyUnchecked = ($chksAdaptive | Where-Object { -not $_.Checked })
    foreach ($chk in $chksAdaptive) { $chk.Checked = [bool]$isAnyUnchecked }
})

# Toggle logic for Legacy
$btnAllLegacy.Add_Click({
    $isAnyUnchecked = ($chksLegacy | Where-Object { -not $_.Checked })
    foreach ($chk in $chksLegacy) { $chk.Checked = [bool]$isAnyUnchecked }
})

$resizeButton = New-Object System.Windows.Forms.Button
$resizeButton.Text = "Resize Image(s)"
$resizeButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$resizeButton.Size = New-Object System.Drawing.Size(200, 50)
$resizeButton.Location = New-Object System.Drawing.Point(175, 530)
$resizeButton.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($resizeButton)

$resizeButton.Add_Click({
    if (-not $global:selectedFile) {
        [System.Windows.Forms.MessageBox]::Show("Please select an image first.")
        return
    }

    $resolutions = @()
    ($chksAdaptive + $chksLegacy + $chk512 + $chk256) | ForEach-Object {
        if ($_.Checked) { $resolutions += [int]$_.Tag }
    }

    if (-not [string]::IsNullOrWhiteSpace($customBox.Text)) {
        $customValues = $customBox.Text -split '[, ]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
        $resolutions += $customValues
    }

    $resolutions = $resolutions | Sort-Object -Unique -Descending

    if ($resolutions.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select or enter at least one resolution.")
        return
    }

    $img = [System.Drawing.Image]::FromFile($global:selectedFile)
    $dir = [System.IO.Path]::GetDirectoryName($global:selectedFile)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($global:selectedFile)
    $ext  = [System.IO.Path]::GetExtension($global:selectedFile)
    
    # Prefix Logic: No underscore if prefix is empty
    $prefix = $prefixBox.Text.Trim()
    $fileBase = if ($prefix) { "${prefix}_${name}" } else { $name }

    foreach ($res in $resolutions) {
        $bmp = New-Object System.Drawing.Bitmap $res, $res
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $res, $res)
        
        # Consistent naming: fileBase_Size.ext
        $outputFile = Join-Path $dir ("$fileBase" + "_" + $res + "x" + $res + $ext)
        $bmp.Save($outputFile, $img.RawFormat)
        
        $g.Dispose()
        $bmp.Dispose()
    }

    $img.Dispose()
    [System.Windows.Forms.MessageBox]::Show("Success! Created $($resolutions.Count) images in folder.")
})

# Footer
$linkLabel = New-Object System.Windows.Forms.LinkLabel
$linkLabel.Text = "by SR15  |  GitHub Repository"
$linkLabel.AutoSize = $true
$linkLabel.Location = New-Object System.Drawing.Point(190, 810)
$linkLabel.Add_LinkClicked({ Start-Process "https://github.com/smile1oasis/ImageResolutionConverter" })
$form.Controls.Add($linkLabel)

$form.Topmost = $true
[void]$form.ShowDialog()