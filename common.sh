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

nodejs() {
    print_head "Download prereq"
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
    status_check $?

    print_head "Installing nodejs"
    yum install nodejs -y &>>${log_file}
    status_check $?

    print_head "Adding User"
    useradd roboshop &>>${log_file}
    status_check $?

    print_head "Creating a Dir"
    mkdir /app &>>${log_file}
    status_check $?

    print_head "Download and Unzip pakages"
    curl -L -o /tmp/$(component).zip https://roboshop-artifacts.s3.amazonaws.com/$(component).zip &>>${log_file}
    cd /app &>>${log_file}
    unzip /tmp/$(component).zip &>>${log_file}
    status_check $?

    print_head "Installing packages"
    cd /app &>>${log_file}
    npm install &>>${log_file}
    status_check $?

    print_head "Copying files"
    cp ${code_dir}/configs/$(component).service /etc/systemd/system/$(component).service &>>${log_file}
    status_check $?

    print_head "Restarting Deamon"
    systemctl daemon-reload &>>${log_file}
    status_check $?

    print_head "Enabeling Catalogue"
    systemctl enable $(component) &>>${log_file}
    status_check $?

    print_head "starting $(component)"
    systemctl start $(component) &>>${log_file}
    status_check $?

    print_head "copying repos"
    cp ${code_dir}/configs/mongodb.repo /etc/systemd/system/mongodb.repo &>>${log_file}
    status_check $?

    print_head "install mongo-shell"
    yum install mongodb-org-shell -y &>>${log_file}
    status_check $?

    print_head "accessing mongodb"
    mongo --host mongodb.itsmevdps.online </app/schema/$(component).js &>>${log_file}
    status_check $?
}