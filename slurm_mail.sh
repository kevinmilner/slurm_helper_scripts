#!/usr/bin/env bash

# Enable completion/failure email for existing jobs.

email=${SLURM_EMAIL:-}
# An explicit address overrides the environment; otherwise all arguments are IDs.
if [[ ${1:-} == *@* ]]; then
  email=$1
  shift
fi
if [[ $# -lt 1 || -z $email ]]; then
  echo "USAGE: $0 [<email>] <job-id> [<job-id> ...]" >&2
  echo "Set SLURM_EMAIL or supply an email address as the first argument." >&2
  exit 2
fi
if [[ ! $email =~ ^[^[:space:]@,]+@[^[:space:]@,]+$ ]]; then
  echo "Expected a single email address: $email" >&2
  exit 2
fi
# Validate every ID before changing any jobs. Allow array tasks and hetjob components.
for job in "$@"; do
  if [[ ! $job =~ ^[0-9]+([_+][0-9]+)?$ ]]; then
    echo "Invalid job ID: $job" >&2
    exit 2
  fi
done
status=0
for job in "$@"; do
  if scontrol update "JobId=$job" "MailUser=$email" MailType=END,FAIL; then
    printf 'Enabled END,FAIL email to %s for job %s\n' "$email" "$job"
  else
    printf 'Could not update job %s\n' "$job" >&2
    status=1
  fi
done
exit "$status"
