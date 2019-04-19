#!/bin/sh

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hm] [-c CXX_FLAGS] [-b Branch name]...
Set up gadgetron with debug flags.

    -h          display this help and exit
    -m          Compile with memory leakage checking
    -c          Compile with cxx flags
    -b          The branch to work with
    -g          Generator ("Unix Makefiles" or "Eclipse CDT4 - Unix Makefiles")
    -t          Build type (Release, Debug, RelWithDebugInfo)
    -r          Remove all folders before setting up
    -s          Suffix for build folder, e.g. "_eclipse"
    -w          Gadgetron working directory, default it is "~"

    -m -b master -g "Unix Makefiles" -t Debug -r 
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
BRANCHNAME=master
CXX_FLAGS=

# Generator
GENERATOR="Unix Makefiles"
BUILD_TYPE=Release
remove_flag=0
suffix=

export GT_WORKING_DIR=/home/${USER}
export GADGETRON_HOME=~/local 
export ISMRMRD_HOME=~/local
export PATH=$PATH:$GADGETRON_HOME/bin:$ISMRMRD_HOME/bin 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ISMRMRD_HOME/lib:$GADGETRON_HOME/lib

while getopts "h?c:mb:g:t:rs:w:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  CXX_FLAGS=$OPTARG
        ;;
    m)  CXX_FLAGS="-fsanitize=leak -fPIC"
        ;;
    b)  BRANCHNAME=$OPTARG
        ;;
    g)  GENERATOR=$OPTARG
        ;;
    t)  BUILD_TYPE=$OPTARG
        ;;
    r)  remove_flag=1
        ;;
    s)  suffix=$OPTARG
        ;;
    w)  GT_WORKING_DIR=$OPTARG
    ;;

    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "GT_WORKING_DIR=$GT_WORKING_DIR, BRANCHNAME=$BRANCHNAME, CXX_FLAGS='$CXX_FLAGS', GENERATOR='$GENERATOR', BUILD_TYPE='$BUILD_TYPE', remove_flag='$remove_flag', suffix='$suffix' "

export GT_INSTALL_DIR=${GT_WORKING_DIR}/local

gcc_v=$(gcc -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$/&00/')
echo "gcc version is ${gcc_v}"

if [ $gcc_v -gt 6 ]
then
    NVCC_FLAG="'-ccbin gcc-6'"
else
    NVCC_FLAG=""
fi
echo "NVCC_FLAG is ${NVCC_FLAG}"

# --------------------------------------------------------------------------------------------
# github

ISMRMRD_REPO=git@github.com:ismrmrd/ismrmrd.git
ISMRMRD_BRANCH=${BRANCHNAME}

GT_REPO=git@github.com:gadgetron/gadgetron.git
GT_BRANCH=${BRANCHNAME}

GT_CONVERTER_REPO=git@github.com:ismrmrd/siemens_to_ismrmrd.git
GT_CONVERTER_BRANCH=${BRANCHNAME}

ISMRMRD_PYTHON_API_REPO=git@github.com:ismrmrd/ismrmrd-python.git
ISMRMRD_PYTHON_API_BRANCH=${BRANCHNAME}

ISMRMRD_PYTHON_TOOLS_REPO=git@github.com:ismrmrd/ismrmrd-python-tools.git
ISMRMRD_PYTHON_TOOLS_BRANCH=${BRANCHNAME}

# ----------------------------------------------------------------------------------------------------------
# clean the installation
# ----------------------------------------------------------------------------------------------------------
if [ "$remove_flag" -eq "1" ]; then
    rm -R -f ${GT_WORKING_DIR}/local
    mkdir ${GT_WORKING_DIR}/local
fi

# ----------------------------------------------------------------------------------------------------------
# ismrmrd
# ----------------------------------------------------------------------------------------------------------

if [ "$remove_flag" -eq "1" ]; then
    rm -R -f ${GT_WORKING_DIR}/mrprogs/ismrmrd
    cd ${GT_WORKING_DIR}/mrprogs
    git clone ${ISMRMRD_REPO} ${GT_WORKING_DIR}/mrprogs/ismrmrd
    cd ${GT_WORKING_DIR}/mrprogs/ismrmrd
    git checkout -b ${ISMRMRD_BRANCH} origin/${ISMRMRD_BRANCH}
    rm -R -f ${GT_WORKING_DIR}/mrprogs/build_ismrmrd_${BUILD_TYPE}${suffix}
    cd ${GT_WORKING_DIR}/mrprogs
    mkdir build_ismrmrd_${BUILD_TYPE}${suffix}
fi

cd ${GT_WORKING_DIR}/mrprogs/build_ismrmrd_${BUILD_TYPE}${suffix}
cmake -G "${GENERATOR}" -DCMAKE_INSTALL_PREFIX=${GT_INSTALL_DIR} -DCMAKE_CXX_FLAGS=${CXX_FLAGS} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DJava_JAVAC_EXECUTABLE= -DJava_JAVA_EXECUTABLE= -DJAVA_INCLUDE_PATH=  ../ismrmrd
make -j $(nproc)
make install

# ----------------------------------------------------------------------------------------------------------
# gadgetron
# ----------------------------------------------------------------------------------------------------------

if [ "$remove_flag" -eq "1" ]; then
    rm -R -f ${GT_WORKING_DIR}/mrprogs/gadgetron
    cd ${GT_WORKING_DIR}/mrprogs
    git clone  ${GT_REPO} ${GT_WORKING_DIR}/mrprogs/gadgetron
    cd ${GT_WORKING_DIR}/mrprogs/gadgetron
    git checkout -b ${GT_BRANCH}

    rm -R -f ${GT_WORKING_DIR}/mrprogs/build_gadgetron_${BUILD_TYPE}${suffix}
    cd ${GT_WORKING_DIR}/mrprogs
    mkdir build_gadgetron_${BUILD_TYPE}${suffix}
fi

cd ${GT_WORKING_DIR}/mrprogs/build_gadgetron_${BUILD_TYPE}${suffix}
if [ $gcc_v -gt 6 ]
then
    cmake -G "${GENERATOR}" -DCMAKE_INSTALL_PREFIX=${GT_INSTALL_DIR} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DISMRMRD_INCLUDE_DIR=${GT_INSTALL_DIR}/include -DISMRMRD_LIBRARY=${GT_INSTALL_DIR}/lib/libismrmrd.so -DISMRMRD_LIB_DIR=${GT_INSTALL_DIR}/lib -DISMRMRD_SCHEMA_DIR=${GT_INSTALL_DIR}/share/ismrmrd/schema -DCUDA_NVCC_FLAGS="-ccbin gcc-6" -DCMAKE_CXX_FLAGS=${CXX_FLAGS} -DBUILD_WITH_PYTHON3=ON -DUSE_MKL=ON ../gadgetron
else
    cmake -G "${GENERATOR}" -DCMAKE_INSTALL_PREFIX=${GT_INSTALL_DIR} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DISMRMRD_INCLUDE_DIR=${GT_INSTALL_DIR}/include -DISMRMRD_LIBRARY=${GT_INSTALL_DIR}/lib/libismrmrd.so -DISMRMRD_LIB_DIR=${GT_INSTALL_DIR}/lib -DISMRMRD_SCHEMA_DIR=${GT_INSTALL_DIR}/share/ismrmrd/schema -DBUILD_WITH_PYTHON3=ON -DUSE_MKL=ON -DCMAKE_CXX_FLAGS=${CXX_FLAGS} ../gadgetron
fi

make -j $(nproc)
make install

# ----------------------------------------------------------------------------------------------------------
#ISMRMRD PYTHON API
# ----------------------------------------------------------------------------------------------------------
cd ${GT_WORKING_DIR}/mrprogs
git clone ${ISMRMRD_PYTHON_API_REPO}
cd ismrmrd-python
sudo python3 setup.py install

# ----------------------------------------------------------------------------------------------------------
#ISMRMRD PYTHON TOOLS
# ----------------------------------------------------------------------------------------------------------
cd ${GT_WORKING_DIR}/mrprogs
git clone ${ISMRMRD_PYTHON_TOOLS_REPO}
cd ismrmrd-python-tools
sudo python3 setup.py install

# ----------------------------------------------------------------------------------------------------------
# siemens_to_ismrmrd
# ----------------------------------------------------------------------------------------------------------

if [ "$remove_flag" -eq "1" ]; then
    rm -R -f ${GT_WORKING_DIR}/mrprogs/siemens_to_ismrmrd
    cd ${GT_WORKING_DIR}/mrprogs
    git clone  ${GT_CONVERTER_REPO}  ${GT_WORKING_DIR}/mrprogs/siemens_to_ismrmrd
    cd ${GT_WORKING_DIR}/mrprogs/siemens_to_ismrmrd
    git checkout -b ${GT_CONVERTER_BRANCH} origin/${GT_CONVERTER_BRANCH}

    rm -R -f ${GT_WORKING_DIR}/mrprogs/build_siemens_to_ismrmrd_${BUILD_TYPE}${suffix}
    cd ${GT_WORKING_DIR}/mrprogs
    mkdir build_siemens_to_ismrmrd_${BUILD_TYPE}${suffix}
fi

cd ${GT_WORKING_DIR}/mrprogs/build_siemens_to_ismrmrd_${BUILD_TYPE}${suffix}
cmake -G "${GENERATOR}" -DCMAKE_INSTALL_PREFIX=${GT_INSTALL_DIR} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DISMRMRD_INCLUDE_DIR=${GT_INSTALL_DIR}/include -DISMRMRD_LIBRARY=${GT_INSTALL_DIR}/lib/libismrmrd.so -DISMRMRD_LIB_DIR=${GT_INSTALL_DIR}/lib -DISMRMRD_SCHEMA_DIR=${GT_INSTALL_DIR}/share/ismrmrd/schema ../siemens_to_ismrmrd
make -j $(nproc)
make install

# ----------------------------------------------------------------------------------------------------------
# make gt ready
# ----------------------------------------------------------------------------------------------------------

cp -f ${GT_INSTALL_DIR}/share/gadgetron/config/gadgetron.xml.example ${GT_INSTALL_DIR}/share/gadgetron/config/gadgetron.xml
mkdir ${GT_INSTALL_DIR}/DebugOutput

