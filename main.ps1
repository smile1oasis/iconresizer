<#
===========================================
 ICON RESIZER – Game Logo Converter (v1.6)
===========================================
#>

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# -------------------------------
# MAIN FORM SETUP
# -------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Icon Resizer 1.6.0"
$form.Size = New-Object System.Drawing.Size(650, 950) # Increased height for UI clarity
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
$pictureBox.Location = New-Object System.Drawing.Point(500, 10)
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

# --- iOS Group (Expanded to show ALL resolutions from screenshots) ---
$groupIOS = New-Object System.Windows.Forms.GroupBox
$groupIOS.Text = "iOS Icons"
$groupIOS.Location = New-Object System.Drawing.Point(20, 150)
$groupIOS.Size = New-Object System.Drawing.Size(190, 400) # Increased height to prevent clipping
$form.Controls.Add($groupIOS)

$btnAllIOS = New-Object System.Windows.Forms.Button
$btnAllIOS.Text = "Select All"
$btnAllIOS.Size = New-Object System.Drawing.Size(70, 20)
$btnAllIOS.Location = New-Object System.Drawing.Point(110, 15)
$groupIOS.Controls.Add($btnAllIOS)

# Full list derived from your Unity screenshots
$resIOS = @(1024, 180, 167, 152, 120, 87, 80, 76, 60, 58, 40, 29, 20)
$chksIOS = foreach ($res in $resIOS) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($res)x$($res)"
    $cb.Tag = $res
    $cb.Location = New-Object System.Drawing.Point(10, (35 + ($resIOS.IndexOf($res) * 25)))
    $groupIOS.Controls.Add($cb); $cb
}

# --- Android Adaptive Group ---
$groupAdaptive = New-Object System.Windows.Forms.GroupBox
$groupAdaptive.Text = "Android Adaptive"
$groupAdaptive.Location = New-Object System.Drawing.Point(225, 150)
$groupAdaptive.Size = New-Object System.Drawing.Size(190, 210)
$form.Controls.Add($groupAdaptive)

$btnAllAdp = New-Object System.Windows.Forms.Button
$btnAllAdp.Text = "Select All"
$btnAllAdp.Size = New-Object System.Drawing.Size(70, 20)
$btnAllAdp.Location = New-Object System.Drawing.Point(110, 15)
$groupAdaptive.Controls.Add($btnAllAdp)

$resAdp = @(432, 324, 216, 162, 108, 81)
$chksAdp = foreach ($res in $resAdp) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($res)x$($res)"; $cb.Tag = $res
    $cb.Location = New-Object System.Drawing.Point(10, (35 + ($resAdp.IndexOf($res) * 25)))
    $groupAdaptive.Controls.Add($cb); $cb
}

# --- Android Legacy Group ---
$groupLegacy = New-Object System.Windows.Forms.GroupBox
$groupLegacy.Text = "Android Legacy"
$groupLegacy.Location = New-Object System.Drawing.Point(430, 150)
$groupLegacy.Size = New-Object System.Drawing.Size(190, 210)
$form.Controls.Add($groupLegacy)

$btnAllLeg = New-Object System.Windows.Forms.Button
$btnAllLeg.Text = "Select All"
$btnAllLeg.Size = New-Object System.Drawing.Size(70, 20)
$btnAllLeg.Location = New-Object System.Drawing.Point(110, 15)
$groupLegacy.Controls.Add($btnAllLeg)

$resLeg = @(192, 144, 96, 72, 48, 36)
$chksLeg = foreach ($res in $resLeg) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($res)x$($res)"; $cb.Tag = $res
    $cb.Location = New-Object System.Drawing.Point(10, (35 + ($resLeg.IndexOf($res) * 25)))
    $groupLegacy.Controls.Add($cb); $cb
}

# --- Common & Custom ---
$groupCommon = New-Object System.Windows.Forms.GroupBox
$groupCommon.Text = "Other Common Icons"
$groupCommon.Location = New-Object System.Drawing.Point(225, 370)
$groupCommon.Size = New-Object System.Drawing.Size(395, 65)
$form.Controls.Add($groupCommon)

$chk512 = New-Object System.Windows.Forms.CheckBox; $chk512.Text = "512x512"; $chk512.Tag = 512; $chk512.Location = New-Object System.Drawing.Point(10, 30); $groupCommon.Controls.Add($chk512)
$chk256 = New-Object System.Windows.Forms.CheckBox; $chk256.Text = "256x256"; $chk256.Tag = 256; $chk256.Location = New-Object System.Drawing.Point(120, 30); $groupCommon.Controls.Add($chk256)

$customBox = New-Object System.Windows.Forms.TextBox; $customBox.Size = New-Object System.Drawing.Size(600, 20); $customBox.Location = New-Object System.Drawing.Point(20, 600)
$form.Controls.AddRange(@((New-Object System.Windows.Forms.Label -Property @{Text="Custom (comma separated):"; Location=New-Object System.Drawing.Point(20, 580); AutoSize=$true}), $customBox))

# -------------------------------
# LOGIC & EVENTS
# -------------------------------

$global:selectedFile = $null
$buttonSelect.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Images|*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.ico"
    if ($ofd.ShowDialog() -eq "OK") {
        $global:selectedFile = $ofd.FileName
        $pictureBox.Image = [System.Drawing.Image]::FromFile($global:selectedFile)
    }
})

$btnAllIOS.Add_Click({ $v = !($chksIOS[0].Checked); $chksIOS | % { $_.Checked = $v } })
$btnAllAdp.Add_Click({ $v = !($chksAdp[0].Checked); $chksAdp | % { $_.Checked = $v } })
$btnAllLeg.Add_Click({ $v = !($chksLeg[0].Checked); $chksLeg | % { $_.Checked = $v } })

$resizeButton = New-Object System.Windows.Forms.Button
$resizeButton.Text = "RESIZE ALL"; $resizeButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold); $resizeButton.Size = New-Object System.Drawing.Size(300, 60); $resizeButton.Location = New-Object System.Drawing.Point(175, 660); $resizeButton.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($resizeButton)

$resizeButton.Add_Click({
    if (-not $global:selectedFile) { [System.Windows.Forms.MessageBox]::Show("Select an image."); return }

    $resolutions = @()
    ($chksIOS + $chksAdp + $chksLeg + $chk512 + $chk256) | % { if ($_.Checked) { $resolutions += $_.Tag } }
    if ($customBox.Text) { $resolutions += ($customBox.Text -split '[, ]+' | ? { $_ -match '^\d+(\.\d+)?$' } | % { [double]$_ }) }
    $resolutions = $resolutions | Sort-Object -Unique -Descending

    if ($resolutions.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Select a size."); return }

    $img = [System.Drawing.Image]::FromFile($global:selectedFile)
    $dir = [System.IO.Path]::GetDirectoryName($global:selectedFile)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($global:selectedFile)
    $ext = [System.IO.Path]::GetExtension($global:selectedFile)
    $prefix = $prefixBox.Text.Trim()
    $fileBase = if ($prefix) { "${prefix}_${name}" } else { $name }

    foreach ($res in $resolutions) {
        $w = $h = [int][Math]::Round($res)
        $bmp = New-Object System.Drawing.Bitmap $w, $h
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = "HighQualityBicubic"
        $g.DrawImage($img, 0, 0, $w, $h)
        $bmp.Save((Join-Path $dir ("$fileBase" + "_" + $res + "x" + $res + $ext)), $img.RawFormat)
        $g.Dispose(); $bmp.Dispose()
    }
    $img.Dispose()
    [System.Windows.Forms.MessageBox]::Show("Success! Created $($resolutions.Count) images.")
})

$linkLabel = New-Object System.Windows.Forms.LinkLabel; $linkLabel.Text = "by SR15 | GitHub Repo"; $linkLabel.AutoSize = $true; $linkLabel.Location = New-Object System.Drawing.Point(250, 850)
$linkLabel.Add_LinkClicked({ Start-Process "https://github.com/smile1oasis/ImageResolutionConverter" })
$form.Controls.Add($linkLabel)

$form.Topmost = $true
[void]$form.ShowDialog()