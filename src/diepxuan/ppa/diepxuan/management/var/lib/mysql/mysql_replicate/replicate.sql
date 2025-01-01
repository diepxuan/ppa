UNINSTALL COMPONENT "file://component_validate_password";
UNINSTALL PLUGIN validate_password;

CREATE USER IF NOT EXISTS 'slave' IDENTIFIED WITH mysql_native_password BY 'ductn@123';
CREATE USER IF NOT EXISTS 'sa' IDENTIFIED WITH mysql_native_password BY 'ductn@123';
CREATE USER IF NOT EXISTS 'sa' IDENTIFIED BY 'ductn@123';
GRANT REPLICATION SLAVE ON *.* TO 'slave';
GRANT ALL PRIVILEGES ON * . * TO 'sa';

GRANT ALL PRIVILEGES ON *.* TO 'sa' IDENTIFIED BY 'ductn@123' WITH GRANT OPTION;

-- INSTALL COMPONENT "file://component_validate_password";
INSTALL PLUGIN validate_password SONAME 'validate_password.so';
-- SET GLOBAL validate_password.policy=MEDIUM;
SET GLOBAL validate_password.policy=LOW;
FLUSH PRIVILEGES;

STOP SLAVE;
STOP REPLICA;

flush status;
flush logs;
flush relay logs;
truncate table mysql.slave_master_info;
reset slave all;
RESET REPLICA ALL;

CHANGE MASTER TO MASTER_HOST='dx1.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123';
CHANGE MASTER TO MASTER_HOST='dx2.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123';
CHANGE MASTER TO MASTER_HOST='dx3.diepxuan.com', MASTER_USER='slave', MASTER_PASSWORD='ductn@123';

reset slave;
START SLAVE;
SHOW SLAVE STATUS;

