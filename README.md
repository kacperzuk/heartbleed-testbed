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
cd proftpd-bleed
docker build -t proftpd-bleed .
docker run -p 2121:21 -p 30000-30009:30000-30009 -it --rm --name=proftpd-bleed proftpd-bleed
```

Test connection:
```
$ openssl s_client -connect localhost:2121 -starttls ftp
$ curl -k --ftp-ssl ftp://localhost:2121/ --user testuser:bordodeszato2009
$ curl -vk --ftp-ssl ftp://localhost:2121/ --user testuser:bordodeszato2009
```

Run a fake-user that uploads credentials.php to server few times a second:
```
cd ftp-bystander
docker build -t ftp-bystander .
docker run --link proftpd-bleed:ftpd -it --rm --name=ftp-bystander ftp-bystander
```

Run exploit from metasploit (it extracts private key and dumps it into /tmp/msf4/loot):
```
cd metasploit
docker build -t metasploit .
docker run --link proftpd-bleed:ftpd --rm -it -v /tmp/msf4:/root/.msf4 metasploit /usr/local/bin/init.sh ftp-hb.rc
```

Run authtls-heartbleed.py exploit (it tries to extract PHP file, but won't succeed ever because proftpd is forking):
```
cd exploit
docker build -t exploit .
docker run --link proftpd-bleed:ftpd --rm -it exploit python3 authtls-heartbleed.py ftpd 21
```

Run vulnerable HTTPS server
```
cd nginx-bleed
docker build -t nginx-bleed .
docker run -p 4443:443 -it --rm --name=nginx-bleed nginx-bleed
```

Test connection:
```
$ openssl s_client -connect localhost:4443
$ curl -k https://localhost:4443/confidential.txt --user testuser:bordodes
$ curl -vk https://localhost:4443/confidential.txt --user testuser:bordodes
```

Run a fake-user that uploads credentials.php to server few times a second:
```
cd http-bystander
docker build -t http-bystander .
docker run --link nginx-bleed:httpd -it --rm --name=http-bystander http-bystander
```

Run exploit from metasploit (it extracts private key):
```
cd metasploit
docker build -t metasploit .
docker run --link nginx-bleed:httpd --rm -it -v /tmp/msf4:/root/.msf4 metasploit /usr/local/bin/init.sh http-hb.rc
```

Run https-heartbleed.py exploit (nginx isn't forking, so it should find the confidential file):
```
cd exploit
docker built -t exploit .
docker run --link nginx-bleed:httpd --rm -it exploit python3 https-heartbleed.py httpd 443
```


Random info:
======

1. stary openssl nie potrafi zainstalowac juz sobie man pages z nowym perlem, wiec zamaist make install trzeba make install_sw
2. proftpd jest gupie i nie linkuje poprawnie libow wymaganych przez openssl, trzeba dodac `-ldl` do `LDFLAGS`
3. nowe gcc jest gupie i wydaje mi sie, ze `-ldl` nie jest potrzebne wiec i tak go nie uzywa. trzeba dodac `-Wl,--no-as-needed` przed `-ldl` w `LDFLAGS`
4. FTP w passive mode wymaga przekierowania wiecej niz jednego portu...
