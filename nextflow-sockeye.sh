#!/bin/bash

module load git
module load singularity
./nextflow -c sockeye.config $@