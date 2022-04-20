#!/bin/bash

module load git
module load singularity
module load miniconda3
./nextflow -c sockeye.config $@ -with-report -with-trace -with-timeline -with-dag 