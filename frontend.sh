source common.sh    

print_head "installing nginx"
yum install nginx -y &>>${log_file}
status_check $?

print_head "Removing files"
rm -rf /usr/share/nginx/html/* &>>${log_file}
status_check $?

print_head "Download files"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}
status_check $?

print_head "copy & Extract files"
cd /usr/share/nginx/html &>>${log_file}
unzip /tmp/frontend.zip &>>${log_file}
status_check $?

print_head "copy nginx for roboshop"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf  &>>${log_file}
status_check $?

print_head "enabeling nginx"
systemctl enable nginx &>>${log_file}
status_check $?

print_head "Starting nginx"
systemctl restart nginx &>>${log_file}
status_check $?