source common.sh

roboshop_pass=$1
if [ -z "${roboshop_pass}" ]; then
    echo -e "\e[31mMissing RabbitMQ App User Password argument\e[0m"
  exit 1
fi

print_head "Downloading erlang packages"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${log_file}
status_check $?

print_head "Downloading rabbitmq packages "
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${log_file}
status_check $?

print_head "Starting erlang & rabbitmq"
yum install erlang rabbitmq-server -y &>>${log_file}
status_check $?

print_head "Enabeling rabbitmq"
systemctl enable rabbitmq-server &>>${log_file}
status_check $?

print_head "Starting rabbitmq"
systemctl start rabbitmq-server &>>${log_file} 
status_check $?

print_head "adding user to rabbitmq"
rabbitmqctl list_users | grep roboshop &>>${log_file}
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop ${roboshop_pass} &>>${log_file}
fi
status_check $?

print_head "Starting rabbitmq"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${log_file}
status_check $?