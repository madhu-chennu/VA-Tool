#!/bin/bash

# Update and upgrade system packages
# sudo apt update && sudo apt upgrade -y

# Install Python3 and pip
# sudo apt-get update
sudo apt install python3-pip

# Remove /bin/go
sudo rm -rf /bin/go

# Update to fix missing packages
# sudo apt update --fix-missing

# Install Golang
sudo apt install golang -y

# Install dirsearch
sudo apt install dirsearch

# Install hakrawler
go install github.com/hakluke/hakrawler@latest

# Install katana
go install github.com/projectdiscovery/katana/cmd/katana@latest
sudo cp ~/go/bin/katana /bin/

# Install nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Install httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Install wapiti3 using pip
pip install wapiti3

# Update and upgrade system packages again
# sudo apt-get update && sudo apt-get upgrade -y
