#!/bin/sh

none_imgs=`sudo docker images|grep "^<none>"|awk '{print $3}'`

if [ -n "$none_imgs" ]; then
    sudo echo "$none_imgs" | xargs docker rmi
fi

echo "Docker none images clean !"


