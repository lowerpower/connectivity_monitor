# connectivity_monitor

Simple connectivity monitor to log when a system does not have connectivity to a target using a simple ping test, option to log to syslog when connectivity fails

# usage:
`
con_mon.sh [-v] [-s] [-c] [-i] <target host optinal>
`

All options optional, will use defaults if not specified.

`
 -v up to 3 times for verbose level (level 1 enables connectivity is ONLINE output)
 -s will log to syslog insted of stdio
 -c number of pings to send per interval (default 2)
 -i interval in seconds to check connectivity (default 30)
`

hostname to ping is optinal, by default will use 8.8.8.8

#Install to /usr/local/bin/con_mon.sh

do not forget to chmod +x  /usr/local/bin/con_mon.sh

I use this in rc.local and log to either a file or syslog

 to syslog:

`
  /usr/local/bin/con_mon.sh -s &>/dev/null &
`

 to logfile:
 
`
/usr/local/bin/con_mon.sh &> /tmp/con_mon.log &   
`

#Output

The following exampels are with -v set so "connectivity is ONLINE" is show, otherwise only offline events are shown.

output to stdio will be timestamped:
`
20230111104728: Connectivity tester starting:
20230111104728: Target Host 8.8.8.8, Interval 30 seconds, Ping Test Count 2, verbose level 1
20230111104728: connectivity is ONLINE to 8.8.8.8

20230111104728: exit after next interval
20230111104759: Connectivity Tester Shutting Down
`
 
Output to syslog will be markd by the ID and pid:
`

`


#Shutdown
HUP INT TERM are trapped and will shutdown after the current operation is over, could be up to interval seconds.


 
 
 
 
