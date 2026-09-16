#!/bin/bash

if [[ $# -lt 1 ]];then
	echo "USAGE: $0 <script.slurm> [<script2.slurm> ... <scriptN.slurm>]"
	exit 2
fi

SLURM_ID_FILE=~/.slurm_submit_prev_id

if [[ ! -e $1 ]];then
	echo "file not specified or not found: $1"
	exit 2
fi

ORIG_DIR=`pwd`
JOB_IDS=""

ACCT_ARG=""
if [[ ! -z $SLURM_ACCT ]];then
	ACCT_ARG="-A $SLURM_ACCT"
fi

for FILE in $@;do
	cd $ORIG_DIR
	
	if [[ $# -gt 1 ]];then
		echo $FILE
	fi
	DIR=`dirname $FILE`
	SCRIPT=`basename $FILE`
	
	if [[ ! -d $DIR ]];then
		echo "$DIR doesn't exist"
		exit 2
	fi
	cd $DIR
	
	OUTPUT=`sbatch --parsable $ACCT_ARG -o ${SCRIPT}.o%j -e ${SCRIPT}.e%j $SCRIPT`
	RET=$?
	printf '%s\n' "$OUTPUT"
	if [[ $RET -eq 0 ]];then
		JOB_ID=${OUTPUT##*$'\n'}
		if [[ ! $JOB_ID =~ ^[0-9]+(\;[^[:space:];]+)?$ || ! ${JOB_ID%%;*} =~ [1-9] ]];then
			echo "sbatch succeeded, but its final output line did not contain a valid job ID; previous ID file left unchanged. Do not resubmit blindly." >&2
			exit 1
		fi
		JOB_ID=${JOB_ID%%;*}
		if [[ $JOB_ID =~ [1-9] ]];then
			if [[ $JOB_IDS ]];then
				JOB_IDS="$JOB_IDS,$JOB_ID"
			else
				JOB_IDS="$JOB_ID"
			fi
		fi
	else
		break
	fi
done
if [[ $RET -eq 0 ]];then
	printf '%s\n' "$JOB_IDS" > "$SLURM_ID_FILE"
fi
exit $RET
