#!/bin/bash

while true; do
    curl -T credentials.php --ftp-ssl -k ftp://ftpd/ --user testuser:boordodeshato2009
done
