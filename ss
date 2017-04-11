#!/bin/bash

set -o errexit -o noclobber -o nounset -o pipefail
params="$(getopt -o prmgh -l pending,running,mine,gres,help --name "$0" -- "$@")"
eval set -- "$params"

states='all'
users=''
addtl=''
partition=''

#        partition   user    time-limit     job-state   cpus
#        id      name    time-left   start-time    nodes      reason
format='%i;%P;%j;%u;%L;%l;%S;%t;%D;%C;%R'

while true
do
    case "$1" in
        -p|--pending )
            #Pending
            states='PD'
            shift
            ;;
        -r|--running )
            # Running
            states='R'
            shift
            ;;
        -m|--mine )
            # Mine
            users="-u $USER"
            shift
            ;;
        -g|--gres )
            # Show gres column (gpus)
            format="$format;%b"
            shift
            ;;
        -h|--help )
            echo "Usage: ss [options]"
            echo ""
            echo -e "Options"
            echo -e "\t -p, --pending    pending"
            echo -e "\t -r, --running    running"
            echo -e "\t -m, --mine       my jobs"
            echo -e "\t -g, --gres       show gres (GPU) column"
            echo -e "\t -h, --help       this message"
            echo ""
            exit 1
            ;;
        -- )
            shift
            break
            ;;
        * )
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

squeue --format="$format" --sort="t,-S" \
       --states=$states $users $partition | column -t -s ';'
