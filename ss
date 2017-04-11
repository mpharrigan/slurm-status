#!/bin/bash

set -o errexit -o noclobber -o nounset -o pipefail
params="$(getopt -o prmgtfh -l pending,running,mine,gres,table,fixed-width,help --name "$0" -- "$@")"
eval set -- "$params"

states='all'
users=''
makecolumn=1

#        partition   user    time-limit     job-state   cpus
#        id      name    time-left   start-time    nodes      reason
format='%i;%P;%j;%u;%L;%l;%S;%t;%D;%C;%R'
fixfmt='%10.10s %10.10s %10.10s %10.10s %10.10s %10.10s %10.10s %10.10s %10.10s %10.10s %10.10s'
fixarg='$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11'

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
            fixfmt="$fixfmt %5s"
            fixarg="$fixarg, \$12"
            shift
            ;;
        -t|--table )
            makecolumn=1
            shift
            ;;
        -f|--fixed-width )
            makecolumn=0
            shift
            ;;
        -h|--help )
            echo "Usage: ss [options] -- [squeue options]"
            echo ""
            echo -e "Options"
            echo -e "\t -p, --pending      pending"
            echo -e "\t -r, --running      running"
            echo -e "\t -m, --mine         my jobs"
            echo -e "\t -g, --gres         show gres (GPU) column"
            echo -e ""
            echo -e "\t -t, --table"
            echo -e "\t -f, --fixed-width  Adapt column widths (table) or"
            echo -e "\t                    truncate (fixed-width)"
            echo -e ""
            echo -e "\t -h, --help         this message"
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

if [ $makecolumn -eq 1 ]
then
    squeue --format="$format" --sort="t,-S" --states=$states $users $@ | column -t -s ';'
else
    fixfmt="\"$fixfmt\\n\""
    squeue --format="$format" --sort="t,-S" --states=$states $users $@ | awk -F ';' "{printf($fixfmt, $fixarg)}"
fi
