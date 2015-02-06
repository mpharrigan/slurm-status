#!/bin/bash

states='all'
users=''
addtl=''
partition=''

while getopts "prmgch" opt
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
            # Gres GPUs
            addtl='%b'
            ;;
        c )
            # GPU partition
            partition='--partition=gpu'
            ;;
        h )
            echo "Usage: ss [prmg]"
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

squeue --format="%.7i %9P %9j  %9u %.13L %.13l %.16S   %.2t %.5D %.5C  %15R $addtl" --sort="t,-S" \
        --states=$states $users $partition
