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

if ! rabbitmqctl list_users | grep -q "^roboshop"
then
    rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
    VALIDATE $? "Adding RabbitMQ User"
else
    echo -e "$G INFO :: RabbitMQ user 'roboshop' already exists. Skipping user creation. $N" | tee -a $LOG_FILE
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting RabbitMQ User Permissions"

PRINT_TIME