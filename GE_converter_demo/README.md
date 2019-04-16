
# ISMRM 2019 GE to ISMRMRD converter demo

## Requirements for this session of the demo

1.  Container environment with Gadgetron installed (container used in previous class sections should suffice).

1.  Another container, *without* system provided HDF5, but with all other requirements needed to build ISMRMRD.
    One built from [this repository](https://github.com/nih-fmrif/dockerImage4DevMR) should work for this demo,
    as should a copy of the default gadgetron container, but with all system HDF5 libraries removed.

1.  **Linux** Orchestra environment, already installed in container without system HDF5, or on user's host system,
    and can be mounted to container.

