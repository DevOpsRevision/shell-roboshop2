#!/bin/bash

source ./common.sh

CHECK_ROOT

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Server" 

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Updating MongoDB Configuration"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"

