#!/bin/bash  
# This script is used to execute commands and capture errors from stderror so they can be returned to the server.

SCRIPT_FULL_PATH="$(realpath -s $0)"
SCRIPT_DIR="$(dirname $SCRIPT_FULL_PATH)"
cd $SCRIPT_DIR

./$1 2>&1
