#!/bin/bash

export PATH=$PATH:/usr/bin/gitolite
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"

GITOLITE=/usr/local/gitolite/gitolite

GITHOME=/home/git
INITFILE=$GITHOME/.gitserver_init

function setup_gitolite() {
    if [ -n "$SSH_KEY" ]; then
	echo "create repositories with your ssh public key !"
	echo "$SSH_KEY" > /tmp/admin.pub
	su git -c "$GITOLITE setup -pk /tmp/admin.pub"
	rm /tmp/admin.pub
    else
	su git -c "$GITOLITE setup -a dummy"
    fi
}

function import_repo() {
    GITADMIN_TMPD=/tmp/gitolite-admin.git

    chown -R git.git  repositories

    if [ -d ./repositories/gitolite-admin.git ]; then
	mv ./repositories/gitolite-admin.git  $GITADMIN_TMPD
    fi

    setup_gitolite

    if [ -d $GITADMIN_TMPD ]; then
	rm -rf ./repositories/gitolite-admin.git
	mv $GITADMIN_TMPD ./repositories/gitolite-admin.git

	# update authorized_keys
	su git -c "cd /home/git/repositories/gitolite-admin.git && GL_LIBDIR=$($GITOLITE query-rc GL_LIBDIR) PATH=$PATH hooks/post-update refs/heads/master"
    fi
}

if [ ! -f $INITFILE ]; then
    cd $GITHOME

    if [ -d repositories ]; then
	import_repo
    fi

    if [ ! -d .gitolite ]; then
        setup_gitolite
    fi
    touch $INITFILE
fi

service ssh start

if [ $# -ne 0 ]; then
    exec $*
else
    while [ 1 ]; do sleep 60;  done
fi


