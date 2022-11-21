# slurm_helper_scripts
Helper scripts for submitting and monitoring SLURM batch jobs

## Submitting Jobs: slurm_submit.sh

This script submits SLURM batch scripts with PBS-like STDOUT and STDERR files: `<script-name>.o<job-ID>` and `<script-name>.e<job-ID>`. For example, if you were to submit a script called script.slurm and the assigned job ID is 1111, then STDOUT could be found in `script.slurm.o1111` and STDERR could be found in `script.slurm.e1111`.

All monitoring scripts here assume generally assume that batch scripts were submitted using `slurm_submit.sh`.

## Tail STDOUT

To tail STDOUT, use `stdout_job_tail.sh`. You can supply a job ID, or omit and the first running job will be found.

## Watch submitted job status and also tail STDOUT

To watch the state of your submitted jobs, and also tail the STDOUT of a running job, use `wqtail`.
