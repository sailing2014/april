# PM2 Application
---

### Table of Contents

* [Architecture](#architecture)
* [SKeleton](#skeleton)
* [References](#Rreferences)


## Architecture

* Glance

    ```
                                     e.g. nginx                   NodeJS Application 
    +---------+                   +---------------+     +-------------------------------------+
    | Browser | --http-request--> | Load Balancer | --> | Process Manager --> Javascript Code |
    +---------+                   +---------------+     +-------------------------------------+
    ```

* NodeJS Application

    ```
    NodeJS Application = NodeJS Process Manager + Javascript Code
    ```

* NodeJS Process Manager

    Use [PM2] as the **per-user** production process manager.


## Skeleton

### Home tree after installing

```
    /home/username/
    |-- .pm2
    |-- bin
    |-- conf
    |   |-- crontab.conf -> /home/username/src/CURRENT/etc/crontab.conf
    |   |-- logrotate.conf -> /home/username/src/CURRENT/etc/logrotate.conf
    |   |-- pm2-app.json -> /home/username/src/CURRENT/etc/pm2-app.json
    |   `-- pm2-${username} -> /home/username/src/CURRENT/etc/pm2-${username}
    |-- data
    |-- log
    |   |-- ${username}-err-0.log
    |   `-- ${username}-out-0.log
    |-- src
    |   |-- CURRENT -> /home/username/src/dev
    |   `-- dev
    |       |-- etc
    |       |   |-- crontab.conf
    |       |   |-- logrotate.conf
    |       |   |-- pm2-app.json
    |       |   `-- pm2-${username}
    |       |-- scripts
    |       |   |-- function.sh
    |       |   `-- install.sh
    |       |-- web
    |       |   `-- main.js
    |       |-- .gitignore
    |       `-- ReadMe
    |-- tmp
    `-- web
        `-- htdocs -> /home/app_user_name/src/CURRENT/web
```

### Description

Item | File | Description
------------|------------|------------
Entry Point | web/[main.js](web/pm2/main.js) | It should be rewrite.
App Declaration | etc/[pm2-app.json](etc/pm2/pm2-app.json) | It will be used to start pm2 process by [install.sh].
App Service | etc/pm2-${username} | Created by [build.sh], and will be deployed to `/etc/init.d/pm2-${username}` by [install.sh].
Crontab | etc/[crontab.conf](etc/pm2/crontab.conf) | It will be install into app user by [install.sh].
Log Rotation | etc/[logrotate.conf] | It will be deployed to `/etc/logrotate.d/${username}` by [install.sh].


* Service Control

    ```
    sudo service pm2-${usernmae} {start|stop|restart|reload|status}
    ```
    Do more by [PM2]
    
* Check startup runlevel info:

    ```
    chkconfig --list pm2-${username}
    ```

* Log

    * Application log folder
    
        ```
        $HOME/log/
        ```
    * PM2 log folder
    
        ```
        $HOME/.pm2
        ```

    * Log files

        Log | File 
      ------|------
      App output log | $HOME/log/${usename}-out-${appid}.log
      App error  log | $HOME/log/${usename}-err-${appid}.log
      PM2 output log | $HOME/.pm2/pm2.log

    * Rotation by `logrotate` with daily rotation, 7 days keep mode  
  See [logrotate.conf]



## References

* PM2 official advanced readme: https://github.com/Unitech/PM2/blob/master/ADVANCED_README.md


[PM2]:              https://github.com/Unitech/PM2
[build.sh]:         build.sh
[install.sh]:       scripts/install.sh
[logrotate.conf]:   etc/pm2/logrotate.conf
