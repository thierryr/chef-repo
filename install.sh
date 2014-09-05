#!/bin/bash

if ! type "chef-solo" > /dev/null; then
  wget https://www.opscode.com/chef/install.sh -O getchef.sh && bash getchef.sh && rm getchef.sh
fi

wget https://github.com/jackhong/chef-repo/archive/master.tar.gz -O chef-repo.tar.gz

tar xzf chef-repo.tar.gz
rm -r chef-repo.tar.gz chef-repo 2>/dev/null
mv chef-repo-master chef-repo

cd chef-repo && chef-solo -c solo/solo.rb -j solo/solo.json && cd ..
rm -rf chef-repo
