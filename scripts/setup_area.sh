#!/bin/bash

#
# This script sets up the release/root version for the area
# to run over the requested supernt_analyze tag.
#
# Aaron Soffa
# asoffa@cern.ch
# September 2017
#

rootver=6.04.14-x86_64-slc6-gcc49-opt

original_dir=$PWD
project_dir=$(dirname ${BASH_SOURCE[0]})/..

#-----------------------------------------------------------

print_usage() {
    echo 'Usage:'
    echo 'source setup_area [--clean] [--help]'
    echo ' --clean:  clean environment by calling'
    echo '              `rc find_packages`,      '
    echo '              `rc clean`,              '
    echo '              `rc compile`             '
    echo
    echo ' --help:   print this message          '
}

#-----------------------------------------------------------

setup_area() {
    cd $project_dir
    local clean=$1

    echo "Setting up ATLAS environment ..."
    export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
    source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh ""  # "" needed here to avoid propagating args of this script

    echo
    echo "Setting up ROOT ${rootver}"
    lsetup "root ${rootver} --skipConfirm"
    #lsetup root

    echo
    echo "Setting up RootCore ..."
    # if rootcore is already set up, clean up the env
    if [[ -d ${ROOTCOREDIR} ]];
    then
        source ${ROOTCOREDIR}/scripts/unsetup.sh
    fi
    
    source RootCore/scripts/setup.sh

    if [[ $clean ]]
    then
        rc find_packages
        rc clean
        rc compile
    fi

    echo
    echo "Done."

    cd $original_dir
}

#-----------------------------------------------------------

main() {
    # parse as in
    # http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
    local clean=""
    local help=""
    while [[ $# > 0 ]]
    do
        key="$1"
        case $key in
            --clean)
                clean=true
                ;;
            -h|--help)
                help=true
                ;;
            *)
                # unknown option
                ;;
        esac
        shift # past argument or value
    done

    if [[ $help ]]
    then
        print_usage
    else
        setup_area $clean
    fi
}

#-----------------------------------------------------------

main $*

