source common.sh
mysql_pass=$1
if [ -z "${mysql_pass}" ]; then
    echo -e "\e[31mMissing MySQL Root Password argument\e[0m"
    exit 1
fi


print_head "disable existing mysql"
dnf module disable mysql -y &>>${log_file}
status_check $?

print_head "ccopying repos"
cp ${code_dir}/Configs/mysql.repo /etc/yum.repos.d/mysql.repo &>>${log_file}
status_check $?

print_head "installing mysql"
yum install mysql-community-server -y &>>${log_file}
status_check $?

print_head "enabeling mysql"
systemctl enable mysqld &>>${log_file}
status_check $?

print_head "starting mysql"
systemctl start mysqld &>>${log_file}
status_check $?

print_head "setting up root user"
echo show databases | mysql -uroot -p${mysql_pass} &>>${log_file}
if [ $? -ne 0 ]; then
    mysql_secure_installation --set-root-pass ${mysql_pass}  &>>${log_file}
fi
status_check $?