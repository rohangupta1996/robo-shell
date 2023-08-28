code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}

print_head() {
  echo -e "\e[35m$1\e[0m"
}
status_check() {
  if [ $1 -eq 0 ]; then
    echo Success
  else
    echo Failure
    exit 1
  fi
}


app_prereq_setup() {
  print_head " create Roboshop User"
        id roboshop &>>${log_file}
        if [ $? -ne 0 ]; then
         useradd roboshop &>>${log_file}
        fi
        status_check $?

        print_head " Creating application directory"
        if [ ! -d /app ]; then
          mkdir /app &>>${log_file}
        fi
        status_check $?

        print_head "Deleting  old content"
        rm -rf /app/* &>>${log_file}
        status_check $?

        print_head "Downloading app content"
        curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
        status_check $?
        cd /app

        print_head "Extracting app Content"
        unzip /tmp/${component}.zip &>>${log_file}
        status_check $?

}

schema_setup() {
  if [ "${schema_type}" == "mongodb" ]; then
    print_head "Copying Mongodb repo file"
    cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
    status_check $?

    print_head "Installing mongo client"
    yum install mongodb-org-shell -y &>>${log_file}
    status_check $?

    print_head "Loading Schema"
    mongo --host mongodb-dev.rohandevops.online </app/schema/${component}.js &>>${log_file}
    status_check $?

  elif [ "${schema_type}" == "mysql" ]; then
        print_head "Install MySQL Client"
            yum install mysql -y &>>${log_file}
            status_check $?

            print_head "Load Schema"
            mysql -h mysql-dev.devopsb71.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>${log_file}
            status_check $?
  fi
}

systemD_setup() {

    print_head "Copying SystemD Service file"
    cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
    status_check $?

    sed -i -e "s/ROBOSHOP_USER_PASSWORD/${roboshop_app_password}/" /etc/systemd/system/${component}.service &>>${log_file}

    print_head "Reload SystemD"
    systemctl daemon-reload &>>${log_file}
    status_check $?

    print_head "Enabling ${component}"
    systemctl enable ${component} &>>${log_file}
    status_check $?

    print_head "Starting ${component}"
    systemctl start ${component} &>>${log_file}
    status_check $?

}

NODEJS() {
  print_head " Configure NodeJS Repo"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
  status_check $?

  print_head "Installing nodejs"
  yum install nodejs -y &>>${log_file}
  status_check $?

  app_prereq_setup

  print_head "Installing Nodejs dependencies"
  npm install &>>${log_file}
  status_check $?

#Accessing the function
  schema_setup

 #Accessing the function
  systemD_setup

  }

  java() {

    print_head "Installing Maven"
    yum install maven -y &>>${log_file}
    status_check $?
# Accessing the function below
    app_prereq_setup

    print_head "Download dependencies and Packages"
    mvn clean package &>>${log_file}
    mv target/${component}-1.0.jar ${component}.jar &>>${log_file}
    status_check $?

# Schema Setup function
    schema_setup

# SystemD Setup function
    systemD_setup

    }

  python() {

    print_head "Installing Python"
    yum install python36 gcc python3-devel -y &>>${log_file}
    status_check $?

# Accessing the function below
    app_prereq_setup

    print_head "Download dependencies"
    pip3.6 install -r requirements.txt
    status_check $?

# SystemD Setup function
    systemD_setup

    }


