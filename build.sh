#!/bin/sh
# Created at: 2015-04-03 08:38:00
#-------------------------------------------------------------

# Description
#-------------------------------------------------------------
# Build a tiny application skeleton
#
# 1. Create a program user in the user's home the skeleton will be built.
# 2. Create directory in the program user home.
# 3. Copy source code to src
#

APR_PATH="$(dirname `readlink -e $0`)"
APR_TYPE=" `find $APR_PATH/config/developing -mindepth 1 -maxdepth 1 -type d -exec basename '{}' \; | grep -v mysqld`  "

function usage() {
    echo -e "\nUsage:"
    echo -e "\t`basename $0` <username> <userid> <type>\n"
    echo -e "Parameters:"
    echo -e "\tusername:    user name of application"
    echo -e "\tuserid:      user id of application"
    echo -e "\ttype:        { "$APR_TYPE" }\n"
}

# Include function.sh
#-------------------------------------------------------------
source "`dirname $0`/scripts/function.sh" || { echo; echo 'Error: required function.sh!'; echo; exit 1; }

# Validattion
#-------------------------------------------------------------
if ! validate_os 'CentOS-6.x'; then
    echo -e '\nOnly for CentOS 6.x .'
    echo -e "But this system is `cat /etc/system-release || unknown`.\n"
    exit 1
fi

[ $# -ne 3 ] && { usage; exit 1; }

UNAME="$1"
USERID="$2"
TYPE="$3"

[ -d $APR_PATH/config/developing/$TYPE -a $APR_PATH/web/$TYPE ] || { errmsg "Error: cannot support type [$TYPE]"; usage; exit 1; }

[ 'root' != "$USER" ] && { errmsg 'Try sudo!'; exit 1; }

# Create app user
#-------------------------------------------------------------
pdate
if pask "Create new user [$UNAME] with id [$USERID]"; then
    create_user $UNAME $USERID || { errmsg "Error: create user [$UNAME] failed!"; exit 1; }
    id $UNAME
    echo OK.
else
    ID="`id -u $UNAME 2>/dev/null`" || { errmsg "Error: the user '$UNAME' does not exist!"; exit 1; }
    [ "$ID" = "$USERID" ] || { errmsg "Error: userid.input($USERID) != userid.exist($ID) !"; exit 1; }
fi

# Deploy app source code
#-------------------------------------------------------------
pdate
SRC_PATH="/home/$UNAME/src/Release"
echo "Build app skeleton to app user [$SRC_PATH] ..."
sudo -u $UNAME mkdir -p $SRC_PATH || { errmsg 'Error: build app skeleton failed!'; exit 1; }
mkdir -p $SRC_PATH/{config/developing,config/product,config/staging,web}
cp -r $APR_PATH/{scripts,.gitignore,ReadMe} $SRC_PATH
# copy etc
cp -r $APR_PATH/config/developing/$TYPE/* $SRC_PATH/config/developing
cp -r $APR_PATH/config/product/$TYPE/* $SRC_PATH/config/product
cp -r $APR_PATH/config/staging/$TYPE/* $SRC_PATH/config/staging

find $APR_PATH/config -maxdepth 1 -type f -exec cp '{}' $SRC_PATH/config \;
# copy web
cp -r $APR_PATH/web/$TYPE/* $SRC_PATH/web/
find $APR_PATH/web -maxdepth 1 -type f -exec cp '{}' $SRC_PATH/web \;

##mysql configuration
if pask "install mysqld ?"; then
      cp -r $APR_PATH/config/developing/mysqld $SRC_PATH/config/developing
      cp -r $APR_PATH/config/product/mysqld $SRC_PATH/config/product
      cp -r $APR_PATH/config/staging/mysqld $SRC_PATH/config/staging
      if pask "mysql is master-slave or no ? if you don't know,please ask system administrator" ;then
      	 sed -i -e "s/%MASTER_SLAVE%/Yes/g" $SRC_PATH/config/developing/mysqld/master_slave.conf 
         sed -i -e "s/%MASTER_SLAVE%/Yes/g" $SRC_PATH/config/product/mysqld/master_slave.conf
         sed -i -e "s/%MASTER_SLAVE%/Yes/g" $SRC_PATH/config/staging/mysqld/master_slave.conf
         getvariable "input developingment mysql master's ip address"
         MASTER=$variable
         getvariable "input developingment mysql slaver's ip address"
         SLAVE=$variable
         if [ X$MASTER == X$SLAVE ]
         then 
             errmsg "That Master's ip address can't be same with SLave"
             exit 1
         fi
         sed -i -e "s/%MASTER%/$MASTER/g" $SRC_PATH/config/developing/mysqld/*
         sed -i -e "s/%SLAVE%/$SLAVE/g" $SRC_PATH/config/developing/mysqld/*
         getvariable "input staging mysql master's ip address"
         MASTER=$variable
         getvariable "input staging mysql slaver's ip address"
         SLAVE=$variable
         if [ X$MASTER == X$SLAVE ]
         then 
             errmsg "That Master's ip address can't be same with SLave"
             exit 1
         fi
         sed -i -e "s/%MASTER%/$MASTER/g" $SRC_PATH/config/staging/mysqld/*
         sed -i -e "s/%SLAVE%/$SLAVE/g" $SRC_PATH/config/staging/mysqld/*
         getvariable "input product mysql master's ip address"
         MASTER=$variable
         getvariable "input product mysql slaver's ip address"
         SLAVE=$variable
         if [ X$MASTER == X$SLAVE ]
         then
             errmsg "That Master's ip address can't be same with SLave"
             exit 1
         fi
         sed -i -e "s/%MASTER%/$MASTER/g" $SRC_PATH/config/product/mysqld/*
         sed -i -e "s/%SLAVE%/$SLAVE/g" $SRC_PATH/config/product/mysqld/* 
      fi
fi

# change owner and group
chown -R $UNAME:program $SRC_PATH

# replace %APP_NAME%, %APP_ID%, %APP_PATH%, %APP_PORT%, %APP_TYPE% in config files
APP_PORT=$((USERID * 10))
MYSQL_PORT=$((USERID*10+1))
README=$SRC_PATH/ReadMe

for CONF in $(find $SRC_PATH/config/ -type f)
do
    sed -i -e "s/%APP_NAME%/$UNAME/g"           $CONF $README
    sed -i -e "s/%APP_ID%/$USERID/g"            $CONF $README
    sed -i -e "s/%APP_PATH%/\/home\/$UNAME/g"   $CONF $README
    sed -i -e "s/%APP_PORT%/$APP_PORT/g"        $CONF $README
    sed -i -e "s/%APP_TYPE%/$TYPE/g"            $CONF $README
    sed -i -e "s/%MYSQL_PORT%/$MYSQL_PORT/g"    $CONF $README
done

# modify pm2 port
if [ -f $SRC_PATH/web/main.js ]
then
    sed -i -e "s/%APP_PORT%/$APP_PORT/g" $SRC_PATH/web/main.js
fi



echo OK.

# Install pm2 and build pm2 per-user auto-startup service script
#-------------------------------------------------------------
if [ "$TYPE" = 'pm2' ]; then
    pdate
    echo 'Install pm2 & build pm2 app ...'
    install_pm2 || { errmsg 'Error: install pm2 failed!'; exit 1; }
    build_pm2app_service $UNAME $SRC_PATH || { errmsg 'Error: build pm2 app failed!'; exit 1; }
    echo OK.
fi

which tree || yum install -y tree 
# Output summary
#-------------------------------------------------------------
pdate
echo -e '\e[92mSuccessfully!\e[0m'
echo -e "The source code are placed in [\e[92m$SRC_PATH\e[0m]."
echo
tree -aCF --dirsfirst /home/$UNAME/
echo
echo    "Further:"
echo -e "    1. Use [sudo sh \e[92m$SRC_PATH/scripts/install.sh\e[0m] to install environment."
echo -e "    2. Add [\e[92m$SRC_PATH\e[0m] into git repository."
echo

#{+----------------------------------------- Embira Footer 1.7 -------+
# | vim<600:set et sw=4 ts=4 sts=4:                                   |
# | vim600:set et sw=4 ts=4 sts=4 ff=unix cindent fdm=indent fdn=1:   |
# +-------------------------------------------------------------------+}
