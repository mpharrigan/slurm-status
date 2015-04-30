#!/bin/bash

states='all'
users=''
addtl=''
partition=''

#        partition   user    time-limit     job-state   cpus
#        id      name    time-left   start-time    nodes      reason
format='%.7i %9P %9j  %9u %.13L %.13l %.16S   %.2t %.5D %.5C  %15R'

while getopts "prmgcht" opt
do
    case $opt in
        p )
            #Pending
            states='PD'
            ;;
        r )
            # Running
            states='R'
            ;;
        m )
            # Mine
            users="-u $USER"
            ;;
        g )
            # Show gres column (gpus)
            format="$format %b"
            ;;
        c )
            # GPU partition
            partition='--partition=gpu'
            ;;
        t )
            # Don't show header
            addtl="$addtl --noheader"
            ;;
        h )
            echo "Usage: ss -[prmgc]"
            echo ""
            echo -e "\t -p    pending"
            echo -e "\t -r    running"
            echo -e "\t -m    my jobs"
            echo -e "\t -g    show gres column"
            echo -e "\t -c    gpu partition"
            echo -e "\t -h    this message"
            echo ""
            exit 0;
            ;;
    esac
done

squeue --format="$format" --sort="t,-S" \
        --states=$states $users $partition $addtl
