#!/bin/bash

#
# This script will check out `supernt_analyze` as well as
# the necessary packages/dependencies to run over the tag
# requested by the user.
#
# Aaron Soffa
# asoffa@cern.ch
# September 2017
#

rootcore_version="RootCore-00-04-62"

#-----------------------------------------------------------
print_usage() {
    echo "Usage:"
    echo "source install.sh [--tag <tag>] [--dev] [--help]"
    echo " --tag    checkout tag <tag>"
    echo " --dev    use master branch (default)"
    echo " --help   print this message"
}
#-----------------------------------------------------------
install() {
    local tag="$1"
    local SVNOFF="svn+ssh://svn.cern.ch/reps/atlasoff/"
    local SVNPHYS="svn+ssh://svn.cern.ch/reps/atlasphys/"
    local REPO="git@github.com:asoffa/SS3LAnalyze.git"

    if [ -z ${ATLAS_LOCAL_ROOT_BASE+x} ]
    then
        echo "Setting up ATLAS environment ..."
        export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
        source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh ""  # "" needed here to avoid propagating args of this script
    fi

    echo "Setting up area for `supernt_analyze`..."
    date

    if [ "${tag}" = "" ]
    then
        echo "------------------------------------------------------------"
        echo " You are checking out the master                            "
        echo " branch of supernt_analyze                                  "
        tput setaf 1
        echo " If you mean to read supernt_analyze's                      "
        echo " from the current production, please call this              "
        echo ' script with the `--tag` option.                            '
        tput sgr0
        echo "------------------------------------------------------------"
    else
        echo "------------------------------------------------------------"
        tput setaf 2
        echo " You are checking out tag ${tag} of supernt_analyze         "
        tput sgr0
        echo "------------------------------------------------------------"
    fi

    echo ""
    echo "Cloning supernt_analyze from $REPO"
    git clone $REPO

    if [ "${tag}" = "" ]
    then
        cd supernt_analyze
        echo "Checking out the master branch of supernt_analyze"
        git checkout master
        cd ..
    else
        cd supernt_analyze
        echo "Checking out tag ${tag}"
        git checkout ${tag}
        cd ..
    fi

    echo "Checking out RootCore verion ${rootcore_version}"
    rootURL="$SVNOFF/PhysicsAnalysis/D3PDTools/RootCore/tags/${rootcore_version}"

    echo "Checking out supernt_analyze dependencies"
    svn co $rootURL RootCore || return || exit

    echo
    echo "Finished."
    date
}
#-----------------------------------------------------------
main() {
    # parse as in
    # http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
    local dev=""
    local tag=""
    local help_opt=""
    while [[ $# > 0 ]]
    do
        key="$1"
        case $key in
            --dev)
                dev="true"
                ;;
            -t|--tag)
                tag="$2"
                shift # past argument
                ;;
            -h|--help)
                help_opt=true
                ;;
            *)
                # unknown option
                ;;
        esac
        shift # past option flag
    done

    if [[ ${help_opt} ]]
    then
        print_usage
    elif [[ (${dev} == "" && ${tag} == "") || (${dev} != "" && ${tag} != "") ]]
    then
        echo 'install: must specify one (and only one) of `--tag <tag>` or `--dev`'
        echo 'Run with `--help` for more information.'
    else
        install ${tag} # `tag`="" if `dev`=true as desired
    fi
}

#-----------------------------------------------------------
main $*
