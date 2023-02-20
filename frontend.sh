code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}

print_head() {
    echo -e "\e[36m$1\e[0m]"
}

status_check(){
    if [ $1 -eq 0 ]; then
        echo SUCCESS
    else
        echo FAILURE
        echo "Read the log file ${log_file} for more information about error"
        exit 1
    fi
}

print_head "installing nginx"
yum install nginx -y &>>${log_file}
status_check $?
print_head "Removing files"
rm -rf /usr/share/nginx/html/* &>>${log_file}
status_check $?
print_head "Download files"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}
status_check $?
print_head "copy files"
cd /usr/share/nginx/html &>>${log_file}
status_check $?
print_head "unzip files"
unzip /tmp/frontend.zip &>>${log_file}
status_check $?
print_head "enabeling nginx"
systemctl enable nginx &>>${log_file}
status_check $?
print_head "Starting nginx"
systemctl restart nginx &>>${log_file}
status_check $?