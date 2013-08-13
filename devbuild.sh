# vim:fdm=marker:
#! /bin/bash
#
#      _            _           _ _     _       _
#   __| | _____   _| |__  _   _(_) | __| |  ___| |__
#  / _` |/ _ \ \ / / '_ \| | | | | |/ _` | / __| '_ \
# | (_| |  __/\ V /| |_) | |_| | | | (_| |_\__ \ | | |
#  \__,_|\___| \_/ |_.__/ \__,_|_|_|\__,_(_)___/_| |_|
#

# PRE BUILD {{{
###################################################################

# VARIABLES # {{{
###################################################################

BLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YLW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)


# }}}
# FUNCTIONS # {{{
###################################################################

function update_hosts {
DEV_HOST=`uname -n`
IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
cat <<- _EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

$IP         $DEV_HOST
_EOF_
}


function update_sshd_config {
cat <<- _EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

ClientAliveInterval 120
_EOF_
}



# }}}



# }}}
# DEV BUILD {{{
###################################################################

# Get Input
clear
echo
read -p "Enter hostname: " newhostname



# Update System
aptitude update
aptitude full-upgrade -y
echo -e "\n${BLD}${RED} Update System ${BLD}${GREEN}| Done!${RESET}\n"



# Install Packages
aptitude install -y \
	build-essential git-core zip zsh safe-rm trash-cli \
	python-software-properties python g++ make golang \
	ruby-full rubygems1.8

	gem install sass
	gem install compass

add-apt-repository -y ppa:chris-lea/node.js
aptitude update
aptitude install -y nodejs
npm install -g express nodemon jshint bower
echo -e "\n${BLD}${RED} Install Packages ${BLD}${GREEN}| Done!${RESET}\n"



# Update Hostname
echo $newhostname > /etc/hostname
hostname -F /etc/hostname
echo -e "\n${BLD}${RED} Update Hostname ${BLD}${GREEN}| Done!${RESET}\n"



# Configure SSH
/bin/cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
/bin/cp -f /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
update_sshd_config >> /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo -e "\n${BLD}${RED} Configure SSH ${BLD}${GREEN}| Done!${RESET}\n"



# Configure DNS
/bin/cp -n /etc/hosts /etc/hosts.bak
/bin/cp -f /etc/hosts.bak /etc/hosts
update_hosts >> /etc/hosts
DEV_HOST=`uname -n`
echo -e "\n${BLD}${RED} Configure DNS ${BLD}${GREEN}| Done!${RESET}\n"



# Configure srv dir
chgrp www-data /srv
chmod -R 775 /srv



# }}}
# POST BUILD # {{{
###################################################################

# Create Additional Account
echo -n -e "\Create a user account? [y/n] "
read -N 1 ADDUSER
if test "$ADDUSER" = "y" -o "$REPLY" = "Y"; then
  if [ $(id -u) -eq 0 ]; then
    echo -e "\n"
    read -p "Enter username : " username
    echo
    read -s -p "Enter password : " password
    echo -e "\n"

    egrep "^$username" /etc/passwd >/dev/null

    if [ $? -eq 0 ]; then
        echo -e "\n$username exists!"
    else
        pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
        useradd -m -p $pass -s /bin/zsh $username
        usermod -G www-data,sudo $username

        [ $? -eq 0 ] && echo -e "\n${BLD}${RED} Create Additional Account $username ${BLD}${GREEN}| Done!${RESET}\n" || echo -e "\nFailed to add another user!"
    fi
		su -s /bin/bash $username -c 'cd ~ && curl -O https://raw.github.com/zshtopia/zshtopia/master/.aux/install.sh && chmod 770 install.sh && ./install.sh'
  else
    echo -e "\nOnly root may add a user to the system"
  fi
else
  echo -e "\n"
fi
echo -e "\n${BLD}${RED} Dev Build ${BLD}${GREEN}| Done!${RESET}\n"



# }}}
