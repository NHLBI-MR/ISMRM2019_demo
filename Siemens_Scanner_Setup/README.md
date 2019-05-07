# Siemens Scanner Setup Demo 

This demo is to demonstrate how to set up Gadgetron with connection on Siemens MR System.

Steps to setup:
------------------------------------------------------------------

1. Download the IceGadgetron [installer](https://github.com/NHLBI-MR/ISMRM2019_demo/raw/master/Siemens_Scanner_Setup/gadgetron-20190403-1543-d522521c_MARS_VE11C.exe)

2. Download the prebuilt [Gadgetron chroot image](https://gadgetrondata.blob.core.windows.net/ice-gadgetron-installer/gadgetron-20190403-1543-d522521c.img.zip)

3. Copy both files to your MR scanner, e.g. C:/Temp/Gadgetron folder

4. Input scanner upgrade password if any

5. Unzip the chroot image zip file

6. Run the installer by double clicking the .exe file and follow the instructions

7. Copy unzipped chroot image to **C:\MedCom\MriCustomer\ice\gadgetron\chroot**

8. Edit C:\MedCom\MriCustomer\ice\gadgetron\gadgetron.ini to point to your gadgetron server. By default, it will run Gadgetron on MARS.

9. This installer was built for **VE11C**.

More information
------------------------------------------------------------------

For more detailed information and source code of IceGadgetron, please contact:

Hui Xue
hui.xue@nih.gov
