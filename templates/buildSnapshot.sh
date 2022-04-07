#!/bin/bash

set -e

cd ${snapshotPath}
./gradlew installDist
cd -
ln -s ${snapshotPath}/build/install/`ls ${snapshotPath}/build/install/` code
