#!/bin/bash 

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)


LOGS_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/shell-script-logs/18-logs.log
MONGODB_HOST=mongodb.sivadevops.space


mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then 
   echo "Error: Please run this script with root previlages" 
   exit 1 # failure is other than 0
fi 

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then 
      echo -e "$2... $R failed $N " | tee -a $LOG_FILE
      exit 1 # failure is other than 0
    else 
     echo -e "$2...$G success $N" | tee -a $LOG_FILE
    fi 

}

##### NodeJS ####
dnf module disable nodejs -y
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs 20"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"

### System user ###
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating roboshop user"

mkdir /app 
VALIDATE $? "moving to /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading code"

mkdir /app 
VALIDATE $? "moving to /app directory"

unzip /tmp/catalogue.zip
VALIDATE $? "unzipping the code"

npm install 
VALIDATE $? "Installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable catalogue 
VALIDATE $? "Enabling catalogue"

systemctl start catalogue
VALIDATE $? "Starting catalogue"

dnf install mongodb-mongosh -y
VALIDATE $? "Installing mongodb client"

mongosh --host $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "Loading schema"

systemctl restart catalogue 
VALIDATE $? "Restarting catalogue"



