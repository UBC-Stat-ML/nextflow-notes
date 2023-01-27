# Notes on nextflow



## Overview

**Motivations:** testing computational stat methodology requires 1000s of computer experiments. This takes a lot of time, for two reasons:
(1) preparing, debugging and organizing all these runs, and (2), waiting that experiments finish running. 

Scientific workflow systems help decrease both (1) and (2). From personal experience by a factor of 10 or more. 

[Nextflow](https://www.nextflow.io/) is a well documented and scalable scientific workflow system. It is heavily used in the bioinformatics community. This tutorial is more tailored to its use in computational statistics. It is self-contained but if you want later on to read more about nextflow, the documentation is [here](https://www.nextflow.io/docs/latest/index.html).

**High-level idea** behind nextflow and other scientific workflow systems:

- You organize your computation as a directed acyclic graph (DAG). 
- Each node is a computer program. You can mix and match languages, e.g. one node in bash, one in R, etc. 
- An edge from node x to node y encodes that node y needs a file that is output by node x. 

Based on this graph, nextflow will do the following:

- Execute the nodes in the correct order and with as much parallelization as possible.
- Each node runs its own fresh directory, with symlinks to its inputs  (symlink = symbolic link, i.e. file pointing to another one). 
- If you change only a subset of nodes, nextflow can re-run only those that changed plus the ones downstream.
- Same workflow can be used on your laptop and the cluster (e.g. this tutorial tailored for UBC's Sockeye cluster but same principles apply for systems based on PBS, SGE, and many more). When doing cloud execution, nextflow takes care of all the batch submission details.
- Helps setup common experimental design patterns, e.g. full factorial designs ran in parallel. 
- Simplified replication, adding one line of code takes care of running a node in a docker/singularity container. 

## Prerequisites

- No need to install nextflow, instead just clone this repo which includes the specific nextflow version we will need.
- Unix (mac, linux, wsl, etc)
- Java **11** (check with `java -version`; use [sdk man](https://sdkman.io/) to make sure you use exactly version 11, not higher, not lower; Java recently got worse at cross version compatibility)
- We will use R for some of the examples (check with `Rscript`)

To run on the Sockeye cluster:

- A Sockeye account (or any pbspro-based cluster, other cluster architectures supported but scripts would have to be tweaked)
- Setup your Sockeye account so that you can push/pull from github without password ([see github doc](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent))


## Running a nextflow workflow locally

### Minimalistic example

Let us start with a simple example: ``minimal.nf``. To run it, go to the root of this repo and use:

```
git clone https://github.com/UBC-Stat-ML/nextflow-notes.git
cd nextflow-notes
./nextflow run minimal.nf -resume | bin/nf-monitor
```

Explanations:

- Look at the code. Each `process` block defines a type of vertex in the DAG. The part between `"""`s is the code to run (internally, it uses bash, unix's lowest common dominator, as a substrate, the first line with `#!` is bash's syntax to specify an interpreter/language for a file. But beyond that you do not need to learn bash!)
- The DAG here has two types of node: `myPreprocessor` and `myCode`
- `myStream` is the name of the edge passing a file from `myPreprocessor` into `myCode` via a symlink
- `-resume` means that if you run the command again, it will only redo what changed, plus processes downstream. Test it! E.g. add a space in either of the two processes to see what get reran.
- `| bin/nf-monitor` calls a utility I wrote to help locate the different temporary folders created by nextflow (they are also accessible in `work/...` based on the prefix identifier of the form `[60/53997c]` available in the nextflow output, use tab to complete the prefix)


### Full example

Look now at `full.nf` for a full example including many real world aspects of large simulations (dry-run, compilation of code, use of data, full factorials designs, cluster configuration, docker/singularity container settings). 

To run in 'dry run' mode (i.e. doing a small subset of the computation for quick debugging):

```
./nextflow run full.nf -resume --dryRun | bin/nf-monitor
```

Explanations:

- key output can be accessed in `deliverables/full`
- see `full.nf` which contains detailed comments
- to run the full pipeline, omit the `--dryRun` argument



## Running a nextflow workflow on Sockeye

### Develop the script locally, push to github

- Fork this repo as a basis to get all the required config files. 
- Use a `dryRun` option to quickly iterate. 
- When you are done, push to github

### Start the Sockeye execution

We will need to setup Java on Sockeye. 

- Follow these instructions:

```
cd ~
mkdir bin
cd bin
cp /home/alexbou/jdk11.zip .
unzip jdk11.zip
```

- Add `~/bin/jdk-11.0.10+9/bin/` to your PATH
- exit or reload bash

The following will avoid you having to constantly do 2FA:

- Login to a stable server accessible with password-less access
- Open a [screen](https://en.wikipedia.org/wiki/GNU_Screen) (screen is your best friend for server-side simulation, well worth learning the basics)

```
screen
```

- Alternatively, to reattach an existing screen, use:

```
screen -dr 
```

- Once you are in a screen, ssh into Sockeye
- In Sockeye, follow the instructions below to create a symlink to where you will be cloning this repo (a specific location in the file system where read and write will be much faster than your home folder; shared across my allocation, so create a subfolder; warning, not backed up but as you will see, part of the process will include a kind of back up in github), then clone and go there

```
cd ~
ln -s /scratch/st-alexbou-1/ st-alexbou-1
cd st-alexbou-1
mkdir myUserName
cd myUserName
git clone git@github.com:UBC-Stat-ML/nextflow-notes.git
cd nextflow-notes
```
- We can now start the script (ignore "failed to retrieve queue status" messages)

```
./nextflow-sockeye.sh run full.nf -resume | bin/nf-monitor --open false
```

- After you are done, when you are doing your own scripts in a separate repo, one way to get back the results is to commit the deliverables folder. For convenience I included a script for doing this 

```
(don't actually run the command below unless you are on a fork, to avoid this repo's history getting cluttered)
./commit-deliverables.sh 
```


## Misc

- If you want to cancel a run, type "control c" **only once**. Nextflow will take care of killing submitted subprocesses for you (if you do "control c" more than once, a hard kill, nextflow will not be able to cancel already submitted jobs). To kill manually subprocesses or see job statistics use `qstat` and `qdel` and read [the Sockeye documentation](https://confluence.it.ubc.ca/display/UARC/UBC+ARC+Technical+User+Documentation).

- By default, nextflow does not show the standard out (you can change this by adding ``echo true`` as a process attribute). To inspect the std out/err, cd to the directory of the process and you can access the std out/err by looking at the files `.command.out` and `.command.err`. 

- Checking general queue status: ``pbsnodes -aSj`` 

- Add any tips or tricks here! (PS: anyone knows how to compose singularity containers directly on the Sockeye cluster, i.e. without having to do it on the laptop?)

TODO/note to self: add error when (1) not running latest code; or (2) forgot to git pull; force a command line switch to still go ahead [or transition to HEAD + documenting commit hash.. for #1] --- probably a good idea to keep read-only copy of script too
