#!/bin/bash

set -e

git clone git@github.com:/${gitUser}/${gitRepoName}
cd ${gitRepoName}
git reset --hard ${codeRevision}
./gradlew installDist
mv build/install/`ls build/install/` ../code


