#!/bin/bash

echo "1. Script name (\$0): $0"
echo "2. First argument (\$1): $1"
echo "3. Second argument (\$2): $2"
echo "4. Total number of arguments (\$#): $#"

echo "5. All arguments as a single string (\"\$*\"):"
for arg in "$*"; do
    echo "   -> [$arg]"
done

echo "6. All arguments as individual words (\"\$@\"):"
for arg in "$@"; do
    echo "   -> [$arg]"
done

# Run a command to test $_ and $?
ls /non_existent_folder > /dev/null 2>&1
echo "7. Exit code of last command (\$?): $?"
echo "8. Last argument of previous command (\$_): $_"

echo "9. PID of the current shell/script (\$\$): $$"

# Run a short background process to test $!
sleep 1 &
echo "10. PID of last background command (\$!): $!"
