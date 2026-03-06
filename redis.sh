#!/bin/bash

source ./common.sh
APP_NAME="redis"

CHECK_ROOT

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling Redis Module"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis Module"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no'  /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Updating Redis Configuration"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis Service"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting Redis Service"

PRINT_TIME


