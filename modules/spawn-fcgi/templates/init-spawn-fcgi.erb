#! /bin/bash
### BEGIN INIT INFO
# Provides:          spawn-fcgi
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       initscript to manage a pool of workers
#                    configured in $POOL_DIR
### END INIT INFO

# Author: Lars Fronius <lars@jimdo.com>
#

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="FCGI Worker Pools"
NAME=spawn-fcgi
DAEMON=/usr/bin/$NAME
POOL_DIR=/etc/spawn-fcgi
POOLS=$(find $POOL_DIR -type f -printf "%f\n")
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
    if [[ -n "$1" ]]; then
        POOLS=$1
    fi
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    for POOL in $POOLS; do
        POOL_ARGS=$(<$POOL_DIR/$POOL)
        PIDFILE=/var/run/${POOL}_spawn-fcgi.pid
        ARGS_FILE=/var/run/${POOL}_spawn-fcgi.args
        echo "$POOL_ARGS" > $ARGS_FILE
        start-stop-daemon --start --quiet --exec $DAEMON --test > /dev/null \
            || return 1
        start-stop-daemon --start --quiet --exec $DAEMON --pidfile $PIDFILE -- \
            -P $PIDFILE $POOL_ARGS \
            || return 2
        # Add code here, if necessary, that waits for the process to be ready
        # to handle requests from services started subsequently which depend
        # on this one.  As a last resort, sleep for some time.
    done
}

#
# Function that stops the daemon/service
#
do_stop()
{
    if [[ -n "$1" ]]; then
        POOLS=$1
    fi
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    for POOL in $POOLS; do
        PIDFILE=/var/run/${POOL}_spawn-fcgi.pid
        ARGS_FILE=/var/run/${POOL}_spawn-fcgi.args
        for pid in $(<$PIDFILE); do
            start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile <(echo ${pid})
            RETVAL="$?"
            [ "$RETVAL" = 2 ] && return 2
            start-stop-daemon --stop --quiet --retry=0/30/KILL/5 --pidfile <(echo ${pid})
            [ "$?" = 2 ] && return 2
        done
        rm -f $PIDFILE
        rm -f $ARGS_FILE
    done
}

#
# Function that reloads spawn-fcgi which have changed configs
#
do_reload() {
    local action=0
    for POOL in $POOLS; do
        POOL_ARGS=$(<$POOL_DIR/$POOL)
        PIDFILE=/var/run/${POOL}_spawn-fcgi.pid
        ARGS_FILE=/var/run/${POOL}_spawn-fcgi.args
        if ! [ "$(<$ARGS_FILE)" = "$POOL_ARGS" ]; then
            log_daemon_msg "Restarting $DESC $POOL" "$NAME"
            do_stop $POOL
            case "$?" in
              0|1)
                do_start $POOL
                case "$?" in
                    0) log_end_msg 0 ;;
                    1) log_end_msg 1 ;; # Old process is still running
                    *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
              *)
                # Failed to stop
                log_end_msg 1
                ;;
            esac
            let "action+=1"
        fi
    done
    if [ $action -eq 0 ]; then
        log_daemon_msg "No $DESC configuration has changed, not restarting" "$NAME"
        log_end_msg 0
    fi
    return 0
}

check_pools() {
    local count=0
    local check=0
    local procs=0
    for POOL in $POOLS; do
        if [ -f /var/run/${POOL}_spawn-fcgi ]; then
            PIDFILE=/var/run/${POOL}_spawn-fcgi.pid
            for pid in $(<$PIDFILE); do
                let "count++"
                ps -p ${pid} 2>&1 > /dev/null
                if [ $? -eq 0 ]; then
                    let "check++"
                fi
            done
            let "procs++"
        fi
    done
    if [ $procs -ne 0 ]; then
        if [ $count -eq $check ]; then
            return 0
        else
            return 3
        fi
    else
        return 1
    fi
}

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    do_start
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  status)
       check_pools
       case "$?" in
           0)
           log_daemon_msg "All $DESC running" "$NAME" && log_end_msg 0 ;;
           1)
           log_daemon_msg "All $DESC stopped" "$NAME" && log_end_msg 0 ;;
           *)
           log_daemon_msg "Something wrong with $DESC" "$NAME" && log_end_msg 1 ;;
       esac
       ;;
  reload|force-reload)
    #
    # If do_reload() is not implemented then leave this commented out
    # and leave 'force-reload' as an alias for 'restart'.
    #
    do_reload
    ;;
  restart)
    #
    # If the "reload" option is implemented then remove the
    # 'force-reload' alias
    #
    log_daemon_msg "Restarting $DESC" "$NAME"
    do_stop
    case "$?" in
      0|1)
        do_start
        case "$?" in
            0) log_end_msg 0 ;;
            1) log_end_msg 1 ;; # Old process is still running
            *) log_end_msg 1 ;; # Failed to start
        esac
        ;;
      *)
        # Failed to stop
        log_end_msg 1
        ;;
    esac
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|reload|force-reload}" >&2
    exit 3
    ;;
esac

:
