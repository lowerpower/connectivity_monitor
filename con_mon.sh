#!/bin/bash 
# https://github.com/lowerpower/connectivity_monitor
#
# connectivity monitor using a simple ping test, option to log to syslog when connectivity fails
#
# usage:
# con_mon.sh [-v] [-s] [-c] [-i] <target host optinal>
#
# All options optional, will use defaults if not specified.
#
# -v up to 3 times for verbose level
# -s will log to syslog insted of stdio
# -c number of pings to send per interval (default 2)
# -i interval in seconds to check connectivity (default 30)
#
# hostname to ping is optinal, by default will use 8.8.8.8
#
# I use this in rc.local and log to either a file or syslog
#
# to syslog:
#   con_mon.sh -s &>/dev/null &
#
# to logfile:
#   con_mon.sh &> /tmp/con_mon.log &
#
#
#-- defaults --

#ID to use in syslog
ID="CON_MON[$$]"
#default target host
TARGET_HOST="8.8.8.8"
#log to syslog if 1
LOG2SYSLOG=0
# verbose level -v, -v -v, or -v -v -v for maximum verbosity
VERBOSE=0
#interval in seconds between connectivity checks
INTERVAL=30
#number of pings to try each connectivity check
COUNT=2
#path to ping utility
PING_UTIL="/bin/ping"

#go until GO is 0
GO=1

#
# Produce a sortable timestamp that is year/month/day/timeofday
#
get_timestamp()
{
    echo $(date +%Y%m%d%H%M%S)
}




##### main program starts here #####

# parse the flag options (and their arguments) #
################################################
while getopts svhi:c: OPT; do
    case "${OPT}" in
      s)
        LOG2SYSLOG=1
        ;;
      c)
        COUNT=${OPTARG}
        ;;
      i)
        INTERVAL=${OPTARG}
        ;;
      v)
        VERBOSE=$((VERBOSE+1))
        if [ $VERBOSE -gt 2 ]; then
            set -x
        fi
        ;;
      h | [?])
        # got invalid option
        echo "TBD"
        exit 1
        ;;
    esac
done


# get rid of the just-finished flag arguments
shift $(($OPTIND-1))

#now lets get ping target hostname, if not set use default
if [[ ${1+x} ]]; then
    TARGET_HOST=$1
    echo "target host set to $1"
fi

# lets exit cleanly after the next sleep
trap 'GO=0; INTERVAL=0; echo;echo "$timestamp: exit after next interval"' HUP INT TERM



#print banner, either to syslog or to stdio
if [ $LOG2SYSLOG -gt 0 ]; then
    logger --tag $ID "Connectivity Tester starting:"
    logger --tag $ID "Target Host $TARGET_HOST, Interval $INTERVAL seconds, Ping Test Count $COUNT, verbose level $VERBOSE"
else
    echo "$timestamp: Connectivity tester starting:"
    echo "$timestamp: Target Host $TARGET_HOST, Interval $INTERVAL seconds, Ping Test Count $COUNT, verbose level $VERBOSE"

fi


#
# main while loop here, go forever,or until GO == 0 which can only happen from signal
#
while [ $GO -gt 0 ]
do

timestamp=$(get_timestamp)  

if $PING_UTIL -c $COUNT -q $TARGET_HOST &>/dev/null; then
    # we do not log online unless verbose mode is on
    if [ $VERBOSE -gt 0 ]; then
        # only log online if verbose is st
        if [ $LOG2SYSLOG -gt 0 ]; then
            logger --tag $ID "connectivity is ONLINE to $TARGET_HOST"
        else
            echo "$timestamp: connectivity is ONLINE to $TARGET_HOST"
        fi
    fi
else
    if [ $LOG2SYSLOG -gt 0 ]; then
	    logger --tag $ID "connectivity is OFFLINE to $TARGET_HOST"
    else
	    echo "$timestamp: connectivity is OFFLINE to $TARGET_HOST"
    fi
fi

#only at debug level 2
if [ $VERBOSE -gt 1 ]; then
    echo "sleeping for interval $INTERVAL go= $GO"
fi

sleep $INTERVAL

done

if [ $LOG2SYSLOG -gt 0 ]; then
    logger -TAG $ID "Connectivity Tester Shutting Down"
else
    echo "$timestamp: Connectivity Tester Shutting Down"
fi


