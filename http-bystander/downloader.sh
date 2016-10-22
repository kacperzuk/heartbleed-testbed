#!/bin/bash

while true; do
	echo -n "."
	curl -sk https://httpd/confidential.txt --user testuser:bordodes >/dev/null
	sleep 0.1
done
