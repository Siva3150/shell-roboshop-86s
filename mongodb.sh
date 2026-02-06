#!/bin/bash 

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)


LOGS_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/shell-script-logs/18-logs.log


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

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Adding mongodb repo" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb" 

systemctl enable mongod  &>>$LOG_FILE
VALIDATE $? "Enabling mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connections to mongodb"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting mongodb"

