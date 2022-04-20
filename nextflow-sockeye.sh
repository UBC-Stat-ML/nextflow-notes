#!/bin/bash

module load git
module load singularity
module load miniconda3
./nextflow -c sockeye.config $@