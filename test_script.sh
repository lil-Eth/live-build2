#!/bin/bash

set -e
set -o pipefail  # Bashism

KALI_DIST="kali-rolling"
KALI_VERSION=""
KALI_VARIANT="default"
TARGET_DIR="$(dirname $0)/images"
TARGET_SUBDIR=""
SUDO="sudo"
VERBOSE=""
USER=""
FILE=""
PENTEST=(forensic gpu pwtools rfid voip web wireless) 


for_list()
{
	input="junk"
	inputArray=()
	while [ "$input" != "" ]
	do
		read -p "Press enter : " input
		inputArray+=("${input}") 
	done
}


Add_package_list()
{
	echo "[+] Add personnal packages to the VM"
	echo "Enter the packages you need : "
	for_list
	if [ ! -f live-build/kali-config/variant-custom/package-lists/perso.list.chroot ]
	then
		touch live-build/kali-config/variant-custom/package-lists/perso.list.chroot 
	fi
	for var in  "${inputArray[@]}"
	do
		echo "$var" >> live-build/kali-config/variant-custom/package-lists/perso.list.chroot
	done
	chmod 755 live-build/kali-config/variant-custom/package-lists/perso.list.chroot
}

Add_file()
{
	echo "[+] Adding file :"
	continue=true
	while [ continue = true ];
	do
		read -p "Which file do you want to add ?" $FILE
		if [ -f $FILE ]
		then
			echo "Add in:\n\t1)Root directory\n\t2)/etc/skel"
			if [ !-z $USER ]
			then
				echo "\n\t3)$USER directory"
			fi
			read -p "Choice : " choice
			case $choise in
				1) cp $FILE live-build/kali-config/variant-custom/includes.chroot/root
				;;
				2) cp $FILE live-build/kali-config/variant-custom/includes.chroot/etc/skel
				;;
				3) cp $FILE live-build/kali-config/variant-custom/includes.chroot/usr
					#	KFLRKJGERLJGR ON PARLE CHINOIS
				;;
				*) echo "Bad parameter"
			esac
			cp $FILE 		
		else
			continue
		fi
		read -p " Do you want to add other file ?(Y/N) " $continue
		if [ $continue == "N" ]
		then
			$continue=false
		else
			continue
		fi
	done
}

Add_config()
{
	end="yes"
	file="live-build/kali-config/variant-custom/hooks/live/"
	echo "[+] Add config to the VM"
	while [ $end == "yes" ]
	do
		echo "Enter the config you want to add"
		for_list
		read -p "file you want to configure : " file_hooks
		file_to_add="$file$file_hooks.hooks"
		echo ${inputArray[@]} > $file_to_add
		chmod 755 $file_to_add
		echo -e "do you want to add another config ? \n"
		read -p "Yes/no : " end
	done


}


Add_group()
{
	echo "[+] Add group to the VM"
	echo "Enter the group you want to create : "
	for_list
	mkdir -p live-build/kali-config/variant-custom/includes.chroot/usr/lib/live/config/
	echo "LIVE_USER_DEFAULT_GROUPS='${inputArray[@]}'" > live-build/kali-config/variant-custom/includes.chroot/usr/lib/live/config/user-setup.conf
	chmod 755 live-build/kali-config/variant-custom/includes.chroot/usr/lib/live/config/user-setup.conf
}


Add_user()
{
	echo "[+] Add user"
	read -p "Enter name of user : " USER
	sed -i "s/username=root/username=$USER/g" live-build/auto/config  
}

# Initialization
if [ ! -d ./live-build ]
then
	# does not exist
	echo "[+] Get initial files"
	git clone https://github.com/nasri136/live-build.git
else
	# check if there is EVERYTHING i don't know how
	echo "[+] Got initial files"		
fi

# TYPE OF PENTEST 
#echo "What type of pentest you want to do : "
#echo -e "\n\t1)Forensic\n\t2)Gpu\n\t3)Password cracking\n\t4)RFID\n\t5)VoIP Testing\n\t6)Web\n\t7)Wireless"
#read -p "\nChoice : " pentest_choice
#echo -e "${PENTEST[$pentest_choice-1]}" >> live-build/kali-config/variant-custom/package-lists/kali.list.chroot


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
# ARGUMENTS
case $key in
    -v|--verbose)
    VERBOSE="1"
    shift # past argument
    echo "Verbose ok"
    ;;
    --variant)
    KALI_VARIANT="$2"
    shift # past argument
    echo "variant : $KALI_VARIANT"
    shift # past value
    ;;
    -g|--group)
    Add_group 
    shift;
    ;;
    -p|--packages)
    shift
    Add_package_list
    ;;
    -f|--file)
    Add_file
    shift
    ;;
    -u|--user)
    Add_user
    shift 
    ;;
    -c|--config)
    Add_config
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    echo "ERROR : invalid command-line option: $1" >&2;
    exit 1
    shift # past argument
    ;;
esac
done

# Packages


echo "[+] Live Build Kali Creation"








