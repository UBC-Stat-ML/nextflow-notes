#!/bin/bash

module load git
git pull
git add deliverables/*
git commit -m "Auto: add deliverables"
git push