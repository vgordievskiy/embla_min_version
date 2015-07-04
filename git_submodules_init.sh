#!/bin/bash
# Exists to fully update the git repo that you are sitting in...

git pull && git submodule init && git submodule update && git submodule status
git submodule foreach git pull origin master
