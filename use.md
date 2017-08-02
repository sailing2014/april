## Using of  April

### Git Clone April

1. git clone git@git.dev.qiwo.co:misc/april.git
1. git clone "your project"

### Add Scripts to Your Project
 
1. cp  -fr april/scripts  "your project" ( **if you does't need to install mysqld ,you can copy  scripts to "your project "** )
1. cd "your project"
1. git add *
1. git commmit -m "add directory script"
1. git push origin

### Execute Scripts

1. cd "your project"
1. sudo sh scripts/install.sh action env -q ( **we need three params,action: could be install update uninstall restore , env: one directory of "your project"/config**  )