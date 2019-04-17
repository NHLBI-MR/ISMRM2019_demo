# Getting started with the Orchestra to ISMRMRD converter library

Orchestra conversion tools

## Steps and commands to build and install the tools, convert GE raw files into ISMRMRD files, and perform reconstructions using the Gadgetron:

1.  Set an installation prefix for all software being built and installed here:

    ```bash
    export ISMRM_DEMO_PREFIX=/usr/local
    ```

1.  Start the container for this portion of the demo with a command something like:

    ```bash
    docker run --name ismrm2019DemoGE -e ISMRM_DEMO_PREFIX=$ISMRM_DEMO_PREFIX -v /Users:/home -v $PATH_to_local/orchestra-sdk-1.7-1/:$ISMRM_DEMO_PREFIX/orchestra --entrypoint "bash" -it fmrif:ismrm2019Demo
    ```

1.  Define the `SDKTOP` environment variable:

    ```bash
    export SDKTOP=$ISMRM_DEMO_PREFIX/orchestra
    ```

1. Define the `ISMRMRD_HOME` AND `GE_TOOLS_HOME` variables. These specify installation location(s), e.g.

    ```bash
    export ISMRMRD_HOME=$ISMRM_DEMO_PREFIX
    export GE_TOOLS_HOME=$ISMRM_DEMO_PREFIX
    ```

1. It's also useful to extend your home environment to include these new locations and the resourses in them

    ```bash
    export PATH=$PATH:$ISMRMRD_HOME/bin:$GE_TOOLS_HOME/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ISMRMRD_HOME/lib:$GE_TOOLS_HOME/lib
    ```

1.  Go to the included ISMRMRD source code folder:

    ```bash
    cd $PATH_to_class_folder/ismrmrd
    ```

1.  Pre-define the location of HDF5 in order to use Orchestra's static HDF5 library:

    ```bash
    export HDF5_ROOT=$SDKTOP/include/recon/3p/Linux/hdf5-1.8.12_dev_linux64
    ```

    Any other version of HDF5 on the system can cause conflicts as cmake will find all versions, and
    will cause issues or conflicts with the build process.  For these instructions to work, only the
    HDF5 supplied with Orchestra should be on the system.

1. Configure, compile, and install ISMRMRD:

    ```bash
    mkdir build
    cd build/
    cmake -D Boost_INCLUDE_DIR=$SDKTOP/include/recon/3p/Linux/boost_1_55_0_dev_linux64/include/ -D CMAKE_INSTALL_PREFIX=$ISMRMRD_HOME -D HDF5_USE_STATIC_LIBRARIES=yes ..
    make
    make install
    ```

1. Navigate to the GE converter source code folder:

    ```bash
    cd ../../ge_to_ismrmrd_converter/
    ```

1. Configure, compile and install the converter:

    ```bash
    mkdir build
    cd build/
    cmake -D CMAKE_INSTALL_PREFIX=$GE_TOOLS_HOME ..
    make install
    ```

1. Navigate to the 'sampleData' directory. A typical command line to convert the supplied P-file using this library is:

   ```bash
   pfile2ismrmrd -v -l libp2i-generic.so -p GenericConverter -x $GE_TOOLS_HOME/share/ge-tools/config/default.xsl P25088.7
   ```

1. Similarly, a typical command line to convert an example ScanArchive file using this library is:

   ```bash
   pfile2ismrmrd -v -l libp2i-generic.so -p GenericConverter -x $GE_TOOLS_HOME/share/ge-tools/config/default.xsl ScanArchive_of_P25088.h5
   ```
   Sample raw data files are now in the 'sampleData' directory.

1. Start the Gadgetron container with the command:

    ```bash
    docker run --name gadgetron -v /Users:/home -t --detach  gadgetron/ubuntu_1804_no_cuda
    ```

1. Enter the running Gadgetron container in an interactive session:

    ```bash
    docker exec -it gadgetron bash
    ```

1. Reconstruct one of the converted data sets by navigating to the directory with the just converted GE raw data file, and sending to Gadgetron:

    ```bash
    gadgetron_ismrmrd_client -f testdata.h5
    ```

1. Reconstruct the converted B0 field-map data set by installing the B0 field map computation gadget, and processing chain, the running the command:

    ```bash
    pushd . (stores the working directory location)
    cd ../../gadgetronExtras
    mkdir build
    cd build
    cmake ..
    make install
    popd
    gadgetron_ismrmrd_client -f testdata.h5 -c fieldMapFloat.xml
    ```

1. Now, in the 'converter' container, navigate to the folder with the sample EPI data, and try to reconstruct as above, i.e.

   ```bash
   pfile2ismrmrd -v -l libp2i-generic.so -p GenericConverter -x $GE_TOOLS_HOME/share/ge-tools/config/epiRT.xsl ScanArchive_301496MR3T6MR_20180829_083635165.h5
   ```

   This should fail (i.e. number of converted acquisitions stored is 0).

1. Use the converter that properly handles EPI data:

   ```bash
   pfile2ismrmrd -v -l libp2i-NIH.so -p NIHepiConverter -x $GE_TOOLS_HOME/share/ge-tools/config/epiRT.xsl ScanArchive_301496MR3T6MR_20180829_083635165.h5
   ```

1. Then back in Gadgetron container, reconstruct this data with the default pipeline (in container with a running Gadgetron-instance):

   ```bash
    gadgetron_ismrmrd_client -f testdata.h5
    ```

1. And then with an reconstruct pipeline that is "EPI-aware" (again, in container with a running Gadgetron-instance):

   ```bash
   pushd .
   cd to 'gtConfigs' directory in the GE converter folder
   cp * $GADGETRON_HOME/share/gadgetron/config/
   popd
   gadgetron_ismrmrd_client -f testdata.h5 -c gtReconExampleGEEPI.xml
   ```

