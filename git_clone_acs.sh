#!/bin/bash
#
# git clone ACS repositoy and checkout the branch named "acs/$ACS_VERSION_NAME"
# $ACS_VERSION_NAME is usually something like 2020AUG
#
# script fails if $ACS_VERSION_NAME is not defined.
# script expects git lfs to be installed

set -u # aborts automatically if we try to expand an undefined variable
: "$ACS_VERSION_NAME"  # tries to expand variable in a no-op context.


git clone https://bitbucket.alma.cl/scm/asw/acs.git ./acs
cd ./acs
git checkout acs/$ACS_VERSION_NAME
