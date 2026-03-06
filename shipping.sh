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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
  VALIDATE $? "Adding Application User"
else
  echo -e "$G INFO :: User 'roboshop' already exists. Skipping user creation. $N" | tee -a $LOG_FILE
fi

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Application Code"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating Application Directory"

cd /app &>>$LOG_FILE
VALIDATE $? "Changing Directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Cleaning Application Directory"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Extracting Application Code"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Building Application"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Moving Application Jar"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying SystemD Service File"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading SystemD"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling Shipping Service"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting Shipping Service"

mysql -h mysql.easydevops.fun -uroot -pRoboShop@1 -e "use cities"

if [ $? -ne 0 ]; then
  echo -e "$Y WARNING :: Shipping schema is not loaded. Loading schema now. $N" | tee -a $LOG_FILE
  # Load the schema
  dnf install mysql -y &>>$LOG_FILE
  VALIDATE $? "Installing MySQL Client"

  mysql -h mysql.easydevops.fun -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
  VALIDATE $? "Loading Shipping Schema"

  mysql -h mysql.easydevops.fun -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
  VALIDATE $? "Creating Application User in MySQL"

  mysql -h mysql.easydevops.fun -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
  VALIDATE $? "Granting Privileges to Application User in MySQL"
else
  echo -e "$G INFO :: Shipping schema is already loaded. Skipping schema loading. $N" | tee -a $LOG_FILE
fi


systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting Shipping Service"

END_TIME=$(date +%s)
ELAPSED_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$G INFO :: Shipping setup completed in $ELAPSED_TIME seconds. $N" | tee -a $LOG_FILE
