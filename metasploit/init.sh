#!/bin/bash

source /usr/local/rvm/scripts/rvm
/etc/init.d/postgresql start
/opt/msf/msfupdate --git-branch master
cd /tmp/data
echo "Running explooit:"
cat /hb.rc
bash -c "cd /tmp/data && GEM_HOME=/usr/local/rvm/gems/ruby-2.3.1@metasploit-framework msfconsole -r /hb.rc"
echo "Done."
