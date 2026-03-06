#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f 1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p "$LOGS_FOLDER"

if [ $USERID -ne 0 ]; then
  echo -e "$R ERROR :: You are NOT root user. Please run this script with root priviliges. $N" | tee -a $LOG_FILE
  exit 1 # Exit with a non-zero status to indicate an error
else
  echo -e "$G INFO :: You are root user. Proceeding with the script execution. $N" | tee -a $LOG_FILE
fi

VALIDATE(){
  if [ $1 -ne 0 ]; then
    echo -e "$R ERROR :: $2 installation .... $R FAILURE $N" | tee -a $LOG_FILE
    exit 1 # Exit with a non-zero status to indicate an error
  else
    echo -e "$G INFO :: $2 installation .... $G SUCCESSFUL. $N" | tee -a $LOG_FILE
  fi
}

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

END_TIME=$(date +%s)
ELAPSED_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$G INFO :: Frontend setup completed in $ELAPSED_TIME seconds. $N" | tee -a $LOG_FILE