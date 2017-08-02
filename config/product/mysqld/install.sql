GRANT SELECT, EVENT ON *.* TO 'backup'@'localhost' identified by 'backup_123';
GRANT SELECT ON *.* TO 'monitor'@'127.0.0.1' IDENTIFIED BY 'Mo@32919#';
delete from mysql.user where User='';
flush privileges;
