source common.sh

print_head "copy Mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?

print_head "Installing MongoDB"
yum install mongodb-org -y &>>${log_file}
status_check $?

print_head "Changing address"
sed -e -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${log_file}
status_check $?

print_head "Enabling MongoDB"
systemctl enable mongod &>>${log_file}
status_check $?

print_head "Starting MongoDB"
systemctl start mongod &>>${log_file}
status_check $?