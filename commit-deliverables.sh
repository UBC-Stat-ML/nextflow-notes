#!/bin/bash

module load git
git pull
git add deliverables/*
git add dag.dot
git add report.html
git add timeline.html
git add trace.txt
git commit -m "Auto: add deliverables"
git push