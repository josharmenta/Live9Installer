#!/bin/bash
# Ableton Live 9 Suite installation for PCM.
# NOTE: This script supplants fix-live-all.sh
# and installs Ableton to use Sassafras
# floating keys. Must be run as root.
# jma 7/15/2017


ROOT_UID=0     # Only users with $UID 0 have root privileges.
E_NOTROOT=87   # Non-root exit error.


# Run as root, of course.
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi  

# Script initialization
clear
echo "###############################################################################"
echo "### WARNING: THIS SCRIPT WILL OVERWRITE ANY PREFERENCES YOU HAVE ALREADY    ###"
echo "### CREATED FOR ABLETON! IF YOU ALREADY RUN THIS INSTALLATION PROCESS, YOU  ###"
echo "### WILL RESET ABLETON COMPLETELY TO FACTORY SETTINGS, AND WILL INTERRUPT   ###"
echo "### OTHER PEOPLE'S WORK. WITH GREAT POWER COMES GREAT RESPONSIBILITY!       ###"
echo "###                                                                         ###"
echo "###                    You have been warned...                              ###"
echo "###############################################################################"

read -rsp $'This script installs Ableton Live for Network Users. Press enter to continue...\n'
echo "First, I need to delete old Preference and Packs Directories"	
sleep 1
rm -rf /Users/Shared/Ableton/Live*

echo "I need some information from you to proceed."
sleep 1

# We need to find out what the shortname of the account is for later stuff purposes.
echo "Running logname to see your account's short name..."
sleep 1
SHORTNAME="$(logname)"
echo "You are currently logged in as $SHORTNAME. This information is critical to the Ableton installation."

# We need to know where /Users is really located
read -p "Enter the path to the Users directory. The default is /Users > " USERPATH
name=${USERPATH:-/Users}
echo $USERPATH

# We need the version number. It keeps changing, so let's prompt for it.
echo "Enter the Live Version Number you wish to install (e.g. 10.1.2)> "
read VERSION

# We should double-check, mistakes happen!
echo "You entered: Live $VERSION."
read -p "Is this correct?  <y/N> " prompt
if [[ $prompt == "n" || $prompt == "N" || $prompt == "no" || $prompt == "No" ]]
then
	echo "Check your version number and try again."
	exit 1
else

	echo "Now checking for Ableton in the Applications folder. Please wait..."

	sleep 3

	# Is Ableton already installed? If not, quit.
	if [ ! -d "/Applications/Ableton?" ]; then
		echo "Ableton is not in the Applications folder. Installation will halt."
		echo "Please move Ableton.app to /Applications and run script again."
		exit 1
	fi

	echo "Ableton is in the Applications folder. Let's proceed..."

	sleep 2

	# Does the Shared Preferences folder for the specific version exist? If so, delete.
	echo "Checking to see if the Shared Preferences library for the specified version already exists..."
	sleep 2
	if [ -d "/Library/Preferences/Ableton/Live $VERSION" ]; then
		sleep 1
		echo "Shared Preferences folder exists. Deleting to avoid conflicts."
		sleep 1
		rm -rf /Library/Preferences/Ableton/Live\ $VERSION
	fi
	
	echo "Checking to see if the Shared Packs library for the specified version already exists..."
	sleep 2
	if [ -d "/Users/Shared/Ableton/Live $VERSION" ]; then
		sleep 1
		echo "Shared Packs folder exists. Deleting to avoid conflicts."
		sleep 1
		rm -rf /Users/Shared/Ableton/Live\ $VERSION
	fi
	

	# Let's make the Shared Preferences folder
	echo "Creating Shared Preferences directory..."
	sleep 1
	mkdir "/Library/Preferences/Ableton" &> /dev/null
	mkdir "/Library/Preferences/Ableton/Live $VERSION" &> /dev/null

	# Now we will create the shared Packs directory
	echo "Creating Shared Packs directory..."
	sleep 1
	mkdir "/Users/Shared/Ableton" &> /dev/null
	mkdir "/Users/Shared/Ableton/Live $VERSION" &> /dev/null
	mkdir "/Users/Shared/Ableton/Live $VERSION/Packs" &> /dev/null
	

	# Now we will create the Cache directory
	echo "Creating Cache directory..."
	sleep 1
	mkdir "/Users/Shared/Ableton" &> /dev/null
	mkdir "/Users/Shared/Ableton/Live $VERSION" &> /dev/null
	mkdir "/Users/Shared/Ableton/Live $VERSION/Cache" &> /dev/null

	# Now we will create the database directory
	echo "Creating Database directory..."
	sleep 1
	mkdir "/Users/Shared/Ableton/Live $VERSION/Database" &> /dev/null


	# Time to create Options.txt
	echo "Creating Options.txt file..."
	sleep 1
	cat <<EOF >"/Library/Preferences/Ableton/Live $VERSION/Options.txt"
-LicenseServer
-DefaultsBaseFolder=</Users/Shared/Ableton/Live $VERSION/Cache>
-DatabaseDirectory=</Users/Shared/Ableton/Live $VERSION/Database>
-DontAskForAdminRights
-EventRecorder=Off
-_DisableAutoUpdates
-_DisableUsageData
-ReWireMasterOff
EOF

	sleep 2
	# Open Ableton and Authorize. We'd better explain this for future Sysadmins.
	echo "I am going to open Ableton. You may need to enter your password."
	echo "This will create Ableton's directories that need to be moved by me."
	echo "Enter your password, wait for all the Packs to install, and come back to me..."
	read -rsp $'Press enter to proceed...\n'
		
	open "/Applications/Ableton Live 9 Suite.app"

	sleep 5
	
	# Time to move the packs
	echo "Open Ableton's preferences. Change the location of the Packs to /Users/Shared/Ableton/Live $VERSION/Packs"
	echo "Allow Ableton to move the Packs to the new location."
	read -rsp $'Press enter to proceed...\n'

	sleep 1
	
	# Authorize Max for Live
	echo "Open a Max patch from Ableton and enter your password to authorize Max for Live"
	read -rsp $'Press enter to proceed...\n'

	sleep 1
	
	# Let's close Ableton
	echo "I will close Ableton Live in 5 seconds. "
	sleep 1
	echo -ne '###            (20%)\r'
	sleep 1
	echo -ne '######         (40%)\r'
	sleep 1
	echo -ne '#########      (60%)\r'
	sleep 1
	echo -ne '############   (80%)\r'
	sleep 1
	echo -ne '###############(100%)\r'
	echo -ne '\n'
	
	pkill Live

    # We need to make the directory owned by local admin and execute only
    echo "Adjusting permissions for packs directory..."
    sleep 1
    chown $SHORTNAME /Users/Shared/Ableton/Live\ $VERSION/Packs
    chmod -f -R 755 "/Users/Shared/Ableton/Live $VERSION/Packs"

	# We need to move Library.cfg and replace two lines
	# Let's start by moving it
	echo "Moving Library.cfg to Shared directory"
	sleep 1
	mv ~/Library/Preferences/Ableton/Live\ $VERSION/Library.cfg /Library/Preferences/Ableton/Live\ $VERSION
	# Now we will change the location of the User library and ProjectPaths
	echo "Updating Library.cfg to allow users to save in home directory"
	sleep 1
	sed -i.bak s/$SHORTNAME/%%USERNAME%%/g /Library/Preferences/Ableton/Live\ $VERSION/Library.cfg

	# Now it's time to clean up.
	echo "I'm going to start cleaning up now."
	echo "I'm deleting all user-created preference"
	echo "files for Ableton."
	sleep 1
	cd $USERPATH

	# We need to protect Shared from the next thing. Lets move it to /Users/tmp
    echo "Moving Shared to a temporary location while I clean $USERPATH"
	mkdir /AbletonInstallTemp
	mv ./Shared/ /AbletonInstallTemp/
	
	sleep 1
	cd $USERPATH
	for user in $USERPATH
	do
		#ensure "user" is a dir
		if [ -d $user ]
		then
			#echo isdir $user
			echo "Deleting User Created Preference files from user $user..." 
			{ 
				rm -rf $USERPATH/$user/Library/Application\ Support/Ableton/
				rm -rf $USERPATH/$user/Library/Preferences/Ableton/
			}  &> /dev/null
		else
			echo "$user is not a user"
 		fi
	
done

mv /AbletonInstallTemp/Shared $USERPATH/
rm -rf /AbletonInstallTemp
	
	
	
	
fi
	

echo "Process complete. Please login as a non-admin user and test Ableton."
