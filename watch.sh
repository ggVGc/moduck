#!/usr/bin/env bash

shopt -s globstar

songName="$1"
shift

ls {src,songs,parts}/** | entr -cr bash -c "./build.sh $songName && ./run.sh $*"
