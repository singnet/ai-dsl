#!/bin/bash

INPUT=$1
OUTPUT=$2

docker run -v $(pwd):/work \
    minlag/mermaid-cli:latest \
    -i /work/$INPUT \
    --scale 4 \
    -o /work/$OUTPUT.tmp.png \
    --cssFile "/work/mermaid.css"

convert -trim $OUTPUT.tmp.png $OUTPUT
