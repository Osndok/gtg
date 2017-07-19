#!/bin/bash

#Don't let the user execute this as root, it breaks graphical login (Changes /tmp permissions)
if [ $UID -eq 0 ]; then
    echo "GTG shouldn't be run as root, terminating"
    exit
fi

PYTHON_EXE=python3
args="--no-crash-handler"
dataset="default"
norun=0
title=""

# Create execution-time data directory if needed
mkdir -p tmp

# Interpret arguments
while getopts bdns: o
do  case "$o" in
    b)   args="$args --boot-test";;
    d)   args="$args -d";;
    n)   norun=1;;
    s)   dataset="$OPTARG";;
    t)   title="$OPTARG";;
    [?]) echo >&2 "Usage: $0 [-s dataset] [-t title] [-b] [-d] [-l] [-n]"
         exit 1;;
    esac
done

# Copy dataset
if [  $dataset != "default" -a ! -d "./tmp/$dataset" ]
then
    echo "Copying $dataset dataset to ./tmp/"
    mkdir -p tmp
    cp -r data/test-data/$dataset tmp/
fi

echo "Setting XDG vars to use $dataset dataset."
export XDG_DATA_HOME="./tmp/$dataset/xdg/data"
export XDG_CACHE_HOME="./tmp/$dataset/xdg/cache"
export XDG_CONFIG_HOME="./tmp/$dataset/xdg/config"

# Title has to be passed to GTG directly, not through $args
# title could be more word, and only the first word would be taken
if [ -z "$title" ]
then
    title="Dev GTG: $(basename $PWD)"
    if [ "$dataset" != "default" ]
    then
        title="$title ($dataset dataset)"
    fi
fi

if [ $norun -eq 0 ]
then
    PYTHONPATH=$PWD $PYTHON_EXE ./GTG/gtg $args -t "$title"
fi

