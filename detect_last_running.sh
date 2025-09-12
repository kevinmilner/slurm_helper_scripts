#!/bin/bash

squeue -t R -u $USER -o "%A %j" -h | grep -v interact | awk '{print $1}' | sort | tail -n 1
#squeue -t R -u $USER -o %A -h | grep -v interact | sort | head -n 1
