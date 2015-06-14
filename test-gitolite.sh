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

mailinglist=`grep mailinglist conf/gitolite.conf`
if [ -z "$mailinglist" ]; then
    sed -i '/repo gitolite/a\    config hooks.mailinglist = xuejianqing@star-net.cn, 123935925@qq.com' conf/gitolite.conf
fi

git add .
git commit -m "test"
git push


echo "do push then email send now..."
echo "Send Email Test" >> README.md
git commit -am "Trigger email send"
git push



