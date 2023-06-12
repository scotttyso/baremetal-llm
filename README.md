# Cisco UCS Baremetal Deployment for Ubuntu 22.0.4 Large Language Model

## Updates/News

06-11-2023
* Initial Release

### Generate Hash Password

```bash
mkpasswd --method=SHA-512 --rounds=4096
```

### Extend Boot Drive Storage 

* Check to see if drives from storage profile are recognized:

```bash
sudo dmesg | grep sd
df -h
```

* Use lvextend to extend the size of the logical volume, to fill up the remaining space:

```bash
sudo lvextend --extents +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```

* Resize the filesystem in that logical volume

```bash
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

* Check end result:

```bash
df -h
```

### Perform System Update

Update the system using the following commands:

```bash
apt list --installed
sudo apt update
apt list --upgradable
sudo apt -y upgrade
```

### Checking NVIDIA GPU 

* Check what kernel modules are currently loaded:

```bash
lsmod
```

* See what devices are connected to the PCI bus in the server.

```bash
lspci | more
lspci | grep VGA
lspci | grep NVIDIA
```

* Confirm what driver is appropriate for your GPU. No need to download it.

[*Install NVIDIA CUDA*](https://www.nvidia.com/Download/index.aspx?lang=en)

### Installing CUDA and NVIDIA Drivers

* Use the Instructions at the URL below to Install the Appropriate Drivers.

[*Install NVIDIA CUDA*](https://developer.nvidia.com/cuda-downloads)

* Update .bashrc with Path for CUDA Version and load it.

```bash
echo 'export PATH="/usr/local/cuda-<cuda-version>/bin:$PATH"' >> .bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda-<cuda-version>/lib64:$LD_LIBRARY_PATH"' >> .bashrc
source .bashrc  
```

### Reboot the host to activate CUDA Driver

```bash
sudo reboot
```

### Verify version of the NVIDIA CUDA Compiler Driver

```bash
nvcc --version
```

* Test the NVIDIA System Management Interface.

```bash
nvidia-smi
```

## Installing Ai-Monitor Tool

```bash
git clone https://github.com/pl247/ai-monitor
```

Installing Miniconda  

[*Install Conda*](https://learnubuntu.com/install-conda/) 

 
```bash
cd /mnt/data
sudo wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
sudo chmod -v +x Miniconda3-py39_4.12.0-Linux-x86_64.sh
sudo ./Miniconda3-py39_4.12.0-Linux-x86_64.sh
```

## Installing Text Generation UI 

### Create New Conda Environment 

```bash
conda create -n textgen python=3.10.9
conda activate textgen
```

* Install pytorch 

```bash
pip3 install torch torchvision torchaudio
```

 

## Install web UI

```bash
git clone https://github.com/oobabooga/text-generation-webui
cd text-generation-webui
pip install -r requirements.txt
```

### Running the Web UI

```bash
conda activate textgen
cd text-generation-webui
python server.py --listen --auto-devices --chat --model-menu --gpu-memory 35
```
 

* CPU only

```bash
python server.py --listen --cpu --chat --model-menu
```

* With bfloat16 not sure if it is faster or not but requires Ampere GPU

```bash
python server.py --listen --auto-devices --chat --model-menu --gpu-memory 14 --bf16
```

* CPU only = ~4 tokens/s
* GPU = ~7 tokens/s

Flags: 
--cpu (CPU only)
--auto-devices (split across CPU and GPU)
--gpu-memory
--public-api

## As a second try it with 4 gpu

* notice how memory is split across 4 GPU and on model page it is configured

```bash
python server.py --listen --auto-devices --chat --model-menu
```
 

Then browse to http://<your-server>:7860/?__theme=dark

 
## Downloading Additional Models from Hugging Face 

From the webui directory run the download model script

```bash
cd ~/text-generation-webui
```

* Unquantized version of the Vicuna-7B 1.1 model HF format

```bash
python download-model.py TheBloke/vicuna-7B-1.1-HF
```

 

# Unquantized version of the Vicuna-13B 1.1 model HF format 

```bash
python download-model.py TheBloke/vicuna-13B-1.1-HF 
```

## Using the API 


```python
import requests 

def run(prompt: str) -> str: 
    request = { 
        'prompt': prompt, 
        'max_new_tokens': 200, 
        'do_sample': True, 
        'temperature': 0.7, 
        'top_p': 0.5, 
        'typical_p': 1, 
        'repetition_penalty': 1.2, 
        'top_k': 40, 
        'min_length': 0, 
        'no_repeat_ngram_size': 0, 
        'num_beams': 1, 
        'penalty_alpha': 0, 
        'length_penalty': 1, 
        'early_stopping': False, 
        'seed': -1, 
        'add_bos_token': True, 
        'truncation_length': 2048, 
        'ban_eos_token': False, 
        'skip_special_tokens': True, 
        'stopping_strings': [] 
    } 

    response = requests.post(f'http://127.0.0.1:5000/api/v1/generate', json=request) 

    if response.status_code == 200: 
        return response.json()['results'][0]['text'] 

    return "" 

prompt = "hey, whats 1+1?" 
response = run(prompt) 
print(response) # the expected result via ui is '2'. But the result via api is ' \n släktet'. 
```