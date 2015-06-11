#!/bin/sh

top=`pwd`
ipaddr=`sudo docker inspect gitolite|grep IPAddress|awk -F\" '{print $4}'`

project=gitolite-admin

rm -rf .tmp
mkdir .tmp
cd .tmp


echo "git clone git@${ipaddr}:$project"
git clone git@${ipaddr}:$project

cd $project

echo "hello world" >> README.md

git add .
git commit -m "test"
git push




