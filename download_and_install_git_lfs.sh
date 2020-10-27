#!/bin/bash
#
# install git-lfs

mkdir git_lfs
cd git_lfs
curl -L https://github.com/git-lfs/git-lfs/releases/download/v2.12.0/git-lfs-linux-386-v2.12.0.tar.gz \
     --output git-lfs-linux-386-v2.12.0.tar.gz

tar -xf git-lfs-linux-386-v2.12.0.tar.gz

./install.sh

git lfs install

rm git-lfs-linux-386-v2.12.0.tar.gz

cd ..
