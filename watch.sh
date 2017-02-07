#!/usr/bin/env bash

shopt -s globstar

songName="$1"
shift

find . -name "src.ck" -print0 | entr -cr bash -c "./build.sh $songName && ./run.sh $*"
