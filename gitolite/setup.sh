#!/bin/sh

export PATH=$PATH:/usr/bin/gitolite
GITOLITE=/usr/local/gitolite/gitolite

GITHOME=/home/git
INITFILE=$GITHOME/.gitserver_init

if [ ! -f $INITFILE ]; then
    cd $GITHOME
    echo $PATH
    echo '---------------'
    if [ ! -d .gitolite ]; then
        su git -c "$GITOLITE setup -a dummy"
    fi
    touch $INITFILE
fi

service ssh start

if [ $# -ne 0 ]; then
    exec $*
else
    while [ 1 ]; do sleep 60;  done
fi


