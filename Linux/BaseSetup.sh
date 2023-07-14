#!/bin/bash

# Set the download directory
DOWNLOAD_DIR="$HOME/Downloads/SW_Setup"

# Set the log file
LOG_FILE="$(pwd)/InstallLog.txt"

# Function to append to log
function log_write {
    DATE=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$DATE - $1" | tee -a $LOG_FILE
}

# Create the download directory if it doesn't exist
if [ ! -d "$DOWNLOAD_DIR" ]; then
    mkdir -p $DOWNLOAD_DIR
    log_write "Created download directory at $DOWNLOAD_DIR"
fi

# Install necessary packages via apt
sudo apt update

packages=("google-chrome-stable" "whatsapp-desktop" "mobaxterm" "pycharm-community" "awscli" "nodejs" "spotify-client" "git" "vscode" "sublimetext" "slack-desktop" "docker-ce" "docker-ce-cli" "containerd.io" "mongodb-compass" "python3" "wsl")
for pkg in "${packages[@]}"; do
    if dpkg -l | grep -q $pkg; then
        log_write "$pkg is already installed, skipping..."
    else
        if sudo apt install -y $pkg; then
            log_write "$pkg installed successfully"
        else
            log_write "Failed to install $pkg"
        fi
    fi
done

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

log_write "All installations finished or encountered error, check the log for details."

log_write "Please install the vscode extensions manually."
