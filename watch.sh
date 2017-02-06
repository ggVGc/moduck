#!/usr/bin/env bash

shopt -s globstar

ls src/** | entr -cr bash -c "./build.sh && ./run.sh $@"
