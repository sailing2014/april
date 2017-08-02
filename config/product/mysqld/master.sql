GRANT REPLICATION CLIENT ON *.* To 'slave_install'@'%SLAVE%' IDENTIFIED BY 'Qwo#@%#%#';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%SLAVE%' IDENTIFIED BY 'Qiwo@Rcp3129';
flush privileges;
