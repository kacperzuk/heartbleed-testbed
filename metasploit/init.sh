#!/bin/bash

source /usr/local/rvm/scripts/rvm
/etc/init.d/postgresql start
cd /tmp/data
bash -c "cd /tmp/data && GEM_HOME=/usr/local/rvm/gems/ruby-2.3.1@metasploit-framework msfconsole -r /scripts/$1"
echo "Done."
