#!/bin/bash

# comment out the following lines to turn off line-by-line mode
#set -x
#trap read debug

echo "Building SigmaKEE..."
docker build -t sigmakee:kabir .

#echo "Coping config.xml..."
#docker run --rm -itd --name sigmakee sigmakee:kabir
#docker cp sigmakee:config.xml .
#docker stop sigmakee

echo "Cloning SUMO..."
git clone https://github.com/nunet-io/sumo.git SUMO

echo "Downloading WordNet..."
wget -q 'http://wordnetcode.princeton.edu/3.0/WordNet-3.0.tar.gz'
tar xf WordNet-3.0.tar.gz
mkdir WordNetMappings
mv WordNet-3.0/dict/* WordNetMappings
cp SUMO/WordNetMappings/* WordNetMappings
sudo rm -r WordNet-3.0*

echo 'Copying AI-DSL ontologies to SUMo dir'
cp ../*.kif ./SUMO
