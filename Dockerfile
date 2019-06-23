FROM mysql:5.7

ENV MYSQL_ROOT_PASSWORD ""
ENV MYSQL_ROOT_HOST ""

EXPOSE 3306

ADD init.sh /docker-entrypoint-initdb.d/
ADD mysql-init.sh /
ADD dbscripts260/ /

WORKDIR /

CMD ["mysqld"]