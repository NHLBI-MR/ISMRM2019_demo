# Getting started with the Orchestra to ISMRMRD converter library

Orchestra conversion tools

## To build and install the tools to convert GE raw files into ISMRMRD files:

1.  Start the container for this portion of the demo with a command something like:

    ```bash
    docker run --name ismrm2019DemoGE -v /Users:/home -v $HOME/my_root/orchestra-sdk-1.7-1/:/opt/local/orchestra --entrypoint "bash" -it fmrif:ismrm2019Demo
    ```

1.  Define the `SDKTOP` environment variable:

    ```bash
    export SDKTOP=/opt/local/orchestra
    ```

1. Define the `ISMRMRD_HOME` AND `GE_TOOLS_HOME` variables. These specify installation location(s), e.g.

    ```bash
    export ISMRMRD_HOME=<prefix>/ismrmrd
    export GE_TOOLS_HOME=<prefix>/ge-tools
    export GADGETRON_HOME=<prefix>/gadgetron
    ```

1. It's also useful to extend your home environment to include these new locations and the resourses in them

    ```bash
    export PATH=$PATH:$ISMRMRD_HOME/bin:$GE_TOOLS_HOME/bin:$GADGETRON_HOME/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ISMRMRD_HOME/lib:$GE_TOOLS_HOME/lib:$GADGETRON_HOME/lib
    ```

1.  Obtain the ISMRMRD source code:

    ```bash
    git clone https://github.com/ismrmrd/ismrmrd
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
    cd ismrmrd/
    mkdir build
    cd build/
    cmake -D CMAKE_INSTALL_PREFIX=$ISMRMRD_HOME -D HDF5_USE_STATIC_LIBRARIES=yes -D CMAKE_EXE_LINKER_FLAGS="-lpthread -lz -ldl" ..
    make install
    cd ../
    ```

1. Obtain the GE converter source code:

    ```bash
    git clone https://github.com/ismrmrd/ge_to_ismrmrd.git
    ```

1. Configure, compile and install the converter:

    ```bash
    cd ge_to_ismrmrd/
    mkdir build
    cd build/
    cmake -D CMAKE_INSTALL_PREFIX=$GE_TOOLS_HOME ..
    make install
    cd ../
    ```

1. A typical command line to convert the supplied P-file using this library is:

   ```bash
   pfile2ismrmrd -v -l libp2i-generic.so -p GenericConverter -x $GE_TOOLS_HOME/share/ge-tools/config/default.xsl P25088.7
   ```

1. If customized conversion libraries are desired, the corresponding command will be:

   ```bash
   pfile2ismrmrd -v -l libp2i-NIH.so -p NIH2dfastConverter -x $GE_TOOLS_HOME/share/ge-tools/config/default.xsl P25088.7
   ```

   The source code that enables this example is included with these tools.  This example is a straightforward copy of the GenericConverter, but it shows how these classes can be inherited from and implemented.

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

1. Reconstruct one of the converted data sets by sending to Gadgetron:

    ```bash
    gadgetron_ismrmrd_client -f testdata.h5
    ```

1. Reconstruct the converted B0 field-map data set by installing the B0 field map computation gadget, and processing chain, the running the command:

    ```bash
    gadgetron_ismrmrd_client -f testdata.h5 -c fieldMapFloat.xml
    ```

