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