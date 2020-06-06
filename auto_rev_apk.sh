#!/bin/bash
#Make uncompil apk easier
#@DeedWark

if [ $UID -ne 0 ] ; then
	echo "You must launch it with sudo!"
	exit 1
fi

apktool="https://raw.githubusercontent.com/iBotPeaches/ApkTool/master/scripts/linux/apktool"
apktool2="https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar"
c_wget=$(dpkg -s wget 2>/dev/null)
c_jre=$(dpkg -s default-jre 2>/dev/null)

echo -e "Setup...\n"

#check wget package
if [ -z "$c_wget" ] ; then
	echo 'wget is missing!'
	read -r -p 'Do you want to install wget? [Y/N]' iwget
	case $iwget in
		[yYoO]* ) echo -e "Installing wget | Please wait!" ; apt-get install -y wget 1>/dev/null;;
		[nN]* ) echo "Try to install wget with 'apt-get install wget'" ; exit 1;; #do an uto detect package-manager
	esac
fi
sleep 1
#check default-jre package
if [ -z "$c_jre" ] ; then
	echo 'JRE/Java package is missing!'
	read -r -p 'Do you want to install default-jre? [Y/N]' ijre
	case $ijre in
		[YyOo]* ) echo -e "Installing default-jre | Please wait! (This could take a minute)" ; apt-get install -y default-jre 1>/dev/null;;
		[Nn]* ) echo "Try to install default-jre with 'apt-get install default-jre'" ; exit 1;;
	esac
fi
#check & wget apktool jar && +x
checkfile="/usr/local/bin/apktool"
if [[ -f "$checkfile" ]]; then
	echo -e "apktool is already installed. Perfect!\n"
else
	mkdir ".apktool" 2>/dev/null && cd ".apktool" 2>/dev/null
	wget -nv --show-progress --no-hsts -q $apktool && chmod +x "apktool" && mv "apktool" "/usr/local/bin/"
	wget -nv --show-progress --no-hsts -q $apktool2 && mv "apktool_2.4.1.jar" "apktool.jar" && chmod +x "apktool.jar" && mv "apktool.jar" "/usr/local/bin/"
	cd ".." && rm -rf ".apktool"
fi

function help () {
	echo -ne "This script will simplify your life by execute automaticaly
	          a tool for reverse engineering Android APK files.
		  To use it: ./script app.apk"
	  }
[[ $1 == "--help" || $1 == "-h" || $1 == "help" || -z $1 ]] && help && exit 0

echo -e "Disassembling in progress..."
apktool d "$1"
dir=$(echo -e "${1}" |cut -d '.' -f1)
echo -e "Disassembling is complete in $dir folder"
