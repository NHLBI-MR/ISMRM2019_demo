#!/bin/sh

# -------------------------------------------------------------------------------

ismrmrd2png()
{
    fname=$1
    [ "$fname" == "" ] && fname="out.h5"

    if [ ! -f "$fname" ]; then
	echo "$0: $fname not found"
	return
    fi
    
    group_name=$( h5ls "$fname" | cut -d ' ' -f 1,2 | sed -e 's@\\@@' )

    imgsets=$( h5ls "$fname"/"$group_name" | cut -d ' ' -f 1 )

    for imgset in $imgsets; do

	line=$( h5ls $fname/"$group_name"/"$imgset" | egrep '^data' )
	nslice=$( echo $line | sed -e 's@.*{@@' -e 's@/.*@@')

	for (( slice=0; slice<$nslice; ++slice )); do
	    h5topng -x $slice -r -d "$group_name"/$imgset/data -o temp.png out.h5
	    convert temp.png -transpose ${imgset}_$( printf "%02d" $slice ).png 
	done
	rm -f temp.png
    done
}

# -------------------------------------------------------------------------------


ismrmPrompt() 
{ 
    [ $TERM=="xterm" ] && TERM=xterm-256color;
    PS1='\[$( tput sgr0 )\]';
    PS1+='\[$( tput bold; tput setaf 10 )\]${PROMPT_HOST}:'
    PS1+='\[$( tput bold; tput setaf  4 )\]$( basename "$PWD" )\$ ';
    PS1+='\[${txtcol:=$( tput setaf 11 )}\]';
    trap - DEBUG;
    trap '[ "$txtcol" != "" ] && { unset txtcol; printf $(tput sgr0); }' DEBUG
}

# -------------------------------------------------------------------------------
# Clean up for demo

ismrmClean()
{
    [ ! -d "$ISMRM_DEMO_HOME" ] && {
	echo "ISMRM_DEMO_HOME not set: skipping"
	return
    }

    ( cd $ISMRM_DEMO_HOME;
    
      rm -rfv \
	 GE_converter_demo/sampleData/*/*.png \
	 GE_converter_demo/sampleData/2dB0Map/out.gif  \
	 GE_converter_demo/sampleData/2dB0Map/out.h5  \
	 GE_converter_demo/sampleData/2dB0Map/testdata.h5  \
	 GE_converter_demo/sampleData/epi/26939/  \
	 GE_converter_demo/sampleData/epi/MRconfig.cfg  \
	 GE_converter_demo/sampleData/epi/gw_coils.dat  \
	 GE_converter_demo/sampleData/epi/out.h5  \
	 GE_converter_demo/sampleData/epi/ref.h5  \
	 GE_converter_demo/sampleData/epi/rowflip.param  \
	 GE_converter_demo/sampleData/epi/testdata.h5  \
	 GE_converter_demo/sampleData/epi/vrgf_kernels.dat

      find . -type f -name '.DS_Store' -exec rm {} \;
    )
}

# -------------------------------------------------------------------------------
# Docker type specific setups

ismrmCmds()
{
    clear
    cd "$ISMRM_DEMO_HOME"/GE_converter_demo/sampleData

    if [ "$ISMRM_DEMO_DATA" == "" ]; then
	PS3="Which demo? : "
	select demo in * ; do break; done
	export ISMRM_DEMO_DATA="$demo"
    fi
    
    cd $ISMRM_DEMO_DATA

    clear;
    echo "Set up for $ISMRM_DEMO_TYPE" demo with "$ISMRM_DEMO_DATA"
    
    history -c
    case "$ISMRM_DEMO_TYPE" in
	GADGETRON)
	    history -r .ismrm_gadgetron_cmds.txt
	    cp .ismrm_gadgetron_cmds.txt /root/.bash_history
	    ;;
	
	CONVERTER)
	    history -r .ismrm_converter_cmds.txt
	    cp .ismrm_converter_cmds.txt /root/.bash_history
	    ;;
    esac
}

# -------------------------------------------------------------------------------
# Docker type specific setups

ismrmSetupConverter()
{
    export ISMRM_DEMO_TYPE="CONVERTER";
    export PROMPT_HOST="GE-2-ismrmrd";
    printf '\e]1;%s\a' 'GE -> ISMRM'
}

ismrmSetupGadgetron()
{
    export ISMRM_DEMO_TYPE="GADGETRON";
    export PROMPT_HOST="Gadgetron";
    printf '\e]1;%s\a' 'Gadgetron'
}

# -------------------------------------------------------------------------------
# Generic Environment setup

ismrmSetupDemo()
{
    export HOME=$ISMRM_DEMO_HOME
    export ISMRM_DEMO_PREFIX=/usr/local
    export SDKTOP=$ISMRM_DEMO_PREFIX/orchestra
    export ISMRMRD_HOME=$ISMRM_DEMO_PREFIX
    export GE_TOOLS_HOME=$ISMRM_DEMO_PREFIX
    export PATH=$PATH:$ISMRMRD_HOME/bin:$GE_TOOLS_HOME/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ISMRMRD_HOME/lib:$GE_TOOLS_HOME/lib
    export HDF5_ROOT=$SDKTOP/include/recon/3p/Linux/hdf5-1.8.12_dev_linux64

    unset ISMRM_DEMO_DATA

    alias ..='cd ..'
    alias cp='cp -i'
    alias mv='mv -i'
    alias rm='rm -i'
    alias rm='rm -i'
    alias h='history'
    alias hfind='history | egrep'
    
    if [ -d "/usr/local/orchestra" ]; then
	ismrmSetupConverter
    elif [ -x "/usr/local/bin/gadgetron" ] ; then
	ismrmSetupGadgetron
    fi

    # Clean the sampleData directories
    ismrmClean
    
    # Set the prompt
    ismrmPrompt

    # Choose the Demo
    ismrmCmds
}

# Main routines

if [ -f /etc/issue ]; then
    export ISMRM_DEMO_HOME=/home/derbyshj/2019-ISMRM-demo
    [ -d "$ISMRM_DEMO_HOME" ] && ismrmSetupDemo
else
    echo "This is not a Linux system!"
fi
