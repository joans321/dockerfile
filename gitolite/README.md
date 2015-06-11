# Gitolite

Gitolite image base on ubuntu 14.04 and support auto send email after repo update.

# Feature

* gitolite server
* support import repositories
* support auto email when update repo --- pending
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


# Require
* admin's pub key for new repositories
* mail config for msmtp
* mount old repo dir to /home/git/repositories for import the already repositories

# Enviroment

* ubuntu 14.04
* openssh-server
* gitolite
* postfix
* msmtp
* mutt

