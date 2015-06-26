# Thanks to miracle2k for the project : http://github.com/miracle2k/dockerfiles/tree/master/gitolite

FROM ubuntu:14.04

MAINTAINER joans <xjq9296@gmail.com>


# Use aliyun for chinse
# ADD sources.list /etc/apt/sources.list


# Install git and ssh server
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y openssh-server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils
RUN apt-get install -y msmtp
RUN apt-get install -y mutt

# For debug
RUN apt-get install -y rsyslog


# Fix locale bug
RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config


# Locale language : en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'LANGUAGE="en_US:en"' >> /etc/default/locale


# Add git user and install gitolite for git user
RUN adduser --group --shell /bin/bash git
RUN cd /tmp; git clone http://github.com/sitaramc/gitolite
RUN cd /tmp/gitolite; git checkout -b v3.6.3 v3.6.3
RUN mkdir -p /usr/local/gitolite
RUN /tmp/gitolite/install -to /usr/local/gitolite
RUN echo "PATH=\$PATH:/usr/local/gitolite" >> /etc/bash.bashrc

# Setup email post-receive script
ADD post-receive-email /usr/local/gitolite/

# Clear unuse packages
RUN rm -rf /tmp/gitolite
RUN rm -rf /tmp/dockerfile
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove

# Setup enviroment and start some service for gitolite
ADD init.sh /init
RUN chmod +x /init

ENTRYPOINT ["/init"]

# sshd port
EXPOSE 22

