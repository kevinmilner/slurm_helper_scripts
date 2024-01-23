# Kevin's SLURM helper scripts

Helper scripts for submitting and monitoring SLURM batch jobs.

To use, clone this git repository on the HPC system you intend to use and add this directory to your path.

For example, if you are using BASH and you cloned it to `$HOME/git/slurm_helper_scripts`, then you would add this to your `$HOME/.bashrc` file (and then log out and back in):

`PATH=$PATH:$HOME/git/slurm_helper_scripts`

## Submitting jobs: slurm_submit.sh

This script submits SLURM batch scripts with PBS-like STDOUT and STDERR files: `<script-name>.o<job-ID>` and `<script-name>.e<job-ID>`. I like this much better than the SLURM default of just `slurm-<job-ID>.out`, which can get confusing when you have multiple SLURM scripts in one directory.

For example, if you were to submit a script called script.slurm with this tool and the assigned job ID is 1111, then STDOUT could be found in `script.slurm.o1111` and STDERR could be found in `script.slurm.e1111`.

## Submit a job with a dependency: slurm_depend_submit.sh

To submit a job with a dependency on another job, use `slurm_depend_submit.sh`. The submitted job will wait until the supplied dependencies complete successfully.

It takes a SLURM script as the first argument, and the Job ID('s) it depends on as the 2nd argument. Multiple dependencies can be specified as <jobID11>:<jobID2>:<jobIDN>. Alternatively, if you omit the Job ID argument, the most recently submitted script with the slurm_submit.sh command will be used as the dependency.

Single job dependency on job 111:

`slurm_depend_submit.sh dependent_job.slurm 111`

Multiple job dependency on jobs 111 and 112:

`slurm_depend_submit.sh dependent_job.slurm 111:112`

Single job dependency on the most recent job you submitted with `slurm_submit.sh`:

`slurm_depend_submit.sh dependent_job.slurm`

## See running jobs: qme or wqme

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

## Tail STDOUT: stdout_job_tail.sh

Once a job is running, to tail STDOUT (see what your job is printing to the console), use `stdout_job_tail.sh`. You can supply a job ID, or omit and the first running job will be found. When you're done, hit ctrl+c to exit.

## See (or watch) submitted job status and also tail STDOUT: qtail or wqtail

To see the the state of your submitted jobs, and also the most recent STDOUT of a running job, use `qtail`. It will automatically limit the printed STDOUT so that it does not exceed the number of lines in your terminal.

```
[kmilner@endeavour1 slurm_helper_scripts]$ qtail
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          19336848      scec cat_bbp_  kmilner  R      22:56     16 e19-[24-39]
          19336847      scec cat_bbp_  kmilner  R    4:46:50     16 e19-[06,08,10,40-48],e20-[01-04]
          19347546      scec du_repor  kmilner  R      14:00      1 e19-12

==> ... 24_01_22-rundir5696_subduction-all-m6.5-skipYears2000-noHF-vmCENTRAL_JAPAN-standardSitesNZ-griddedSitesNZ/cat_bbp_parallel.slurm.o19336847 <==

[22:29:43.206 (e19-10.hpc.usc.edu) Process 2]: waiting for other processes with Barrier()
[22:29:43.205 DispatcherThread]: checking if we're all done...
[22:29:43.205 (e19-06.hpc.usc.edu) Process 0]: running async post-batch hook for process 2. running=28, queued=0, finished=403
[22:29:43.205 DispatcherThread]: not yet. waiting on: 4,5,7
[22:29:43.205 DispatcherThread]: waiting for READY message.
[22:29:43.205 (e19-06.hpc.usc.edu) Process 0]: async post-batch estimates: rate: 49.95 tasks/s, time for running: 560.56 ms
[22:29:44.247 (e19-06.hpc.usc.edu) Process 0]: done running async post-batch hook for process 2. running=28, queued=0, finished=403
```

To watch the output of that command, use `wqtail` and hit ctrl+c to exit when you're done.

## Cancel all jobs (regardless of state): scancel_me.sh

To quickly cancel all jobs (running, queued, or otherwise), run `scancel_me.sh`
