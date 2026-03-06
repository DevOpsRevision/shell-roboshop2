#!/bin/bash

source ./common.sh
APP_NAME="shipping"
CHECK_ROOT

APP_SETUP
MAVEN_SETUP
SYSTEMD_SETUP


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

PRINT_TIME