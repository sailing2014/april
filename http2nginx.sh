#!/bin/bash
# Create nginx config

UNAME="$1"
USERID="$2"

function usage() {
    echo -e "\nUsage:"
    echo -e "\t`basename $0` <username> <userid>\n"
    echo -e "Parameters:"
    echo -e "\tusername:    user name of application"
    echo -e "\tuserid:      user id of application"
}

# Include function.sh
#-------------------------------------------------------------
source "`dirname $0`/scripts/function.sh" || { echo; echo 'Error: required function.sh!'; echo; exit 1; }

[ $# -ne 2 ] && { usage; exit 1; }

APP_PORT=$((USERID * 10))

if [ -d "$UNAME" ]; then
    echo "You have make it already! Delete the $UNAME Directory and run again, pls."
    exit 1
else
    mkdir $UNAME
fi
/bin/cp -ar ./config/developing/nginx_php/*.conf ./${UNAME}/
for CONF in $(find ${UNAME}/ -type f)
do
    sed -i -e "s/%APP_NAME%/$UNAME/g"           $CONF
    sed -i -e "s/%APP_ID%/$USERID/g"            $CONF
    sed -i -e "s/%APP_PATH%/\/home\/${UNAME}/g"   $CONF
    sed -i -e "s/%APP_PORT%/$APP_PORT/g"        $CONF
done

echo "Check ./$UNAME pls. If it is OK, then copy to you project's config/{developing,product,product}/ directory"
ls -R ./$UNAME
