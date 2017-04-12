#!/bin/bash

set -e

git clone https://github.com/${gitUser}/${gitRepoName}
cd ${gitRepoName}
git reset --hard ${codeRevision}
./gradlew installDist
mv build/install/${gitRepoName} ../code


