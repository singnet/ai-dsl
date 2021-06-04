#!/bin/bash

KBDIR=/sigma/sigmakee/KBs
PWD=`pwd`
echo $PWD

DOCKER_RUN="docker run \
            -it --rm \
            --name sigmakee \
            -p 8080:8080 \
            --mount type=bind,src=$PWD/SUMO,dst=$KBDIR \
            --mount type=bind,src=$PWD/config.xml,dst=$KBDIR/config.xml \
            --mount type=bind,src=$PWD/WordNetMappings,dst=$KBDIR/WordNetMappings \
            sigmakee:kabir"

$DOCKER_RUN
