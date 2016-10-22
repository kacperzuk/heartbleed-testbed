#!/bin/bash
set -e
for i in exploit ftp-bystander http-bystander metasploit nginx-bleed proftpd-bleed; do
	docker pull kacperzuk/heartbleed-testbed-$i
done
