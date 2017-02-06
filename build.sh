#!/usr/bin/env bash



rm -rf build
mkdir build

cp -r src/* build
python2 ./generateMidiPorts.py build/midiPorts.m3
cd build || exit
while IFS= read -r -d '' file
do
  m4 "$file" > tmp
  mv tmp "${file%.*}.ck"
done < <(find . -name '*.ck' -print0)

