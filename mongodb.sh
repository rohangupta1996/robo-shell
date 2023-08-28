source Common.sh


print_head "Setup mongodb repository"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?

print_head " Instaling Mongodb "
yum install mongodb-org -y &>>${log_file}
status_check $?

print_head " Updating mongodb listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
status_check $?


print_head " Enabling mongodb"
systemctl enable mongod &>>${log_file}
status_check $?

print_head "Starting mongodb"
systemctl restart mongod &>>${log_file}
status_check $?



