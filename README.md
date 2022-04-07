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
- Same workflow can be used on your laptop and the cluster (e.g. this one designed for UBC's Sockeye cluster). In the latter case, nextflow takes care of all the batch submission details.
- Helps setup common experimental design patterns, e.g. full factorial designs ran in parallel. 
- Simplified replication, adding one line of code takes care of running a node in a docker/singularity container. 

## Prerequisites

- Do **not** install nextflow, instead just clone this repo which has one with the version we will use built-in.
- Unix (mac, linux, wsl, etc)
- Java 11 (use [sdk man](https://sdkman.io/) to make sure you use exactly this version; Java recently got worse at backward compatibility)
- We will use R for some of the examples

To run on Sockeye:

- A Sockeye account
- Setup your Sockeye account so that you can push/pull from github without password (**TODO**: can someone add a link to instructions for doing this)
- To make things easier, set-up also a department VM (email help@stat)
- Setup password less SSH to the department VM (**TODO**: can someone add a link to instructions for doing this), which you can keep as semi-permanent bridge to Sockeye via ``screen`` to avoid the annoying 2FA



## Running a nextflow workflow locally

### Minimalistic example

Let us start with a simple example: ``minimal.nf``. To run it, go to the root of this repo and use:

```
./nextflow run minimal.nf -resume | bin/nf-monitor
```

Explanations:

- Look at the code. Each `process` block defines an edge. The part between `"""`s is the code to run (internally, it uses bash, unix's lowest common dominator as a substrate, the first line with `#!` is bash's syntax to specify an interpreter/language for a file. But beyond that you do not need to learn bash!)
- The DAG here has two types of node: `myPreprocessor` and `myCode`
- `myStream` is the name of the edge passing a file from `myPreprocessor` into `myCode` via a symlink
- `-resume` means that if you run the command again, it will only redo what changed. Test it! E.g. add a comment in either of the two processes to see what get reran.
- `| bin/nf-monitor` is a utility I wrote to help locate the different temporary folders created for you (they are also accessible in `work/...` based on the prefix identifier of the form `[60/53997c]` available in the nextflow output, use tab to complete the prefix)


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

- Use this repo as a basis to get all the properly configured files. 
- Use a `dryRun` option to quickly iterate. 

### Start the Sockeye execution

We will to setup Java on Sockeye. 

- Follow these instructions:
```
cd ~
mkdir bin
cd bin
cp /home/alexbou/jdk11.zip .
unzip jdk11.zip
```
- Add `~/bin/jdk-11.0.10+9/bin/` to your PATH
- exit

The following will avoid you having to constantly do 2FA:

- Login to a stable server accessible with password-less access
- Open a screen 

```
screen
```

- Alternatively, to reattach use (I use detach-reattach in case there is a stale connection)

```
screen -dr 
```

- One you are in a screen, ssh into Sockeye
- In Sockeye, create a symlink to where you will be cloning this repo, then clone and go there

```
cd ~
ln -s /scratch/st-alexbou-1/ st-alexbou-1
cd st-alexbou-1
git clone git@github.com:alexandrebouchard/nextflow-notes.git
cd nextflow-notes
```
- We can now start the script

```
./nextflow-sockeye.sh run full.nf -resume 
```

- After you are done, one way to get back the results is to commit the deliverables folder

```
git add deliverables/*
git commit
[i, then commit message, then shift-:, wq]
git push 
```