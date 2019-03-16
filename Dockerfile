FROM alpine:latest
MAINTAINER d@d.ru
 
RUN apk update && apk add dcron bash curl wget rsync ca-certificates openssh-client mysql-client lftp && rm -rf /var/cache/apk/*

RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
ADD etc/lftp.conf /etc/lftp.conf
COPY /scripts/* /
RUN chmod  +x /docker-entry.sh
RUN chmod  +x /docker-cmd.sh
RUN chmod  +x /doBackupDatabase.sh
RUN chmod  +x /doBackupFile.sh
RUN mkdir /backups
RUN chmod  777 /backups

ENTRYPOINT ["/docker-entry.sh"]
CMD ["/docker-cmd.sh"]
