#!/usr/bin/env bash




rm -rf build
mkdir build

python2 ./generateMidiPorts.py build/midiPorts.m4

cp "songs/$1.ck" build/_cur_song.ck

cp -r src/* build

mkdir build/parts
cp -r parts/* build/parts



cd build/parts || exit

echo "" > ../_all_parts.m4

while IFS= read -r -d '' file
do
  echo "include(parts/$file)" > ../_all_parts.m4
done < <(find . -name '*.ck' -print0)


cd ../ || exit

while IFS= read -r -d '' file
do
  m4 "$file" > tmp
  mv tmp "${file%.*}.ck"
done < <(find . -name '*.ck' -print0)

