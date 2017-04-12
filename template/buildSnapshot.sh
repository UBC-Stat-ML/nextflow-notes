#!/bin/bash

set -e

cd ${snapshotPath}
./gradlew installDist
cd -
ln -s ${snapshotPath}/build/install/${gitRepoName} code