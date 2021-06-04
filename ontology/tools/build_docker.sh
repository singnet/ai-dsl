#!/bin/bash

echo "Building SigmaKEE..."
docker build -t sigmakee:kabir .

echo "Coping config.xml..."
docker run --rm -itd --name sigmakee sigmakee:kabir
docker cp sigmakee:/sigma/sigmakee/KBs/config.xml .
docker stop sigmakee

echo "Cloning SUMO..."
git clone https://github.com/nunet-io/ai-dsl.git SUMO

echo "Downloading WordNet..."
wget -q 'http://wordnetcode.princeton.edu/3.0/WordNet-3.0.tar.gz'
tar xf WordNet-3.0.tar.gz
mkdir WordNetMappings
mv WordNet-3.0/dict/* WordNetMappings
cp SUMO/WordNetMappings/* WordNetMappings
sudo rm -r WordNet-3.0*
