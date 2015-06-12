#!/bin/bash

### Init gitolite server when docker container start

export PATH=$PATH:/usr/local/gitolite
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"

GITOLITE=/usr/local/gitolite/gitolite

GITHOME=/home/git

INITFILE=$GITHOME/.gitserver_init

# Install auto email hook
function setup_mail() {
    POST_MAIL=/usr/local/gitolite/post-receive-email
    su git -c "cp $POST_MAIL $GITHOME/.gitolite/hooks/common/post-receive"
    su git -c "gitolite setup --hooks-only"
}

function setup_gitolite() {
    if [ -n "$SSH_KEY" ]; then
        echo "create repositories with your ssh public key !"
        echo "$SSH_KEY" > /tmp/admin.pub
        su git -c "$GITOLITE setup -pk /tmp/admin.pub"
        rm /tmp/admin.pub
    else
        su git -c "$GITOLITE setup -a dummy"
    fi

    # Enable all config default, I like this feature
    # Config maillist in the gitolite-admin's gitolite.conf file
    if [ -z "$GIT_CONFIG_KEYS" ]; then
        GIT_CONFIG_KEYS=.*
    fi

    rcfile=$GITHOME/.gitolite.rc
    sed -i "s/GIT_CONFIG_KEYS.*=>.*''/GIT_CONFIG_KEYS => \"${GIT_CONFIG_KEYS}\"/g" $rcfile

    if [ -n "$LOCAL_CODE" ]; then
        sed -i "s|# LOCAL_CODE.*=>.*$|LOCAL_CODE => \"${LOCAL_CODE}\",|" $rcfile
    fi

    # change unmask, you need to do chmod for alread exist files manually.
    if [ -n "$UMASK" ]; then
        sed -i "s/UMASK.*=>.*/UMASK => ${UMASK},/g" $rcfile
    fi
}

function import_repo() {
    GITADMIN_TMPD=/tmp/gitolite-admin.git

    if [ -d ./repositories/gitolite-admin.git ]; then
        mv ./repositories/gitolite-admin.git  $GITADMIN_TMPD
    fi

    setup_gitolite
    setup_mail

    if [ -d $GITADMIN_TMPD ]; then
        echo "restore to original gitolite-admin"
        rm -rf ./repositories/gitolite-admin.git
        mv $GITADMIN_TMPD ./repositories/gitolite-admin.git

        # update authorized_keys
        su git -c "cd /home/git/repositories/gitolite-admin.git && GL_LIBDIR=$($GITOLITE query-rc GL_LIBDIR) PATH=$PATH hooks/post-update refs/heads/master"
    fi

    echo "Configure gitolite server successfully !!!"
}

# Change owner and permission when system start
chown -R git.git $GITHOME
cd $GITHOME

# Setup gitolite when system start
if [ ! -f $INITFILE ]; then
    if [ -d repositories ]; then
        import_repo
    fi

    if [ ! -d .gitolite ]; then
        setup_gitolite
    fi
    touch $INITFILE
fi

service ssh start
service postfix start

if [ $# -ne 0 ]; then
    exec $*
else
    # do nothing
    while [ 1 ]; do sleep 3600;  done
fi


