#!/bin/bash

while true; do
    curl -T credentials.php --ftp-ssl -k ftp://ftpd/ --user testuser:bordodeszato2009
    curl --ftp-ssl -k ftp://ftpd/credentials.php --user testuser:bordodeszato2009
done
