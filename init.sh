#!/bin/bash

echo "INITIALISING DATABASE: INTERNAL"

sh /mysql-init.sh -h localhost -u root -p ${MYSQL_ROOT_PASSWORD} -v wso2user -w wso2password -l int -r 260 -d n

echo "INITIALISING DATABASE: EXTERNAL"

sh /mysql-init.sh -h localhost -u root -p ${MYSQL_ROOT_PASSWORD} -v wso2user -w wso2password -l ext -r 260 -d n