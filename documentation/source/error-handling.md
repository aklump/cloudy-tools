# Exit Status

When you call `success_exit` and `success_elapsed_exit` the exit status is set to 0 and the script exits.  With the latter, the elapsed time is also printed.

When you call `failed_exit` the exit status is set to 1 by default.  To change the exit status to something other than 1, then do something like the following, which will return a 2.  Valid exit codes are from 0-255. [Learn more](https://www.tldp.org/LDP/abs/html/exit-status.html).

    CLOUDY_EXIT_STATUS=2
    failed_exit "Missing $ROOT/_perms.local.sh."
