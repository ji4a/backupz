#!/bin/bash

CRON_JOB="@reboot /root/transfer.sh > /path/to/output.log 2>&1 &"
(crontab -l | grep -F "$CRON_JOB") > /dev/null

if [ $? -ne 0 ]; then
    (crontab -l; echo "$CRON_JOB") | crontab -
    echo "Cron job added successfully."
else
    echo "Cron job already exists."
fi

### EXECUTE TRANSFER.SH in the background ####
nohup bash transfer.sh > backup_output.log 2>&1 &
