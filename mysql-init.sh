#!/bin/bash

WSO2USER=wso2user
WSO2PASS=wso2pass
DROPDBIFEXISTS=n

while getopts h:u:p:v:w:l:r:d: option
do
    case "${option}" in
        h) DBHOST=${OPTARG};;
        u) DBUSER=${OPTARG};;
        p) DBPASS=${OPTARG};;
        v) WSO2USER=${OPTARG};;
        w) WSO2PASS=${OPTARG};;
        l) LOCATION=${OPTARG};;
        r) RELEASE=${OPTARG};;
        d) DROPDBIFEXISTS=${OPTARG};;
    esac
done

#CMD sh ./startup.sh -e ${ENVIRONMENT} -h ${DBHOST} -u${DBUSER} -p${DBPASS}

if [ -z $DBHOST ] || [ -z $DBUSER ] || [ -z $DBPASS ] || [ -z $LOCATION ] || [ -r $RELEASE ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./init.sh -h DBHOST -u DBUSER -p DBPASS [-v WSO2USER] [-w WSO2PASS] -l LOCATION <int | ext> -r < 220 | 250 | 260 > -d DROPDBIFEXISTS <y | n>"
    echo " "
    exit
fi

BASESCRIPT=dbscripts${RELEASE}/mysql5.7.sql
APIMSCRIPT=dbscripts${RELEASE}/apimgt/mysql5.7.sql
MBSCRIPT=dbscripts${RELEASE}/mb-store/mysql-mb.sql
SCHEMAPOSTFIX="${RELEASE}_${LOCATION}"

echo "VERIFYING USER ACCOUNTS"
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(1) from mysql.user where user = '${WSO2USER}' and host = 'localhost';" -N -B)
if [ $count -eq 0 ]
then    
    echo " - creating user '${WSO2USER}@localhost':"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create user if not exists '${WSO2USER}'@'localhost' IDENTIFIED BY '${WSO2PASS}';"
    echo " "   
fi
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(1) from mysql.user where user = '${WSO2USER}' and host = '%';" -N -B)
if [ $count -eq 0 ]
then    
    echo " - creating user '${WSO2USER}@%':"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create user if not exists '${WSO2USER}'@'%' IDENTIFIED BY '${WSO2PASS}';"
    echo " "
fi

echo " "
echo "1/6:"
echo " "

if [ "$DROPDBIFEXISTS" = "y" ]; then
    echo "DELETING DATABASES"
    echo " - wso2am_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "DROP DATABASE IF EXISTS wso2am_${SCHEMAPOSTFIX};"
    echo " - wso2um_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "DROP DATABASE IF EXISTS wso2um_${SCHEMAPOSTFIX};"
    echo " - wso2reg_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "DROP DATABASE IF EXISTS wso2reg_${SCHEMAPOSTFIX};"
    echo " - wso2regshared_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "DROP DATABASE IF EXISTS wso2regshared_${SCHEMAPOSTFIX};"
    echo " - wso2mb_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "DROP DATABASE IF EXISTS wso2mb_${SCHEMAPOSTFIX};"
fi

echo " "
echo "VERIFYING WSO2 DATABASE"
#echo ${SCHEMAPOSTFIX}
echo " "

echo " "
echo "2/6:"
echo " "

echo "Verifying wso2am_${SCHEMAPOSTFIX} ..."
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2am_${SCHEMAPOSTFIX}');" -N -B)
if [ $count -eq 0 ]
then
    echo " - creating database wso2am_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create database wso2am_${SCHEMAPOSTFIX};"    
    echo " - creating tables wso2am_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} --database=wso2am_${SCHEMAPOSTFIX} < ${APIMSCRIPT}    
    echo " - granting privileges"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2am_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'localhost';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2am_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'%';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "FLUSH PRIVILEGES;"
    echo " "
    echo " "
fi

echo " "
echo "3/6:"
echo " "

echo "Verifying wso2um_${SCHEMAPOSTFIX} ..."
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2um_${SCHEMAPOSTFIX}');" -N -B)
if [ $count -eq 0 ]
then
    echo " - creating database wso2um_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create database wso2um_${SCHEMAPOSTFIX};"    
    echo " - creating tables wso2um_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} --database=wso2um_${SCHEMAPOSTFIX} < ${BASESCRIPT}    
    echo " - granting privileges"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2um_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'localhost';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2um_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'%';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "FLUSH PRIVILEGES;"
    echo " "
    echo " "
fi

echo " "
echo "4/6:"
echo " "

echo "Verifying wso2reg_${SCHEMAPOSTFIX} ..."
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2reg_${SCHEMAPOSTFIX}');" -N -B)
if [ $count -eq 0 ]
then
    echo " - creating database wso2reg_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create database wso2reg_${SCHEMAPOSTFIX};"    
    echo " - creating tables wso2reg_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} --database=wso2reg_${SCHEMAPOSTFIX} < ${BASESCRIPT}    
    echo " - granting privileges"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2reg_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'localhost';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2reg_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'%';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "FLUSH PRIVILEGES;"
    echo " "
    echo " "
fi

echo " "
echo "5/6:"
echo " "

echo "Verifying wso2regshared_${SCHEMAPOSTFIX} ..."
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2regshared_${SCHEMAPOSTFIX}');" -N -B)
if [ $count -eq 0 ]
then
    echo " - creating database wso2regshared_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create database wso2regshared_${SCHEMAPOSTFIX};"    
    echo " - creating tables wso2regshared_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} --database=wso2regshared_${SCHEMAPOSTFIX} < ${BASESCRIPT}    
    echo " - granting privileges"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2regshared_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'localhost';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2regshared_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'%';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "FLUSH PRIVILEGES;"
    echo " "
    echo " "
fi

echo " "
echo "6/6:"
echo " "

echo "Verifying wso2mb_${SCHEMAPOSTFIX} ..."
count=$(mysql -h ${DBHOST} -u ${DBUSER} -p${DBPASS} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2mb_${SCHEMAPOSTFIX}');" -N -B)
if [ $count -eq 0 ]
then
    echo " - creating database wso2mb_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "create database wso2mb_${SCHEMAPOSTFIX};"    
    echo " - creating tables wso2mb_${SCHEMAPOSTFIX}"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} --database=wso2mb_${SCHEMAPOSTFIX} < ${MBSCRIPT}
    echo " - granting privileges"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2mb_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'localhost';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "GRANT ALL PRIVILEGES ON wso2mb_${SCHEMAPOSTFIX}.* TO '${WSO2USER}'@'%';"
    mysql -h $DBHOST -u $DBUSER -p${DBPASS} -e "FLUSH PRIVILEGES;"
    echo " "
    echo " "
fi

echo " "
echo " "
