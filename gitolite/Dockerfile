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


# Fix locale bug
RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config


# Locale language : en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'LANGUAGE="en_US:en"' >> /etc/default/locale


# Add git user and install gitolite for git user
RUN adduser --system --group --shell /bin/bash git
RUN cd /tmp; git clone http://github.com/sitaramc/gitolite
RUN cd /tmp/gitolite; git checkout -b v3.6.3 v3.6.3
RUN mkdir -p /usr/local/gitolite
RUN /tmp/gitolite/install -to /usr/local/gitolite
RUN echo "PATH=\$PATH:/usr/local/gitolite" >> /etc/bash.bashrc


# Clear unuse packages
RUN rm -rf /tmp/gitolite
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove


# Setup enviroment and start some service for gitolite
ADD setup.sh /init
RUN chmod +x /init

# For test
CMD echo "hello gitolite server"

ENTRYPOINT ["/init"]

# sshd port
EXPOSE 22

