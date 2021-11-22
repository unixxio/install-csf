# Install CSF
**Last Update**: November 22, 2021

This installer should work on any Debian based OS. This also includes Ubuntu. If it detects that CSF is already installed, it will abort installation.

**Install CURL first**
```
apt-get install curl -y
```

### Run the installer with the following command
```
bash <( curl -sSL https://raw.githubusercontent.com/unixxio/install-csf/main/install-csf.sh )
```

**Requirements**
* Execute as root

**What does it do**
* Install the latest CSF version from source
* Automatically whitelist your ip-address
* Automatically whitelist your ip-range

**Default allowed (open) ports**
* 20 (FTP data)
* 21 (FTP)
* 80 (HTTP)
* 443 (HTTPS)
* 35000:35999 (FTP Passive)

**Important Locations**
* /etc/csf/csf.conf (General configuration)
* /etc/csf/csf.allow (Whitelist)
* /etc/csf/csf.deny (Blacklist)

**CSF Commands**

CSF status
```
systemctl status csf
```
LFD status
```
systemctl status lfd
```
Stop CSF
```
systemctl stop csf
```
Stop LFD
```
systemctl stop lfd
```
Start CSF
```
systemctl start csf
```
Start LFD
```
systemctl start lfd
```
Reload CSF (after making changes to configuration)
```
csf -r
```
Disable CSF
```
csf -x
```
Enable CSF
```
csf -e
```
Allow IP-address (whitelist)
```
csf -a 123.123.123.123 Short description here
```
Deny IP-address (blacklist)
```
csf -d 123.123.123.123 Short description here
```
Check CSF version
```
csf -v
```

**Tested on**
* Debian 10 Buster
* Debian 11 Bullseye

## Support
Feel free to [buy me a beer](https://paypal.me/sonnymeijer)! ;-)

## DISCLAIMER
Use at your own risk and always make sure you have backups! Make sure you check your IP-address is added to the whitelist because SSH (port 22) is only accessible from allowed (whitelisted) IP's.
