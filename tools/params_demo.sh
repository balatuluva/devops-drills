#!/usr/bin/env bash
# params_demo.sh — show special parameters and exit codes
echo "script name : $0"
echo "arg count   : $#"
i=1
for arg in "$@"; do
  echo "arg $i       : [$arg]"
  i=$((i + 1))
done
ls /definitely/not/here 2>/dev/null
echo "ls exit code: $?"
if [ "$#" -eq 0 ]; then
  echo "usage: $0 ARG..." >&2
  exit 2
fi
exit 0
