# Gitolite

Gitolite image base on ubuntu 14.04 and support auto send email after repo update.

# Feature

* gitolite server
* support import repositories
* support auto email when update repo
* support jenkins notify ---- pending

# Usage

## New Git Server

Gitolite only need your ssh public key if you are first time to use it.
Generator a new ssh key in the *~/.ssh* directory with command :

    $ ssh-keygen -f ~/.ssh/id_rsa  -t rsa -N ''

If you have any issue, refer to https://help.github.com/articles/generating-ssh-keys

Run docker command to start gitolite server with your ssh public key :

    $ sudo docker run -it --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" joans321/gitolite

## Import Git Repositories

If you already have repositories, what you need to do is import them.

Run docker command to start gitolite with your repositories :

	$ sudo docker run -it --rm -v YourRepoDir:/home/git/repositories joans321/gitolite

## Configure email account

If you use postfix as email server, just skip this category.

The email client is msmtprc, so you need to setup account for it.

You have two way to setup the account config :

* Adding a data volument and assign the msmtprc path through by var *MSMTPRC*. Do command like this:

	$ sudo docker run -it --rm -v YourMsmtprcPath:/data -e MSMTPRC=/data/msmtprc joans321/gitolite

* Use email account and password through by var *EMAIL_ACCOUNT* and *EMAIL_PASSWD*. Do command like this:

	$ sudo docker run -it --rm -e EMAIL_ACCOUNT=EmailAddress -e EMAIL_PASSWD=EmailPasswd joans321/gitolite

> Note : email host default is mail.{$domain of your email address}, you can change through by var EMAIL_HOST.


## Configure email recipients

* clone the gitolite-admin at your container
* add *config hooks.mailinglist* to *conf/gitolite.conf* file for the repo
* Example like this :

```sh
repo gitolite-admin
    RW+     =   admin
    config hooks.mailinglist = YourEmailAddress, AnotherManEmail
```

> Note : hooks.mailinglist will work at next commit

# Require
* admin's pub key for new repositories
* email config for msmtp if not use postfix
* mount old repo dir to /home/git/repositories for import the already repositories

# Enviroment

* ubuntu 14.04
* openssh-server
* gitolite
* postfix
* msmtp
* mutt

