#!/bin/bash

rm -r nedry
git clone git@github.com:UBC-Stat-ML/nedry.git
cd nedry
./gradlew installDist
mv build/install/nedry/bin ..
mv build/install/nedry/lib ..
cd ..
rm -r nedry