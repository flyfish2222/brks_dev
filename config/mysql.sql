create database dongnaobike;

use mysql;
update user set host = '.' where user = 'root';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
flush privileges;