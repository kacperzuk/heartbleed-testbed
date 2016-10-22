#!/bin/bash
set -e
for i in exploit ftp-bystander http-bystander metasploit nginx-bleed proftpd-bleed; do
	pushd $i
	docker build -t kacperzuk/heartbleed-testbed-$i .
	popd
done
