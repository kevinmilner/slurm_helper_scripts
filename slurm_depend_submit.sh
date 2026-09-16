#!/bin/bash

if [[ ! -e $1 ]];then
	echo "file not specified or not found: $1"
	exit 2
fi

OUT_SLURM_ID_FILE=~/.slurm_depend_submit_prev_id

DIR=`dirname ${1}`
SCRIPT=`basename ${1}`

if [[ ! -d $DIR ]];then
	echo "$DIR doesn't exist"
	exit 2
fi
cd $DIR

if [[ $# -lt 2 ]];then
	SLURM_ID_FILE=~/.slurm_submit_prev_id
	if [[ -e $SLURM_ID_FILE ]];then
		JOB_ID=`cat $SLURM_ID_FILE`
		echo "Detected previously submitted Job ID=$JOB_ID"
	else
		echo "Did not specify a depenecy Job ID and no record of previously submitted in $SLURM_ID_FILE"
		exit 1
	fi
else
	JOB_ID=$2
fi

ACCT_ARG=""
if [[ ! -z $SLURM_ACCT ]];then
	ACCT_ARG="-A $SLURM_ACCT"
fi

OUTPUT=`sbatch --parsable $ACCT_ARG -o ${SCRIPT}.o%j -e ${SCRIPT}.e%j --dependency=afterok:$JOB_ID $SCRIPT`
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
		echo $JOB_ID > $OUT_SLURM_ID_FILE
	fi
fi

exit $RET
