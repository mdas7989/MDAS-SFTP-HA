#!/bin/bash

Server1=<Primary Server hostname>
Server2=<Secondary Server Hostname>
RECIPIENTS="mdas.070989@gmail.com"

status1=`nc -v -z -w10 $Server1 2222 2>&1| grep -i Connected | wc -l`
status2=`nc -v -z -w10 $Server2 2222 2>&1| grep -i Connected | wc -l`

if [ $Server1 = `hostname -f` ]; then
echo "Hey this is me Primary Host: $Server1 ------- Checking my status"
        if [ $status1 = 1 ] ; then
                echo "Hey I am up. You can now SFTP to me and copy your data"
                echo "Stopping  Seconday host $Server2 if they are running"
                ssh -o StrictHostKeyChecking=no app@$Server2 "sh /app/scripts/Script_iptables.sh AddRule "
                echo "Syncing data from Primary Server to  seconday server"
                rsync -arvc -e 'ssh -o StrictHostKeyChecking=no' <source_path> <destination_path>

        fi

status1=`nc -v -z -w10 $Server1 2222 2>&1| grep -i Connected | wc -l`
status2=`nc -v -z -w10 $Server2 2222 2>&1| grep -i Connected | wc -l`

elif [ $Server2 = `hostname -f` ]; then
        if [ $status1 = 1 ] && [$status2 = 1] ; then
        echo "Primary is running, making sure Secondary $Server2 is down"
        ssh -o StrictHostKeyChecking=no app@$Server2 "sh /app/scripts/Script_iptables.sh AddRule "
        elif [ $status1 = 0 ] && [ $status2 = 0 ]; then
        echo "Both Primary & Secondary is down"
        /usr/sbin/sendmail "$RECIPIENTS" < /app/scripts/indexing_failure_msg.txt
        cd /app/scripts ; sh Script_iptables.sh DelRule
        echo "SFTP port is made up in $Server2"
        sleep 5
        fi

fi
