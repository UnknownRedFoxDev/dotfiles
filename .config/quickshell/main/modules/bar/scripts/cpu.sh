#!/bin/env bash

old=(`cat /proc/stat | awk '/^cpu / {
    user = $2;
    nice = $3;
    systemtime = $4;
    idle = $5;
    iowait = $6;
    irq = $7;
    softirq = $8;
    total = (user + nice + systemtime + idle + iowait + irq + softirq);
    idleTime = (idle + iowait);
    printf "%d %d\n", total, idleTime
}'
`)

sleep 1

new=(`cat /proc/stat | awk '/^cpu / {
    user = $2;
    nice = $3;
    systemtime = $4;
    idle = $5;
    iowait = $6;
    irq = $7;
    softirq = $8;
    total = (user + nice + systemtime + idle + iowait + irq + softirq);
    idleTime = (idle + iowait);
    printf "%d %d\n", total, idleTime
}'
`)

prev_total=${old[0]}
prev_idle=${old[1]}

curr_total=${new[0]}
curr_idle=${new[1]}

delta_idle=$(( curr_idle - prev_idle ))
delta_total=$(( curr_total - prev_total ))

echo $(( 100 - (delta_idle * 100 / delta_total) ))
