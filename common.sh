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

app_prereq_setup(){
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
}

schema_setup(){
    if [ "${schema_type}" == "mongodb" ]; then

        print_head "copying repos"
        cp ${code_dir}/Configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
        status_check $?

        print_head "install mongo-shell"
        yum install mongodb-org-shell -y &>>${log_file}
        status_check $?

        print_head "Loading mongodb Schema"
        mongo --host mongodb.itsmevdps.online </app/schema/${component}.js &>>${log_file}
        status_check $?
    elif [ "${schema_type}" == "mysql" ]; then
        print_head "Installing mysql"
        yum install mysql -y &>>${log_file}
        status_check $?

        print_head "loading mysql schema"
        mysql -h mysql.itsmevdps.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>${log_file}
        status_check $?

    fi
}

systemd_setup(){
    print_head "Copying files"
    cp ${code_dir}/Configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
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
}

nodejs() {
    print_head "Download prereq"
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
    status_check $?

    print_head "Installing nodejs"
    yum install nodejs -y &>>${log_file}
    status_check $?

    app_prereq_setup

    print_head "Installing NodeJS packages"
    npm install &>>${log_file}
    status_check $?

    schema_setup

    systemd_setup

}

java(){
    print_head "Installing Maven"
    yum install maven -y &>>${log_file}
    status_check $?

    app_prereq_setup

    print_head "Download packages"
    mvn clean package &>>${log_file}
    mv target/${component}-1.0.jar ${component}.jar &>>${log_file}
    status_check $?

    schema_setup

    systemd_setup
}

python() {

  print_head "Install Python"
  yum install python36 gcc python3-devel -y &>>${log_file}
  status_check $?

  app_prereq_setup

  print_head "Download Dependencies"
  pip3.6 install -r requirements.txt &>>${log_file}
  status_check $?

  systemd_setup
}