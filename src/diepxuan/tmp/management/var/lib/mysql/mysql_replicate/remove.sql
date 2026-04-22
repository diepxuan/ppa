STOP SLAVE;
STOP REPLICA;

flush status;
flush logs;
flush relay logs;
truncate table mysql.slave_master_info;
reset slave all;
RESET REPLICA ALL;
