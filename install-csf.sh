#!/bin/bash

#####################################################
#                                                   #
#  Description : Install CSF from source            #
#  Author      : Unixx.io                           #
#  E-mail      : github@unixx.io                    #
#  GitHub      : https://www.github.com/unixxio     #
#  Last Update : November 22, 2021                  #
#                                                   #
#####################################################
clear

# Variables
distro="$(lsb_release -sd | awk '{print tolower ($1)}')"
release="$(lsb_release -sc)"
version="$(lsb_release -sr)"
kernel="$(uname -r)"
uptime="$(uptime -p | cut -d " " -f2-)"
my_username="$(whoami)"
user_ip="$(who am i --ips | awk '{print $5}' | sed 's/[()]//g')"
user_hostname="$(host ${user_ip} | awk '{print $5}' | sed 's/.$//')"
network_range="$(hostname -I | rev | cut -d. -f2-4 | rev).0/24"

packages="libwww-perl liblwp-protocol-https-perl libgd-graph-perl iptables"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Show the current logged in user
echo -e "\nHello ${my_username}, you are logged in from ${user_ip} (${user_hostname}).\n"

# Show system information
echo -e "Distribution : ${distro}"
echo -e "Release      : ${release}"
echo -e "Version      : ${version}"
echo -e "Kernel       : ${kernel}"
echo -e "Uptime       : ${uptime}"

if [[ ! -d /etc/csf ]]; then
    # Script feedback
    echo -e "\nInstalling CSF. Please wait...\n"

    # Install required packages on APT based systems (Debian/Ubuntu)
    apt-get install ${packages} -y > /dev/null 2>&1

    # Stop and disable firewall on Ubuntu (if running)
    systemctl stop ufw > /dev/null 2>&1
    systemctl disable ufw > /dev/null 2>&1

    # Download and install csf
    rm -fv /usr/src/csf.tgz > /dev/null 2>&1
    wget -q https://download.configserver.com/csf.tgz -O /usr/src/csf.tgz > /dev/null 2>&1
    tar -xzf /usr/src/csf.tgz -C /usr/src/ > /dev/null 2>&1
    rm -fv /usr/src/csf.tgz > /dev/null 2>&1
    cd /usr/src/csf && sh /usr/src/csf/install.sh > /dev/null 2>&1

    # Remove comments and empty lines from config to increase readability
    sed -i '/^#/d' /etc/csf/csf.conf
    sed -i '/^$/d' /etc/csf/csf.conf

    # Replace configs
    sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
    sed -i 's/IGNORE_ALLOW = "0"/IGNORE_ALLOW = "1"/g' /etc/csf/csf.conf
    sed -i 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995"/TCP_IN = "20,21,80,443,35000:35999"/g' /etc/csf/csf.conf
    sed -i 's/TCP6_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995"/TCP6_IN = "20,21,80,443,35000:35999"/g' /etc/csf/csf.conf
    sed -i 's/TCP_OUT = "20,21,22,25,53,80,110,113,443,587,993,995"/TCP_OUT = "1:65535"/g' /etc/csf/csf.conf
    sed -i 's/TCP6_OUT = "20,21,22,25,53,80,110,113,443,587,993,995"/TCP6_OUT = "1:65535"/g' /etc/csf/csf.conf

    # Add ip-address of network range to csf.allow
    if [[ ! $(cat /etc/csf/csf.allow | grep "${network_range}") ]]; then
      echo "${network_range} # automatically added" >> /etc/csf/csf.allow
    fi

    # Add ip-address and hostname from logged in user to csf.allow
    if [[ ! $(cat /etc/csf/csf.allow | grep "${user_ip}") ]]; then
      echo "${user_ip} # ${user_hostname}" >> /etc/csf/csf.allow
    fi

    # Start services
    systemctl start csf
    systemctl start lfd

    # Enable services
    systemctl enable csf
    systemctl enable lfd
else
    echo -e "\nCSF is already installed. Nothing to do here :-)\n"
    exit 1
fi

# Finish install
echo -e "CSF is now installed. Enjoy! ;-)\n"
exit 0
