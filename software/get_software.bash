#!/bin/bash

set -x
set -e

wget https://github.com/lazear/sage/releases/download/v0.14.7/sage-v0.14.7-aarch64-apple-darwin.tar.gz
tar -xzf sage-v0.14.7-aarch64-apple-darwin.tar.gz
cp sage-v0.14.7-aarch64-apple-darwin/sage sage
sage --help

wget https://github.com/Nesvilab/DIA-Umpire/releases/download/v2.2.8/DIA_Umpire_SE-2.2.8.jar

git clone git@github.com:TalusBio/ionmesh.git ionmesh_repo
(cd ionmesh_repo && git checkout fb269e9da84c8f9fd5085c438f0c260da6a2d4a9 && cargo b --release && cp target/release/ionmesh ../ionmesh)
