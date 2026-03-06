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

mkdir -p "$LOGS_FOLDER"

CHECK_ROOT(){
  if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR :: You are NOT root user. Please run this script with root priviliges. $N" | tee -a $LOG_FILE
    exit 1 # Exit with a non-zero status to indicate an error
  else
    echo -e "$G INFO :: You are root user. Proceeding with the script execution. $N" | tee -a $LOG_FILE
  fi
}

VALIDATE(){
  if [ $1 -ne 0 ]; then
    echo -e "$R ERROR :: $2 installation .... $R FAILURE $N" | tee -a $LOG_FILE
    exit 1 # Exit with a non-zero status to indicate an error
  else
    echo -e "$G INFO :: $2 installation .... $G SUCCESSFUL. $N" | tee -a $LOG_FILE
  fi
}

PRINT_TIME(){
    END_TIME=$(date +%s)
    ELAPSED_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "$G INFO :: $APP_NAME setup completed in $ELAPSED_TIME seconds. $N" | tee -a $LOG_FILE
}


#NodeJS Setup
NODEJS_SETUP(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling NodeJS Module"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS Module"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Application Dependencies"
}

#Application Setup
APP_SETUP(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
      useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
      VALIDATE $? "Adding Application User"
    else
      echo -e "$G INFO :: User 'roboshop' already exists. Skipping user creation. $N" | tee -a $LOG_FILE
    fi

    curl -L -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading Application Code"

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "Creating Application Directory"

    cd /app &>>$LOG_FILE
    VALIDATE $? "Changing Directory"

    rm -rf /app/* &>>$LOG_FILE
    VALIDATE $? "Cleaning Application Directory"

    unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
    VALIDATE $? "Extracting Application Code"
}

#SystemD Setup
SYSTEMD_SETUP(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service &>>$LOG_FILE
    VALIDATE $? "Copying SystemD Service File"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Reloading SystemD"

    systemctl enable $APP_NAME &>>$LOG_FILE
    VALIDATE $? "Enabling $APP_NAME Service"

    systemctl start $APP_NAME &>>$LOG_FILE
    VALIDATE $? "Starting $APP_NAME Service"
}

