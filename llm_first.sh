#!/bin/sh
# Update System Packages and GCC Compiler
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential sysstat

# Install CUDA and NVIDIA Drivers
# https://developer.nvidia.com/cuda-12-0-0-download-archive
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin 
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 
wget https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda-repo-ubuntu2204-12-0-local_12.0.0-525.60.13-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-0-local_12.0.0-525.60.13-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-0-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-12-0

# Updating Path with CUDA Version
echo 'export PATH="/usr/local/cuda-12.0/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda-12.0/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc

sudo shutdown -r now
