#!/bin/bash

### Init gitolite server when docker container start

export PATH=$PATH:/usr/local/gitolite
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"

GITOLITE=/usr/local/gitolite/gitolite

GITHOME=/home/git

INITFILE=$GITHOME/.gitserver_init

# Install auto email hook and account
function setup_mail() {
    echo "setup email hooks..."
    POST_MAIL=/usr/local/gitolite/post-receive-email
    su git -c "cp $POST_MAIL $GITHOME/.gitolite/hooks/common/post-receive"
    su git -c "$GITOLITE setup --hooks-only"

    setup_email_config
}

# Copy msmtprc file or create with EMAIL_* environments
function setup_email_config() {
    if [ -n "$MSMTPRC" ]; then
        if [ ! -f "$MSMTPRC" ]; then
            echo >&2 "Cannot find file : $MSMTPRC"
            return
        fi

        echo "Setup Msmtp config from $MSMTPRC"
        su git -c "cp $MSMTPRC ~/.msmtprc"
        su git -c "chmod 600 ~/.msmtprc"
        return
    fi

    if [ -z "$EMAIL_ACCOUNT" ]; then
        return
    fi

    echo "Setup Msmtp config file :"

    domain=`echo $EMAIL_ACCOUNT | awk -F\@ '{print \$2}'`
    if [ -z "$domain" ]; then
        echo >&2 "Invalid email account address : $EMAIL_ACCOUNT"
        return
    fi

    if [ -z "$EMAIL_HOST" ]; then
        EMAIL_HOST="mail.${domain}"
    fi

    echo "    Email Address : $EMAIL_ACCOUNT"
    echo "    Email Host    : $EMAIL_HOST"

    su git -c "cat << EOF > ~/.msmtprc
account default
host $EMAIL_HOST
auth login
from $EMAIL_ACCOUNT
user $EMAIL_ACCOUNT
password $EMAIL_PASSWD
logfile ''
EOF"
    su git -c "chmod 600 ~/.msmtprc"
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

    setup_mail
}

function import_repo() {
    GITADMIN_TMPD=/tmp/gitolite-admin.git

    if [ -d ./repositories/gitolite-admin.git ]; then
        mv ./repositories/gitolite-admin.git  $GITADMIN_TMPD
    fi

    setup_gitolite

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


