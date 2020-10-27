#!/bin/bash
#
# git clone ACS repositoy and checkout the branch named "acs/$ACS_TAG"
# $ACS_TAG is usually something like 2020AUG
#
# script fails if $ACS_TAG is not defined.
# script expects git lfs to be installed
source ./VERSION

set -u # aborts automatically if we try to expand an undefined variable
: "$ACS_TAG"  # tries to expand variable in a no-op context.


git clone https://bitbucket.alma.cl/scm/asw/acs.git ./acs
cd ./acs
git checkout acs/$ACS_TAG
