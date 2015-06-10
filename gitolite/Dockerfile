# Thanks to miracle2k for the project : https://github.com/miracle2k/dockerfiles/tree/master/gitolite

FROM ubuntu:14.04

MAINTAINER joans <xjq9296@gmail.com>

# Use aliyun for chinse
# ADD sources.list /etc/apt/sources.list

# Install git and ssh server
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y openssh-server

# Fix locale bug
RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config

# Locale language : en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'LANGUAGE="en_US:en"' >> /etc/default/locale

# Add git user and install gitolite for git user
RUN adduser --system --group --shell /bin/bash git
RUN su git -c "mkdir /home/git/bin"
RUN cd /home/git; su git -c "git clone https://github.com/sitaramc/gitolite"
RUN cd /home/git/gitolite; su git -c "git checkout -b v3.6.3 v3.6.3"
RUN cd /home/git/gitolite; su git -c "./install -ln"

# For test
CMD echo "hello gitolite server"

ENTRYPOINT ["/bin/bash"]

# sshd port
EXPOSE 22

