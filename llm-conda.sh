#!/bin/sh
# Install sysstat on your system and then download simple ai-monitor.py script from github: 
cd ~
git clone https://github.com/pl247/ai-monitor

# Installing Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
chmod -v +x Miniconda3-py39_4.12.0-Linux-x86_64.sh
./Miniconda3-py39_4.12.0-Linux-x86_64.sh

#Create New Conda Environment 
conda create -n textgen python=3.10.9 
conda activate textgen 

#Install pytorch 
pip3 install torch torchvision torchaudio 

#Install web UI 
git clone https://github.com/oobabooga/text-generation-webui 
cd text-generation-webui 
pip install -r requirements.txt 