#!/bin/sh

GITHOME=/home/git
INITFILE=$GITHOME/.gitserver_init

if [ ! -f $INITFILE ]; then
    cd $GITHOME
    if [ ! -d .gitolite ]; then
        su git -c gitolite setup -a dummy
    fi
    touch $INITFILE
fi

service ssh start

while [ 1 ]; do
  echo "Dummy echo"
  sleep 60
done
