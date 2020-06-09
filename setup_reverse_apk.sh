#!/bin/bash
#Make disassembling apk easier
#@DeedWark

#check ROOT
if [ $UID -ne 0 ] ; then
	echo "You must launch it with ROOT!"
	exit 1
fi

#var
apktool2="https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar"
pkg="apt-get install"
no="-y"
java="default-jre"
c_curl=$(dpkg -s curl 2>/dev/null)
c_jre=$(dpkg -s default-jre 2>/dev/null)

echo -e "APK Disassembler"

#check curl package
if [ -z "$c_curl" ] ; then
	echo 'curl is missing!'
	read -r -p 'Do you want to install curl? [Y/N] ' icurl
	case $icurl in
		[yYoO]* ) echo -e "Installing curl | Please wait!" ; $pkg $no curl 1>/dev/null && echo -e "curl is now installed!\n";;
		[nN]* ) echo "Try to install wget with '${pkg} curl'" ; exit 1;;
	esac
fi
#check java package
if [ -z "$c_jre" ] ; then
	echo 'Java package is missing!'
	read -r -p 'Do you want to install Java? [Y/N] ' ijre
	case $ijre in
		[YyOo]* ) echo -e "Installing default-jre | Please wait! (This could take a minute)" ; $pkg $no $java 1>/dev/null && echo -e "Java is now installed!\n";;
		[Nn]* ) echo "Try to install default-jre with '${pkg} ${java}'" ; exit 1;;
	esac
fi
#check & curl apktool jar && +x
checkfile="/usr/local/bin/apktool"
if [[ ! -f "$checkfile" ]]; then
	mkdir ".apktool" 2>/dev/null && cd ".apktool" 2>/dev/null
	echo -e "\nDownloading apktool.jar ...\n" && curl -o apktool.jar $apktool2 1>/dev/null && chmod +x "apktool.jar" && mv "apktool.jar" "/usr/local/bin/"
	cd ".." && rm -rf ".apktool"
fi

function help () {
	echo -ne "\nA tool for reverse engineering Android APK files
Usage:
Disassembling: dizapk app.apk
Reassembling:  dizapk b app

Use (dizapk -h / dizapk --help / dizapk help) to show this message\n"
	  }
[[ $1 == "--help" || $1 == "-h" || $1 == "help" || -z $1 ]] && help && exit 0

function diz () {
	java -jar /usr/local/bin/apktool.jar d "$1"
	dir=$(echo -e "${1}" |cut -d '.' -f1)
	echo -e "Disassembling done in ${dir} folder"
}
function rea () {
	apktool b "$1"
	echo -e "Reassembling APK done: ${dir}.apk"
}
if [[ $1 == "b" || $1 == "-b" ]] ; then
	rea
else
	diz
fi
####################### END #########################
