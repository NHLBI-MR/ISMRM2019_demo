# ISMRM2019_demo

![alt text](./Slides/GT.jpg "Gadgetron")

This repo holds the Gadgetron demo materials for the "Open-Source Software Tools for MR Pulse Design, Simulation & Reconstruction", ISMRM 2019, Montreal, Canada.

### Demo and presenters

Demos presented in this repo was prepared by :

**Hui Xue** : National Heart Lung and Blood Institute (NHLBI), National Institutes of Health, Betheda, USA

**David Hansen** : Gradient Software Inc., Denmark 

**Oliver Josephs, Martina Callaghan** : Wellcome Trust Centre for Neuroimaging, London, UK

**Vinai Roopchansingh, John  Derbyshire** : National Institute of Mental Health (NIMH), National Institutes of Health, Betheda, USA

**Valery Ozenne, Aurélien Trotier** : University of Bordeaux, France

**Adri Campbell, Peter Kellman** : National Heart Lung and Blood Institute (NHLBI), National Institutes of Health, Betheda, USA

|                  Demo                 |    Presenter  |
| --------------------------------------|:-------------:|
| Gadgetron installation and setup      | David Hansen  | 
| Build your first gadget chain         | David Hansen  |
| Siemens Scanner Setup                 | Hui Xue       |
| GE scanner interaction                | Vinai Roopchansingh and John  Derbyshire |
| Gadgetron - Matlab for neuro imaging  | Oliver Josephs and Martina Callaghan      |
| Build an AI recon inside Gadgetron    | Hui Xue       |

### AWS virtual machine

A amazon EC2 virtual machine was set up for the demo session. The public dns is :
```
ec2-3-14-64-140.us-east-2.compute.amazonaws.com
```
### AWS instance set up
The gadgetron and ismrmrd are already intalled in this instance.

* Source code is at ~/mrprogs
* Gadgetron is installed at ~/local
* The demo repo is cloned at ~/mrprogs/ISMRM2019_demo

To run the gadgetron, open a terminal and type:
```
gadgetron
```

To run the gadgetron integration test, open another terminal and type:
```
cd ~/mrprogs/gadgetron/test/integration
python3 run_tests.py -G ~/local -I ~/local ./cases/*.cfg
```

### To perform the demo

E.g. the AI demo, open an interminal and type:
```
cd ~/mrprogs/ISMRM2019_demo/AI_in_Gadgetron
jupyter notebook
```
Then open the Grappa.ai.ipynb and run cells.

### Set up the AWS instance
Start an ubuntu 18.04 instance and install following libraries:
```
sudo apt-get update --quiet
sudo apt-get install --no-install-recommends --no-install-suggests --yes software-properties-common apt-utils wget build-essential cython3 emacs python3-dev python3-pip libhdf5-serial-dev cmake git-core libboost-all-dev libfftw3-dev h5utils jq hdf5-tools liblapack-dev libatlas-base-dev libxml2-dev libfreetype6-dev pkg-config libxslt-dev libarmadillo-dev libace-dev gcc-multilib libgtest-dev python3-dev liblapack-dev liblapacke-dev libplplot-dev libdcmtk-dev supervisor cmake-curses-gui neofetch supervisor net-tools cpio libpugixml-dev libopenblas-base libopenblas-dev python3-tk

mkdir ~/software
cd ~/software

#ZFP
cd ~/software && \
git clone https://github.com/hansenms/ZFP.git && \
cd ZFP && \
mkdir lib && \
make && \
make shared && \
sudo make -j $(nproc) install

# BART
cd ~/software && \
git clone https://github.com/mrirecon/bart --branch master --single-branch && \
cd bart && \
mkdir build && \
cd build && \
cmake .. -DBART_FPIC=ON -DBART_ENABLE_MEM_CFL=ON -DBART_REDEFINE_PRINTF_FOR_TRACE=ON -DBART_LOG_BACKEND=ON -DBART_LOG_GADGETRON_BACKEND=ON && \
make -j $(nproc) && \
sudo make install

# Python packages
sudo pip3 install -U pip setuptools
sudo pip3 install numpy==1.15.4 scipy Cython tk-tools matplotlib==2.2.3 scikit-image opencv_python pydicom scikit-learn psutil pyxb lxml Pillow h5py
sudo pip3 install https://download.pytorch.org/whl/cpu/torch-1.0.0-cp36-cp36m-linux_x86_64.whl
sudo pip3 install torchvision
sudo pip3 install --upgrade tensorflow
sudo pip3 install tensorboardx visdom
```
### To compile and install gadgetron
```
cd ~/mrprogs/
git clone https://github.com/NHLBI-MR/ISMRM2019_demo.git
cd ISMRM2019_demo
sh ./setup_gadgetron_local.sh -r -t Release
```
Then add the following to `~/.bashrc`:
```
export GADGETRON_HOME=~/local 
export ISMRMRD_HOME=~/local
export PATH=$PATH:$GADGETRON_HOME/bin:$ISMRMRD_HOME/bin 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ISMRMRD_HOME/lib:$GADGETRON_HOME/lib
```
