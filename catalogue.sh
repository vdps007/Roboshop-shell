source common.sh

component=catalogue
#nodejs

print_head "Download prereq"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?

print_head "Installing nodejs"
yum install nodejs -y &>>${log_file}
status_check $?

print_head "Adding User"
id roboshop &>>${log_file}
if [ $? -ne 0 ]; then
    useradd roboshop &>>${log_file}
fi
status_check $?

print_head "Creating a Dir"
if [ ! -d /app ]; then
    mkdir /app &>>${log_file}
fi
status_check $?

print_head "Delete Old Content"
rm -rf /app/* &>>${log_file}
status_check $?

print_head "Download and Unzip pakages"
curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
cd /app
unzip /tmp/${component}.zip &>>${log_file}
status_check $?

print_head "Installing packages"
npm install &>>${log_file}
status_check $?

print_head "Copying files"
cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
status_check $?

print_head "Restarting Deamon"
systemctl daemon-reload &>>${log_file}
status_check $?

print_head "Enabeling Catalogue"
systemctl enable ${component} &>>${log_file}
status_check $?

print_head "starting ${component}"
systemctl start ${component} &>>${log_file}
status_check $?

print_head "copying repos"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?

print_head "install mongo-shell"
yum install mongodb-org-shell -y &>>${log_file}
status_check $?

print_head "accessing mongodb"
mongo --host mongodb.itsmevdps.online </app/schema/${component}.js &>>${log_file}
status_check $?