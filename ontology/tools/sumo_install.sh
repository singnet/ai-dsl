#!/bin/bash

# comment out the following lines to turn off line-by-line mode
set -x
trap read debug

# install everything on sumo directory under home
cd ~
mkdir sumo
cd sumo
mkdir workspace
mkdir Programs
cd Programs
wget 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.zip'
wget 'http://wordnetcode.princeton.edu/3.0/WordNet-3.0.tar.gz'
wget 'http://wwwlehre.dhbw-stuttgart.de/~sschulz/WORK/E_DOWNLOAD/V_2.0/E.tgz'
tar -xvzf E.tgz
unzip apache-tomcat-8.5.23.zip
rm apache-tomcat-8.5.23.zip
cd ~/sumo/Programs/apache-tomcat-8.5.23/bin
chmod 777 *
cd ../webapps
chmod 777 *
cd ~/sumo/workspace/
sudo apt-get install git
git clone https://github.com/ontologyportal/sigmakee
git clone https://github.com/ontologyportal/sumo
cd ~
mkdir .sigmakee
cd .sigmakee
mkdir KBs
cp -R ~/sumo/workspace/sumo/* KBs
me="$(whoami)"
cp ~/sumo/workspace/sigmakee/config.xml ~/.sigmakee/KBs
sed -i "s/theuser/$me/g" KBs/config.xml
cd ~/sumo/Programs
gunzip WordNet-3.0.tar.gz
tar -xvf WordNet-3.0.tar
cp WordNet-3.0/dict/* ~/.sigmakee/KBs/WordNetMappings/
cd ~/sumo/Programs/E
sudo apt-get install make
sudo apt-get install gcc
./configure
make
make install
cd ~
sudo apt-get install graphviz
echo "export SIGMA_HOME=~/.sigmakee" >> .bashrc
echo "export SIGMA_SRC=~/sumo/workspace/sigmakee" >> .bashrc
echo "export ONTOLOGYPORTAL_GIT=~/sumo/workspace" >> .bashrc
echo "export CATALINA_OPTS=\"$CATALINA_OPTS -Xms500M -Xmx7g\"" >> .bashrc
echo "export CATALINA_HOME=~/sumo/Programs/apache-tomcat-8.5.23" >> .bashrc
source .bashrc
cd ~/sumo/workspace/sigmakee
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install ant
ant
