#!/bin/bash

source ./common.sh
APP_NAME="mysql"

CHECK_ROOT


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL Service"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL Service"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Securing MySQL Installation"

PRINT_TIME