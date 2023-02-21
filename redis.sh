source common.sh

print_head "Installing Redis repos"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${log_file}
status_check $?

print_head "Enabeling Redis 6.2 modules"
dnf module enable redis:remi-6.2 -y &>>${log_file}
status_check $?

print_head "Installing Redis 6.2"
yum install redis -y &>>${log_file}
status_check $?

print_head "Changing address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${log_file}
status_check $?

print_head "Enabeling Redis"
systemctl enable redis &>>${log_file}
status_check $?

print_head "Starting Redis"
systemctl start redis &>>${log_file}
status_check $?