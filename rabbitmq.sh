#!/bin/bash

source ./common.sh
APP_NAME="rabbitmq"

CHECK_ROOT

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Adding RabbitMQ Repository"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling RabbitMQ Service"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting RabbitMQ Service"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Adding RabbitMQ User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting RabbitMQ User Permissions"

PRINT_TIME