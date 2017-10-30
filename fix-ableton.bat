rem Spiral 2: 10/29/17
rem Spiral 2 includes clarifications in final authorization instructions. -jma

@ECHO off
cls
echo **************WARNING! WARNING! WARNING!********************
echo *** You are about to clear the User directories for      ***
echo *** Ableton Live and enable Sassafras licensing.         ***
echo *** This will break Ableton if you are not careful.      ***
echo ***						      ***
echo *** You must run this script as an administrator.        ***
echo *** Use an elevated command prompt to execute.           ***
echo ************************************************************
:choice
set /P c=Are you sure you want to continue[Y/N]?
if /I "%c%" EQU "Y" goto :proceed
if /I "%c%" EQU "N" goto :eof
goto :choice


:proceed
echo I am going to delete the CommonConfiguration directory,
echo which may exist from older installations, and could
echo cause conflicts.
TIMEOUT 10
rd /s /q "C:\ProgramData\Ableton\CommonConfiguration" >nul 2>&1

rem This is where we get the Version number for Live.
set /p version="Enter Live Version Number: "

mkdir C:\ProgramData\Ableton\CommonConfiguration
mkdir "C:\ProgramData\Ableton\CommonConfiguration\Live %version%"
mkdir "C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Preferences"
mkdir "C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Database"
mkdir "C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Cache"

rem Write Options.txt

rem Saved in C:\ProgramData\Ableton\CommonConfiguration\Live VERSION\Preferences\
(
	echo -LicenseServer
	echo -DefaultsBaseFolder=C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Cache
	echo -DatabaseDirectory=C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Database
	echo -DontAskForAdminRights
	echo -EventRecorder=Off
	echo -_DisableAutoUpdates
	echo -_DisableUsageData 
	echo -_EnsureKeyMessagesForPlugins
	echo -ReWireMasterOff
) > "C:\ProgramData\Ableton\CommonConfiguration\Live "%version%"\Preferences\Options.txt"

cd /d "C:\Users"
for /d %%a in (*) do rd /s /q "C:\Users\%%a\AppData\Roaming\Ableton" >nul 2>&1

echo Complete. The next steps are:
echo 1. Launch Live.
echo 2. From Ableton Preferences, Change core library to 
echo C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Database
echo 3. Authorize Max4Live if installed.
echo 3. Move library.cfg to C:\ProgramData\Ableton\CommonConfiguration\Live %version%\Preferences
echo Search for and delete all other copies.
cd "C:\Users\%USERNAME%"
echo This window will close in 300 seconds.
TIMEOUT 300
GOTO EOF

:eof
