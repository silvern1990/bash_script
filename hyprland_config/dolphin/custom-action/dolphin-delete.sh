#!/bin/bash

for file in "$@"; do
    dir=$(dirname -- "$file")
    name=$(basename -- "$file")

    rm -f -- "$file"

done
