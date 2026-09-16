#!/usr/bin/env bash

# Enable completion/failure email for the current user's jobs.

email=${SLURM_EMAIL:-}
if [[ $# -eq 1 ]]; then
  email=$1
fi
if [[ $# -gt 1 || -z $email ]]; then
  echo "USAGE: $0 [<email>]" >&2
  echo "Set SLURM_EMAIL or supply an email address." >&2
  exit 2
fi
if [[ ! $email =~ ^[^[:space:]@,]+@[^[:space:]@,]+$ ]]; then
  echo "Expected a single email address: $email" >&2
  exit 2
fi
# Capture the status directly: process substitution would hide squeue failures.
# Expand arrays so pending task ranges are returned as individual task IDs.
if ! output=$(squeue --me --noheader --states=all --array -o '%i'); then
  echo "Could not list your jobs; no email settings changed." >&2
  exit 1
fi
jobs=()
while IFS= read -r job; do
  job=${job//[[:space:]]/}
  [[ -n $job ]] && jobs+=("$job")
done <<< "$output"
if [[ ${#jobs[@]} -eq 0 ]]; then
  echo "No current jobs found."
  exit 0
fi
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
exec bash "$script_dir/slurm_mail.sh" "$email" "${jobs[@]}"
