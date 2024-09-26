#!/bin/bash

if [[ $# -ne 1 ]];then
	echo "USAGE: <script.slurm>"
	exit 2;
fi
if [[ ! -e $1 ]];then
	echo "file not specified or not found: $1"
	exit 2
fi

SLURM_ID_FILE=~/.slurm_depend_submit_prev_id

if [[ -e $SLURM_ID_FILE ]];then
	JOB_ID=`cat $SLURM_ID_FILE`
	echo "Detected previously submitted Job ID=$JOB_ID"
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
	$DIR/slurm_depend_submit.sh $1 $JOB_ID
	exit $?
else
	echo "Cannot chain dependencies becasuse none found in $SLURM_ID_FILE; did you submit with slurm_depend_submit.sh?"
	exit 1
fi
