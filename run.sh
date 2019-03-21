# This oneiner does the following:
# * takes UUIDs from the 'batch' file
# * in parallel runs the a script on them, with parallelism defined by the '-P' setting
#   then connect to the device with balena ssh, pipe in the task script, and
#   save the log with the UUID prepended
cat batch | stdbuf -oL xargs -I{} -P 10 /bin/sh -c "grep -a -q '{} : DONE' supervisor-update.log || (./supervisor-update.sh {} | sed 's/^/{} : /' | tee --append supervisor-update.log)"
