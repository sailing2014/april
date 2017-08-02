# April
A Tiny Application Skeleton
----
  
[April] can be used to create a tiny application skeleton supported for:

* NodeJS app with [PM2] as the **per-user** process manager
* PHP app (*coming soon*)
* Pure httpd(apache) app
* Pure nginx app (*coming soon*)

It is constructed with the following main components:

 Component | Description
 ---|---
 [build.sh] | Used to create application skeleton.
 [install.sh] | Used to deploy application into target environment. It will install crontab, auto-startup service, logrotation and so on.
 [Entry Point](#entry-point) | Entry point of the application, such as **[main.js]** for [PM2] app.
 [Service](#service) | Declaration of the application, such as **pm2-${username}** for [PM2] app.
 [Log Rotation](#log-rotation) | Log is rotated with **[logrotate.conf]** by logrotate.d .

### Table of Contents

* [Usage](#usage)
  * [Use build.sh to create a new application](#use-build-sh-to-create-a-new-application)
  * [Use install.sh to deploy application](#use-install-sh-to-deploy-application)     
  
* [App Skeleton](#app-skeleton)
  * [Entry Point](#entry-point)
  * [Service & Config](#service-amp-config)
  * [Log Rotation](#log-rotation)
  * [Crontab](#crontab)

## Usage


###  ``` Attention: ```
 
 * if you build  master or slave of mysql,you must build  master of mysql frist
 * if you don't build master frist,That would be some error happen
 * ```you should use master branch ```

Generally steps:
 

* Step 1. Initially, use [build.sh] to create a application.
* Step 2. Use [install.sh] to deploy the application destination environment.
* Step 3. Add application into VCS repository, such as gitlab.
* Step 4. Start hack, hack, hack with the [entry point](#entry-point) of application.
* Step 5. Release application and use [install.sh] to deploy to target environment.


### Use [build.sh] to create a new application

```
Usage:
        build.sh <username> <userid> <type>

Parameters:
        username:    user name of application
        userid:      user id of application
        type:        { httpd pm2 }
```
        

1. Download [April]'s latest version from https://git.x.x.co/misc/april/tags .  
   And then decompress the archive.


    ```git clone git@git.x.x.co:misc/april.git ```    
    ```cd april ```   
    ```git checkout master```
   

1. Use `sudo sh build.sh username userid type` to create a new application skeleton.
    * Output the created application skeleton, e.g. [PM2] application.
    
        ```
        /home/username/
        |-- src/
        |   `-- Release/
        |       |-- config/
        |       |   |-- developing  
        |       |      |-- crontab.conf
        |       |      |-- logrotate.conf
        |       |      |-- pm2-app.json
        |       |      `-- pm2-${username}*
        |       |      `-- my.cnf
        |       |      '-- ${username}_mysqld
        |       |   |-- product
        |       |      |-- crontab.conf
        |       |      |-- logrotate.conf
        |       |      |-- pm2-app.json
        |       |      `-- pm2-${username}*
        |       |      `-- my.cnf
        |       |      '-- ${username}_mysqld
        |       |   |-- staging
        |       |      |-- crontab.conf
        |       |      |-- logrotate.conf
        |       |      |-- pm2-app.json
        |       |      `-- pm2-${username}*
        |       |      `-- my.cnf
        |       |      '-- ${username}_mysqld
        |       |-- scripts/
        |       |   |-- function.sh
        |       |   |-- update.sh (Used for mysql,you must modify it every time & give a date to exec_time)
        |       |   `-- install.sh
        |       |-- web/
        |       |   `-- main.js
        |       |-- .gitignore
        |       `-- ReadMe
        |-- .bash_history
        |-- .bash_logout
        |-- .bash_profile
        `-- .bashrc
        ```
    
1. At last, switch to app user for developing.  
   Generally, you should add `$HOME/src/Realse` into git repository.

    ```
    sudo su - username
    ssh-keygen  # and then, add public key to git.dev.qiwo.co
    cd ~/src/Realse
    git init
    git commit -m "Init the project"
    git remote add origin git@git.x.x.co:group/app.git
    git push -u origin master
    git branch developing
    git branch staging
    git push origin developing
    git push origin staging
    git checkout developing
    ```
    **If You Use Nginx & Php-fpm ,You Should Seee [php-fpm](phpfpm.md)**
    
    Now, you can start wonderful performance with [main.js] .

### Use [install.sh] to deploy application


```
Usage:
        install.sh [action env [-q]]
        
Parameters:
        action:  { install | update | uninstall  | restore } 
        env: { developing | product | staging }
        -q:      quiet mode, no interation.
```

* Use `sudo sh /home/username/src/CURRENT/scripts/install.sh` to deploy applcaiotn target environment
    * The followings will be installed:
      * Link `etc/${environment}/*` to `$HOME/conf`.
      * Install crontab to app user by `$HOME/conf/crontab.conf` if it exists.
      * Install logrotate config `$HOME/conf/logrotate.conf` to `/etc/logrotate.d/` if it exists.
      * Install httpd config `$HOME/conf/httpd.conf` to `/etc/httpd/conf.d/httpd_${username}.conf` if it exists.
      * Install NodeJS, npm, pm2 if [PM2] app declaration `$HOME/conf/pm2-app.json` exists. (See more: [pm2-app.md](doc/pm2-app.md))
      * $environment can be developing or product or staging

    * Output after perform **install** action, e.g. [PM2] application:

        ```
        uid=userid(username) gid=1001(program) groups=1001(program)
        
        /home/username/
        |-- .pm2
        |-- bin
        |   `-- update.sh ->/home/username/src/CURRENT/scripts/update.sh
        |-- conf
        |   |-- crontab.conf -> /home/username/src/CURRENT/config/$environment/crontab.conf
        |   |-- logrotate.conf -> /home/username/src/CURRENT/config/$environment/logrotate.conf
        |   |-- pm2-app.json -> /home/username/src/CURRENT/config/$environment/pm2-app.json
        |   `-- pm2-${username} -> /home/username/src/CURRENT/config/$environment/pm2-${username}
        |   `-- my.cnf -> /home/username/src/CURRENT/config/$environment/my.cnf
        |-- data
        |-- log
        |   |-- ${username}-err-0.log
        |   `-- ${username}-out-0.log
        |-- src
        |   |-- CURRENT -> /home/username/src/Release_$(date +%y%m%d%k%M%S)/
        |   `-- Release_$(date +%y%m%d%k%M%S)/
        |       |-- config 
        |       |   |-- developing  
        |       |      |-- crontab.conf
        |       |      |-- logrotate.conf
        |       |      |-- pm2-app.json
        |       |      `-- pm2-${username}*
        |       |      `-- my.cnf
        |       |      '-- ${username}_mysqld
        |       |   |-- product
        |       |      |-- crontab.conf
        |       |      |-- logrotate.conf
        |       |      |-- pm2-app.json
        |       |      `-- pm2-${username}*
        |       |      `-- my.cnf
        |       |      '-- ${username}_mysqld
        |       |   |-- staging
        |       |      |-- crontab.conf
        |       |      |-- logrotate.conf
        |       |      |-- pm2-app.json
        |       |      `-- pm2-${username}*
        |       |      `-- my.cnf
        |       |      '-- ${username}_mysqld
        |       |-- scripts/
        |       |   |-- function.sh
        |       |   `-- install.sh
        |       |   |-- update.sh (Used for mysql,you must modify it every time & give a date to exec_time)
        |       |-- web/
        |       |   `-- main.js
        |       |-- .gitignore
        |       `-- ReadMe
        |-- tmp
        `-- web
            `-- htdocs -> /home/username/src/CURRENT/web
        
        ...
        ```
* Use `sudo sh install.sh update  { developing | product | staging } [-q]` to update a installed application.

* Use `sudo sh install.sh uninstall { developing | product | staging } [-q]` to uninstall a application.


## App Skeleton

### Entry Point

  App Type | Entry Point
  ---------|---------
  [PM2] App with NodeJS | web/[main.js]
  PHP App   | web/[index.html]
  httpd App | web/[index.html]
  nginx App | web/[index.html]
  nginx rtmp app | web/[index.html]
  nginx php 5.4 | web/[/index.php]

### Service & Config

  App Type | App Location | System Location
  ---------|---------|---------
  [PM2] App with NodeJS | $HOME/conf/pm2-${username} | /etc/init.d/pm2-${username}
  PHP App   | $HOME/conf/httpd.conf | /etc/httpd/conf.d/httpd_${username}.conf
  httpd App | $HOME/conf/httpd.conf | /etc/httpd/conf.d/httpd_${username}.conf
  nginx App | $HOME/conf/nginx.conf | /etc/nginx/conf.d/nginx_${username}.conf
  mysql app |$HOME/data/mysql | $HOME/conf/mysqld/my.cnf
  nginx rtmp app | $HOME/conf/nginxrtmp.conf |  /etc/nginx/conf.d/nginxrtmp.${username}.conf 
  nginx php 5.4  | $HOME/conf/nginxphp54.conf | /etc/nginx/conf.d/nginxphp54.${username}.conf

### Log Rotation

Log rotation by `logrotate` with **daily rotation, 7 days keep** mode.

  App Type | Log Path | Rotation
  ---------|---------|---------
  [PM2] App with NodeJS | $HOME/log, $HOME/.pm2 | etc/pm2/[logrotate.conf](etc/pm2/logrotate.conf)
  PHP App   | $HOME/log | etc/php/[logrotate.conf](etc/php/logrotate.conf)
  httpd App | $HOME/log | etc/httpd/[logrotate.conf](etc/httpd/logrotate.conf)
  nginx App | $HOME/log | etc/nginx/[logrotate.conf](etc/nginx/logrotate.conf)

### Crontab

By default, the crontab config file will be generated to `etc/crontab.conf`. Crontab task can be added to it.  
The [install.sh] will link it to `$HOME/conf/crontab.conf`, and install it into the app user's crontab.


[April]:            https://git.x.x.co/misc/april
[PM2]:              https://github.com/Unitech/PM2
[build.sh]:         build.sh
[install.sh]:       scripts/install.sh
[pm2-app.json]:     etc/pm2/pm2-app.json
[main.js]:          web/pm2/main.js
[index.html]:       web/httpd/index.html

       
      
       
      
