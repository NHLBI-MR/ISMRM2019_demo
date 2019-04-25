
# ISMRM 2019 GE to ISMRMRD converter demo

## Requirements for this session of the demo

1.  Container environment with Gadgetron installed (container used in previous class sections should suffice).

1.  Another container, *without* system provided HDF5 and pre-built ISMRMRD, but with all other requirements
    needed to build ISMRMRD. One built from [this repository](https://github.com/nih-fmrif/dockerImage4DevMR)
    should work for this demo, as should a copy of the default gadgetron container, but with all system HDF5
    and previously built and and installed ISMRMRD binaries and libraries removed.

1.  **Linux** Orchestra environment, already installed in container without system HDF5, or on user's host system,
    and can be mounted to container.

1.  Please go into the "ge_to_ismrmrd_converter" folder, and go through steps 1-10 of the demonstration, i.e. have
    your environment / container set up, and ISMRMRD and GE-to-ISMRMRD already built, installed, and ready for use,
    if you want to follow along with the class demonstrations in real time.  The build process using Orchestra is
    rather lengthy, and would otherwise not allow any time for demonstration.

