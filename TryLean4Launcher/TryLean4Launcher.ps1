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

Function Check-CacheStatus {
    $script:cacheStatusLabel.Text = $msgTable.notInstalled
    $script:hasCache = $false
    $exists = Test-Path -Path "projects\LeanPlayground\.lake\packages\mathlib\.lake\build\lib\Mathlib\Init.olean" -PathType Leaf
    $exists2 = Test-Path -Path "projects\LeanPlayground\.lake\packages\mathlib\.lake\build\lib\lean\Mathlib\Init.olean" -PathType Leaf
    If ($exists -Or $exists2) {
        $script:cacheStatusLabel.Text = $msgTable.installed
        $script:hasCache = $true
    }
}

$msgTable = Merge-Hashtables $msgTable $localizedMsgTable

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
$subPanel.Controls.Add($button)

$button = [System.Windows.Forms.Button]::new()
$button.Dock = "Fill"
$button.TextImageRelation = "ImageAboveText"
$button.Text = $msgTable.startBash
$button.Image = $terminalImage
$subPanel.Controls.Add($button)

[void]$mainForm.ShowDialog()
