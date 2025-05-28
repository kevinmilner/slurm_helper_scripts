#!/usr/bin/env python3
"""
Summarise Slurm jobs by user for a given queue.

Usage:
    queue_check.py [--full] <queue>
"""

import sys
import subprocess

def main() -> None:
    # ------------------------------------------------------------------ argparse-lite
    full = False
    if len(sys.argv) == 2:
        queue = sys.argv[1]
    elif len(sys.argv) == 3 and sys.argv[1] == "--full":
        full = True
        queue = sys.argv[2]
    else:
        print("USAGE: [--full] <queue>")
        sys.exit(1)

    # ------------------------------------------------------------------ query squeue
    cmd = f'squeue -o "%.18i %.20P %.20u %.2t %.6D" | grep {queue}'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode not in (0, 1):          # 1 means grep found nothing
        print(result.stderr, file=sys.stderr)
        sys.exit(result.returncode)

    # ------------------------------------------------------------------ parse output
    users              = []
    user_queued_jobs   = {}
    user_running_jobs  = {}
    user_nodes         = {}

    queued_jobs  = 0
    running_jobs = 0
    used_nodes   = 0

    for line in result.stdout.splitlines():
        fields = line.split()
        if len(fields) == 5:
            job_id, _, user, state, nodes = fields
            nodes = int(nodes)
            if user not in users:
                users.append(user)
                user_queued_jobs[user]  = []
                user_running_jobs[user] = []
                user_nodes[user]        = 0

            if state == "R":
                user_running_jobs[user].append(job_id)
                running_jobs          += 1
                user_nodes[user]      += nodes
                used_nodes            += nodes
            else:
                user_queued_jobs[user].append(job_id)
                queued_jobs += 1
        elif fields:   # non-empty line but unexpected format
            print(f"bad split (len {len(fields)}): {fields}", file=sys.stderr)

    # ------------------------------------------------------------------ top-level summary
    print(f"{len(users)} users running {running_jobs} jobs on "
          f"{used_nodes} nodes, {queued_jobs} queued jobs")

    tot_nodes = 0
    for user in users:
        running = user_running_jobs[user]
        queued  = user_queued_jobs[user]
        nodes   = user_nodes[user]
        print(f"user: {user},\trunning: {len(running)} ({nodes} nodes),"
              f"\tqueued: {len(queued)}")
        tot_nodes += nodes
    print(f"Total nodes in use: {tot_nodes}")

    # ------------------------------------------------------------------ full per-user listing
    if full:
        for user in users:
            cmd = f"squeue -u {user}"
            out = subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout
            print(out, end="")                     # already contains newlines

if __name__ == "__main__":
    main()

