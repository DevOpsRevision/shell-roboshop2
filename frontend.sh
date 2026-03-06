#!/bin/bash

source ./common.sh
APP_NAME="frontend"

CHECK_ROOT

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Nginx Module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx Module"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling Nginx Service"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting Nginx Service"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Cleaning Nginx Default Content"

curl -L -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Frontend Code"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "Changing Directory"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting Frontend Code"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Removing Default Nginx Configuration"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying Nginx Configuration"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting Nginx Service"

PRINT_TIME