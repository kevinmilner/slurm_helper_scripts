# slurm_helper_scripts

Helper scripts for submitting and monitoring SLURM batch jobs.

To use, clone this git repository on the HPC system you intend to use and add this directory to your path.

For example, if you are using BASH and you cloned it to `$HOME/git/slurm_helper_scripts`, then you would add this to your `$HOME/.bashrc` file (and then log out and back in):

`PATH=$PATH:$HOME/git/slurm_helper_scripts`

## Submitting Jobs: slurm_submit.sh

This script submits SLURM batch scripts with PBS-like STDOUT and STDERR files: `<script-name>.o<job-ID>` and `<script-name>.e<job-ID>`. I like this much better than the SLURM default of just `slurm-<job-ID>.out`, which can get confusing when you have multiple slurm scripts in one directory.

For example, if you were to submit a script called script.slurm with this tool and the assigned job ID is 1111, then STDOUT could be found in `script.slurm.o1111` and STDERR could be found in `script.slurm.e1111`.

## See running jobs

Use the `qme` command (q for see the queue, me for me/you) to see running jobs:

```
[kmilner@endeavour1 ~]$ qme
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          19336848      scec cat_bbp_  kmilner  R      16:33     16 e19-[24-39]
          19336847      scec cat_bbp_  kmilner  R    4:40:27     16 e19-[06,08,10,40-48],e20-[01-04]
          19347546      scec du_repor  kmilner  R       7:37      1 e19-12
```

This is just a handy alias for `squeue -u $USER`

If you want to watch the output of that command, use `wqme` instead (w for watch). When you're done, hit ctrl+c to exit. This is just a handy alias for `watch -n 10 squeue -u $USER`

## Tail STDOUT

To tail STDOUT (see what your job is printing to the console), use `stdout_job_tail.sh`. You can supply a job ID, or omit and the first running job will be found. When you're done, hit ctrl+c to exit.

## Watch submitted job status and also tail STDOUT

To see the the state of your submitted jobs, and also the most recent STDOUT of a running job, use `qtail`.

To watch the output of that command, use `wqtail` and hit ctrl+c to exit when you're done.
