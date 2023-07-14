# Requesting Admin Privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$arguments`""
    exit
}

# Download Directory
$downloadDir = "$HOME\Downloads\SW_Setup"

# Log file
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "InstallLog.txt"

# Function to append to log
function Log-Write($message) {
    Add-Content -Path $logFile -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - $message"
    Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - $message"
}

# Create Download directory if not exists
If(!(test-path $downloadDir))
{
    New-Item -ItemType Directory -Force -Path $downloadDir
    Log-Write "Created download directory at $downloadDir"
}

# Function to install Chocolatey if not already installed
function Install-Chocolatey {
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        # Install Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Log-Write "Chocolatey installed successfully"
    }
    else {
        Log-Write "Chocolatey is already installed, skipping..."
    }
}

# Function to install software using Chocolatey
# Get the original 'choco' command
$originalChocoCommand = Get-Command 'choco'

# Install Chocolatey
Install-Chocolatey

# Create a proxy function that wraps the original command
function choco {
    # The $args automatic variable contains all the arguments passed to the function
    $arguments = $args -join ' '

    try {
        # Invoke the original command
        & $originalChocoCommand $args -y

        # Check if the first argument is 'install'
        if ($args[0] -eq 'install') {
            # Log success
            Log-Write "Command 'choco $arguments' executed successfully"
        }
    }
    catch {
        # Log error
        if ($args[0] -eq 'install') {
            Log-Write "Failed to execute 'choco $arguments'. Error: $_"
        }
    }
}

# Download and Install each piece of software
choco install googlechrome
choco install whatsapp
choco install mobaxterm
choco install pycharm-community
choco install awscli
choco install nodejs
choco install spotify
choco install git
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
choco install everything
choco install vscode
choco install sublimetext3
choco install slack
choco install docker-desktop
choco install mongodb-compass
choco install python --version=3.10.11
choco install wsl2

Log-Write "All installations finished or encountered error, check the log for details."

Log-Write "Installing vscode extensions..."

# List of extension identifiers
$vscodeExtensions = @(
    "JillMNolan.python-essentials",
    "afractal.node-essentials",
    "TechieCouch.docker-essentials",
    "VisualStudioExptTeam.vscodeintellicode",
    "vscode-icons-team.vscode-icons",
    "jabacchetta.vscode-essentials",
    "GitHub.copilot"
)

# Loop through the list and install each extension
foreach ($extension in $vscodeExtensions) {
    try {
        # Install the extension
        code --install-extension $extension
        Log-Write "VS Code extension '$extension' installed successfully"
    }
    catch {
        Log-Write "Failed to install VS Code extension '$extension'. Error: $_"
    }
}

Log-Write "Installed all vscode extensions."

Log-Write "Initializing VSCode settings..."
# Define the path to settings.json
$settingsPath = "$Env:APPDATA\Code\User\settings.json"

# Function to convert PSObject to Hashtable
function ConvertTo-Hashtable($obj) {
    $hash = @{}
    $obj | Get-Member -MemberType *Property | % { 
        if ($obj.($_.Name) -is [PSCustomObject]) {
            $hash[$_.Name] = ConvertTo-Hashtable $obj.($_.Name)
        } else {
            $hash[$_.Name] = $obj.($_.Name)
        }
    }
    return $hash
}

# Check if settings.json exists and is not empty
if (Test-Path $settingsPath -and (Get-Content $settingsPath -Raw)) {
    # Read the existing settings
    $existingSettingsObject = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

    # Convert the existing settings to a hashtable
    $existingSettings = ConvertTo-Hashtable $existingSettingsObject
} else {
    # If settings.json is missing or empty, create an empty hashtable for existing settings
    $existingSettings = @{}
}

# Define the settings to add
$newSettings = @{
    "workbench.iconTheme" = "vscode-icons"
    "files.autoSave" = "afterDelay"
    "files.autoSaveDelay" = 1000
}

# Add the new settings to the existing ones
foreach ($setting in $newSettings.GetEnumerator()) {
    $existingSettings[$setting.Name] = $setting.Value
}

# Convert the updated settings back to JSON
$settingsJson = $existingSettings | ConvertTo-Json -Depth 100

# Write the settings to settings.json
Set-Content -Path $settingsPath -Value $settingsJson
Log-Write "Finished Initializing VSCode settings."

# Wait for user input before closing
pause
