#!/usr/bin/env bash



songName="$1"

if [[ "$songName" == "" ]]; then
  rm -rf build
  mkdir build
fi

python2 ./generateMidiPorts.py build/midiPorts.m4



if [[ "$songName" == "" ]]; then
  echo "" > build/_cur_song
else
  echo "Building song: $1"
  cp "$1.ck" build/_cur_song
  cd build || exit
  m4 _cur_song > tmp
  mv tmp _cur_song
  cd .. || exit
fi

rm -rf build/parts
mkdir build/parts
cp -r parts/* build/parts

rm -rf build/instruments
mkdir build/instruments
cp -r instruments/* build/instruments


cd build/parts || exit

echo "" > ../_all_parts.m4

while IFS= read -r -d '' file
do
  echo "include(parts/$file)" >> ../_all_parts.m4
done < <(find . -name '*.ck' -print0)

cd ../../build/instruments || exit

echo "" > ../_all_instruments.m4



while IFS= read -r -d '' file
do
  echo "include(instruments/$file)" >> ../_all_instruments.m4
done < <(find . -name '*.ck' -print0)



cd ../ || exit

if [[ "$songName" == "" ]]; then
  cp -r ../src/* .
  cp -r ../midi_flower .
  while IFS= read -r -d '' file
  do
    m4 "$file" > tmp
    echo "$file"
    mv tmp "$file"
  done < <(find . -name '*.ck' -print0)
fi
