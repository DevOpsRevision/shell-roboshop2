#!/bin/bash

source ./common.sh

APP_NAME="catalogue"

CHECK_ROOT
APP_SETUP
NODEJS_SETUP
SYSTEMD_SETUP

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copying MongoDB Repository File"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Client"


STATUS=$(mongosh --host mongodb.easydevops.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.easydevops.fun </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
  echo -e "$G INFO :: Data already exists in MongoDB. Skipping data load. $N" | tee -a $LOG_FILE
fi

PRINT_TIME
