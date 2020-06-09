#!/bin/bash
#Make uncompil apk easier
#@DeedWark

#check ROOT
if [ $UID -ne 0 ] ; then
	echo "You must launch it with sudo!"
	exit 1
fi

#var
os=$(grep -Ei "^ID=" /etc/os-release |cut -d '=' -f2)
apktool="https://raw.githubusercontent.com/iBotPeaches/ApkTool/master/scripts/linux/apktool"
apktool2="https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar"

echo -e "Setup...\n"

#check OS and package
case $os in
	[Dd]ebi* | [Uu]bun* | [Ll]inux[Mm]int* | [Kk]ali* ) pkg="apt-get install" ; java="default-jre" ; no="-y" ; c_curl=$(dpkg -s curl 2>/dev/null) ; c_jre=$(dpkg -s default-jre 2>/dev/null);;
	[Aa]rch* ) pkg="pacman -S" ; no="--noconfirm" ; java="jre-openjdk" ; c_curl=$(pacman -Qs curl 2>/dev/null) ; c_jre=$(pacman -Qs jre-openjdk 2>/dev/null);;
	[Cc]ent* | [Ff]edo* | [Oo]l* | [Rr]ed[*Hh]* ) pkg="yum install" ; java="java-11-openjdk" ; no="-y" ; c_curl=$(yum list installed curl) ; c_jre=$(yum list installed java-11-openjdk);;
	[Oo]pen[sS]* ) pkg="zypper install" ; no="-y" ; java="java-11-openjdk" ; c_curl=$(zypper se curl |grep -i "wget" 2>/dev/null) ; c_jre=$(zypper se java-11-openjdk |grep -i "java-11-openjdk" 2>/dev/null);;
esac

#check curl package
if [ -z "$c_curl" ] ; then
	echo 'curl is missing!'
	read -r -p 'Do you want to install curl? [Y/N] ' icurl
	case $icurl in
		[yYoO]* ) echo -e "Installing curl | Please wait!" ; $pkg $no curl 1>/dev/null && echo -e "curl is now installed!\n";;
		[nN]* ) echo "Try to install wget with '${pkg} curl'" ; exit 1;;
	esac
fi
#sleep 1
#check java package
if [ -z "$c_jre" ] ; then
	echo 'Java package is missing!'
	read -r -p 'Do you want to install JAVA? [Y/N] ' ijre
	case $ijre in
		[YyOo]* ) echo -e "Installing default-jre | Please wait! (This could take a minute)" ; $pkg $no $java 1>/dev/null && echo -e "$java is now installed!\n";;
		[Nn]* ) echo "Try to install default-jre with '${pkg} ${java}'" ; exit 1;;
	esac
fi
#check & curl apktool jar && +x
checkfile="/usr/local/bin/apktool"
if [[ -f "$checkfile" ]]; then
	echo -e "apktool is already installed. Perfect!\n"
else
	mkdir ".apktool" 2>/dev/null && cd ".apktool" 2>/dev/null
	curl -o apktool $apktool 1>/dev/null && chmod +x "apktool" && mv "apktool" "/usr/local/bin/"
	echo -e "Downloading apktool.jar ..." && curl -o apktool.jar $apktool2 1>/dev/null && chmod +x "apktool.jar" && mv "apktool.jar" "/usr/local/bin/"
	cd ".." && rm -rf ".apktool"
fi

function help () {
	echo -ne "\nThis script will simplify your life by execute automaticaly
	          a tool for reverse engineering Android APK files.
		  To use it: ./script app.apk\n"
	  }
[[ $1 == "--help" || $1 == "-h" || $1 == "help" || -z $1 ]] && help && exit 0

echo -e "Disassembling in progress..."
apktool d "$1"
dir=$(echo -e "${1}" |cut -d '.' -f1)
echo -e "Disassembling is complete in $dir folder"
###################################################
