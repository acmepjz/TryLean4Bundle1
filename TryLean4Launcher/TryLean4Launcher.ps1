$msgTable = Data {
    ConvertFrom-StringData @'
    formTitle = Try Lean4 Windows Bundle Launcher
    home = Home
    oneClickStart = One click to start Try Lean4 Windows Bundle
    offlineHelp = Offline mathlib help
    startServer = Start offline mathlib help server
    stopServer = Stop offline mathlib help server
    showHelp = Open offline mathlib help
    advanced = Advanced
    unpackCache = Unpack mathlib cache
    cacheStatus = mathlib cache status
    notInstalled = Not installed
    installed = Installed
    startBundle = Start Try Lean4 Windows Bundle
    startVSCode = Start Lean4 VSCode code editor
    startBash = Start Lean4 bash command line
    error = Error
    fileNotFound = Failed to load file '{0}'. Please check the installation is correct.
    cacheAlreadyExists = Mathlib cache already exists
    unpackCacheMsg = Do you want to install mathlib cache?
    unpackCacheTime = The installation process will take 5 minutes.
    cacheAlreadyExistsMsg = Mathlib cache already exists. Do you want to reinstall?
    firstTimeUse = Seems that it's the first time you using Try Lean4 Windows Bundle.
    firstTimeUse2 = The mathlib cache is not installed yet. Do you want to install mathlib cache?
    firstTimeUse3 = Choose 'yes' to install mathlib cache (recommended).
    firstTimeUse4 = Choose 'no' to run VSCode directly, note that 'import Mathlib' will be not available.
'@
}

Import-LocalizedData -BindingVariable localizedMsgTable -ErrorAction:SilentlyContinue

Function Merge-Hashtables {
    $Output = @{}
    ForEach ($Hashtable in ($Input + $Args)) {
        If ($Hashtable -is [Hashtable]) {
            ForEach ($Key in $Hashtable.Keys) {$Output.$Key = $Hashtable.$Key}
        }
    }
    $Output
}

$msgTable = Merge-Hashtables $msgTable $localizedMsgTable

Function Check-AtLeastOneFileExists {
    ForEach ($FileName in ($Input + $Args)) {
        $exists = Test-Path -Path $FileName -PathType Leaf
        If ($exists) {
            Return $true
        }
    }
    $false
}

Function Check-AllFileExists-And-Report {
    ForEach ($FileName in ($Input + $Args)) {
        $exists = Test-Path -Path $FileName -PathType Leaf
        If (-Not $exists) {
            $msg = ($msgTable.fileNotFound -f $FileName)
            [void]([System.Windows.Forms.MessageBox]::Show($msg, $msgTable.error, "OK", "Error"))
            Return $false
        }
    }
    $true
}

Function Check-CacheStatus {
    $script:cacheStatusLabel.Text = $msgTable.notInstalled
    $script:hasCache = $false
    $exists = Check-AtLeastOneFileExists "projects\LeanPlayground\.lake\packages\mathlib\.lake\build\lib\Mathlib\Init.olean" "projects\LeanPlayground\.lake\packages\mathlib\.lake\build\lib\lean\Mathlib\Init.olean"
    If ($exists) {
        $script:cacheStatusLabel.Text = $msgTable.installed
        $script:hasCache = $true
    }
}

Function Start-VSCode {
    $exists = Check-AllFileExists-And-Report "scripts\setup_env_variables.cmd" "scripts\start_Lean_VSCode.cmd"
    If ($exists) {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"cd scripts && start_Lean_VSCode.cmd`""
    }
}

Function Start-Bash {
    $exists = Check-AllFileExists-And-Report "scripts\setup_env_variables.cmd" "scripts\start_Lean_bash.cmd"
    If ($exists) {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"cd scripts && start_Lean_bash.cmd`""
    }
}

Function Do-UnpackCache {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"cd scripts && unpack_cache.cmd /y`"" -Wait
    Start-Sleep 0.1
    Check-CacheStatus
}

Function Unpack-Cache {
    $exists = Check-AllFileExists-And-Report "scripts\setup_env_variables.cmd" "scripts\unpack_cache.cmd"
    If (-Not $exists) {
        Return
    }
    $title = If ($script:hasCache) { $msgTable.cacheAlreadyExists } Else { $msgTable.unpackCache }
    $msg = If ($script:hasCache) { $msgTable.cacheAlreadyExistsMsg } Else { $msgTable.unpackCacheMsg }
    $msg = $msg + "`n`n" + $msgTable.unpackCacheTime
    $ret = [System.Windows.Forms.MessageBox]::Show($msg, $title, "YesNo", "Question")
    If ($ret -ne [System.Windows.Forms.DialogResult]::Yes) {
        Return
    }
    Do-UnpackCache
}

Function Unpack-And-Start-VSCode {
    $exists = Check-AllFileExists-And-Report "scripts\setup_env_variables.cmd" "scripts\unpack_cache.cmd" "scripts\start_Lean_VSCode.cmd"
    If (-Not $exists) {
        Return
    }
    If (-Not $script:hasCache) {
        $msg = $msgTable.firstTimeUse + "`n" + $msgTable.firstTimeUse2 + "`n`n- " + $msgTable.firstTimeUse3 + " " + $msgTable.unpackCacheTime + "`n- " + $msgTable.firstTimeUse4
        $ret = [System.Windows.Forms.MessageBox]::Show($msg, $msgTable.unpackCache, "YesNo", "Question")
        If ($ret -eq [System.Windows.Forms.DialogResult]::Yes) {
            Do-UnpackCache
        }
    }
    Start-VSCode
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$leanImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\lean_logo.png")
$editImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\edit.png")
$terminalImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\terminal.png")
$startImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\start.png")
$stopImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\stop.png")
$searchImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\search.png")
$unpackImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\unpack.png")

$mainForm = [System.Windows.Forms.Form]::new()
$mainForm.ClientSize = '800, 480'
$mainForm.Text = $msgTable.formTitle

$mainPanel = [System.Windows.Forms.TableLayoutPanel]::new()
$mainPanel.Dock = "Fill"
$mainPanel.Padding = 4
$mainPanel.RowCount = 1
$mainPanel.ColumnCount = 1
[void]$mainPanel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 100))
[void]$mainPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 100))
$mainForm.Controls.Add($mainPanel)

$tabControl = [System.Windows.Forms.TabControl]::new()
$tabControl.Dock = "Fill"
$mainPanel.Controls.Add($tabControl)

$tabPage = [System.Windows.Forms.TabPage]::new()
$tabPage.Text = $msgTable.home
$tabControl.Controls.Add($tabPage)

$subPanel = [System.Windows.Forms.TableLayoutPanel]::new()
$subPanel.Dock = "Fill"
$subPanel.Padding = 4
$subPanel.RowCount = 1
$subPanel.ColumnCount = 1
[void]$subPanel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 100))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 100))
$tabPage.Controls.Add($subPanel)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.oneClickStart
$button.Image = $leanImage
$button.Add_Click({ Unpack-And-Start-VSCode })
$subPanel.Controls.Add($button)

$tabPage = [System.Windows.Forms.TabPage]::new()
$tabPage.Text = $msgTable.offlineHelp
$tabControl.Controls.Add($tabPage)

$subPanel = [System.Windows.Forms.TableLayoutPanel]::new()
$subPanel.Dock = "Fill"
$subPanel.Padding = 4
$subPanel.RowCount = 1
$subPanel.ColumnCount = 3
[void]$subPanel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 100))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 33.33))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 33.33))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 33.33))
$tabPage.Controls.Add($subPanel)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.startServer
$button.Image = $startImage
$subPanel.Controls.Add($button)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.stopServer
$button.Image = $stopImage
$button.Enabled = $false
$subPanel.Controls.Add($button)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.showHelp
$button.Image = $searchImage
$button.Enabled = $false
$subPanel.Controls.Add($button)

$tabPage = [System.Windows.Forms.TabPage]::new()
$tabPage.Text = $msgTable.advanced
$tabControl.Controls.Add($tabPage)

$panel = [System.Windows.Forms.TableLayoutPanel]::new()
$panel.Dock = "Fill"
$panel.Padding = 4
$panel.RowCount = 2
$panel.ColumnCount = 1
[void]$panel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 50))
[void]$panel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 50))
[void]$panel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 100))
$tabPage.Controls.Add($panel)

$groupBox = [System.Windows.Forms.GroupBox]::new()
$groupBox.Dock = "Fill"
$groupBox.Text = $msgTable.unpackCache
$panel.Controls.Add($groupBox)

$subPanel = [System.Windows.Forms.TableLayoutPanel]::new()
$subPanel.Dock = "Fill"
$subPanel.Padding = 4
$subPanel.RowCount = 1
$subPanel.ColumnCount = 2
[void]$subPanel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 100))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 50))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 50))
$groupBox.Controls.Add($subPanel)

$subGroupBox = [System.Windows.Forms.GroupBox]::new()
$subGroupBox.Dock = "Fill"
$subGroupBox.Text = $msgTable.cacheStatus
$subPanel.Controls.Add($subGroupBox)

$cacheStatusLabel = [System.Windows.Forms.Label]::new()
$cacheStatusLabel.Dock = "Fill"
$cacheStatusLabel.TextAlign = "MiddleCenter"
$subGroupBox.Controls.Add($cacheStatusLabel)

Check-CacheStatus

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.unpackCache
$button.Image = $unpackImage
$button.Add_Click({ Unpack-Cache })
$subPanel.Controls.Add($button)

$groupBox = [System.Windows.Forms.GroupBox]::new()
$groupBox.Dock = "Fill"
$groupBox.Text = $msgTable.startBundle
$panel.Controls.Add($groupBox)

$subPanel = [System.Windows.Forms.TableLayoutPanel]::new()
$subPanel.Dock = "Fill"
$subPanel.Padding = 4
$subPanel.RowCount = 1
$subPanel.ColumnCount = 2
[void]$subPanel.RowStyles.Add([System.Windows.Forms.RowStyle]::new("Percent", 100))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 50))
[void]$subPanel.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new("Percent", 50))
$groupBox.Controls.Add($subPanel)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.startVSCode
$button.Image = $editImage
$button.Add_Click({ Start-VSCode })
$subPanel.Controls.Add($button)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.startBash
$button.Image = $terminalImage
$button.Add_Click({ Start-Bash })
$subPanel.Controls.Add($button)

[void]$mainForm.ShowDialog()
