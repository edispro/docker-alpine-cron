# docker-alpine-cron

Dockerfile and scripts for creating image with Cron based on Alpine  
Installed packages: dcron wget rsync ca-certificates  

#### Environment variables:

CRON_STRINGS - strings with cron jobs. Use "\n" for newline (Default: undefined)   
CRON_TAIL - if defined cron log file will read to *stdout* by *tail* (Default: undefined)   true/false
By default cron running in foreground  

#### Cron files
- /etc/cron.d - place to mount custom crontab files  

When image will run, files in */etc/cron.d* will copied to */var/spool/cron/crontab*.   
If *CRON_STRINGS* defined script creates file */var/spool/cron/crontab/CRON_STRINGS*  

#### Log files
Log file by default placed in /var/log/cron/cron.log 

#### Simple usage:
```
docker run --name="alpine-cron-sample" -d \
-v /path/to/app/conf/crontabs:/etc/cron.d \
-v /path/to/app/scripts:/scripts \
xordiv/docker-alpine-cron
```

#### With scripts and CRON_STRINGS
```
docker run --name="alpine-cron-sample" -d \
-e 'CRON_STRINGS=* * * * * root /scripts/myapp-script.sh'
-v /path/to/app/scripts:/scripts \
xordiv/docker-alpine-cron
```

#### Get URL by cron every minute
```
docker run --name="alpine-cron-sample" -d \
-e 'CRON_STRINGS=* * * * * root wget https://sample.dockerhost/cron-jobs'
xordiv/docker-alpine-cron
```
---------------------------------
Mysql Backup Script
```
 SYNOPSIS
    /doBackupDatabase.sh 

 OPTIONS
   --DB_USER=[name]             Database user name
   --DB_HOST=[hostname] Database host name
   --DB_PORT=[port]             Database host port
   --DB_PASS=[password]         Database user password
   --DB_NAME=[name]             Database name
   --FTP_USER=[name]                    FTP server username
   --FTP_PASS=[password]                FTP server user password
   --FTP_HOST=[hostname]                FTP server hostname
   --FTP_PORT=[port]            FTP server port
   --FTP_PROTO=[ftp]            Protocol to use (default: ftp) ,sftp
   --REMOTE_PATH=[path]         Your FTP backup destination folder
   -h, --help                           print this help
```
--------------------------------
File Backup Script 
```
    SYNOPSIS
    /doBackupFile.sh 

 OPTIONS
   --LOCAL_PATH=[path]          Local Dir path
   --EXCLODE1=[path]    exclode dir or file path
   --EXCLODE2=[path]            exclode dir or file path
   --EXCLODE3=[path]            exclode dir or file path
   --EXCLODE4=[path]            exclode dir or file path
   --FTP_USER=[name]                    FTP server username
   --FTP_PASS=[password]                FTP server user password
   --FTP_HOST=[hostname]                FTP server hostname
   --FTP_PORT=[port]            FTP server port
   --FTP_PROTO=[ftp]            Protocol to use (default: ftp) ,sftp
   --REMOTE_PATH=[path]         Your FTP backup destination folder
   -h, --help                           print this help
   ```
---------
   #### Simple usage:
```
docker run --name="alpine-cron-sample" -d \
-v /path/to/app/conf/crontabs:/etc/cron.d \
-v /path/to/app/scripts:/scripts \
-v /path/to/file/dir:/data \
xordiv/d
```