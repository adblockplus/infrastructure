#!/bin/bash
### BEGIN INIT INFO
# Provides:          hgwebdir
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     3 5
# Default-Stop:      0 1 2 6
# Description:       HG FastCGI server
### END INIT INFO

SCRIPT=/opt/hgweb.fcgi
FCGI_SOCKET=/var/run/hgweb.sock
PID_FILE=/var/run/hgweb.pid
USER=www-data

start() {
    spawn-fcgi -f $SCRIPT -s $FCGI_SOCKET -P $PID_FILE -u $USER
}

stop() {
    if [ -e "$PID_FILE" ]; then
        kill -9 `cat $PID_FILE` && rm $PID_FILE && rm $FCGI_SOCKET
    else
        echo "daemon not running" >&2
    fi
}

help() {
    echo "Usage: $0 {start|stop|restart}"
    test 'help' = "$1"
}

case "$1" in
    start|stop) $1;;
    restart) stop; start;;
    *) help "$@";;
esac
