source Common.sh

print_head "Installing Repo files"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${log_file}
status_check $?

print_head "Enable redis 6.2"
yum module enable redis:remi-6.2 -y &>>${log_file}
status_check $?

print_head "Installing redis"
yum install redis -y &>>${log_file}
status_check $?


print_head "Updating listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${log_file}
status_check $?

print_head "Enabling Redis"
systemctl enable redis &>>${log_file}
status_check $?

print_head "Starting Redis"
systemctl start redis &>>${log_file}
status_check $?

