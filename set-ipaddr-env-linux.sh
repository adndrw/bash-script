#!/bin/bash

IPADDR=$(ip address show | grep 'inet ' | grep 'eth' | awk '{print $2}' | cut -d'/' -f1)
echo $IPADDR

 pm2 set pm2-logrotate:max_size 1G
 pm2 set pm2-logrotate:retain 7
 pm2 set pm2-logrotate:compress true
 pm2 set pm2-logrotate:dateFormat YYYY-MM-DD_HH-mm-ss
 pm2 set pm2-logrotate:workerInterval 30
 pm2 set pm2-logrotate:rotateInterval 0 * * * *
 pm2 set pm2-logrotate:rotateModule true