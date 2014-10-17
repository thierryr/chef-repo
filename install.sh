#!/bin/bash

if ! type "chef-solo" > /dev/null; then
  wget https://www.opscode.com/chef/install.sh -O getchef.sh && bash getchef.sh && rm getchef.sh
fi

rm -r chef-repo.tar.gz chef-repo 2>/dev/null

wget https://raw.githubusercontent.com/thierryr/chef-repo/master/master.tar.gz --no-check-certificate -O chef-repo.tar.gz

tar xzf chef-repo.tar.gz

cd chef-repo && FRCP=$1 chef-solo -c solo/solo.rb -j solo/solo.json && cd ..
rm -rf chef-repo
