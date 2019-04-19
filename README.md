# ISMRM2019_demo

![alt text](./Slides/GT.jpg "Gadgetron")

This repo holds the Gadgetron demo materials for the "Open-Source Software Tools for MR Pulse Design, Simulation & Reconstruction", ISMRM 2019, Montreal, Canada.

### Demo and presenters

Demos presented in this repo was prepared by :

**Hui Xue** : National Heart Lung and Blood Institute (NHLBI), National Institutes of Health, Betheda, USA

**David Hansen** : Gradient Software Inc., Denmark 

**Oliver Joseph, Martina Callaghan** : Wellcome Trust Centre for Neuroimaging, London, UK

**Vinai Roopchansingh, John  Derbyshire** : National Institute of Mental Health (NIMH), National Institutes of Health, Betheda, USA

**Valery Ozenne, Aurélien Trotier** : University of Bordeaux, France

**Adri Campbell, Peter Kellman** : National Heart Lung and Blood Institute (NHLBI), National Institutes of Health, Betheda, USA

|                  Demo                 |    Presenter  |
| --------------------------------------|:-------------:|
| Gadgetron installation and setup      | David Hansen  | 
| Build your first gadget chain         | David Hansen  |
| Siemens Scanner Setup                 | Hui Xue       |
| GE scanner interaction                | Vinai Roopchansingh and John  Derbyshire |
| Gadgetron - Matlab for neuro imaging  | Oliver Joseph and Martina Callaghan      |
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
