source Common.sh
mysql_root_password=$1
if [ -z "${mysql_root_password}" ]; then
  echo "Missing mysql root password"
  exit 1
fi

component = shipping
schema_type="mysql"
java

# jab execute karte hai --   bash mysql.sh rohan123   --matlb argument $1 ki value rohan123 hai