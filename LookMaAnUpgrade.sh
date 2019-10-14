#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#   This Script is designed for use in JAMF
#
#   - This script will ...
#       Locate the Machines Object in Active Directory and update it's OS Version Field if needed
#
###############################################################################################################################################
#
# Requires the following parameters be set.
#		DOMAIN=$4
#		USER=$5
#		PASS=$6
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.1 - 14/10/2019
#
#   - 13/12/2018 - V1.0 - Created by Headbolt
#
#   - 14/10/2019 - V1.1 - Updated by Headbolt
#                           More comprehensive error checking and notation
#
####################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################
#
# Grabs the NETBIOS name of the AD Domain that the users Machine Resides in from JAMF variable #4 eg. DOMAIN
DOMAIN=$4
# Grabs the Username of a user that has been granted specific permissions just for this task from JAMF variable #5 eg. username
# Recommended is Read/Write permissions ONLY to the OS Version Field of Descendant Computer Objects on the Relevant AD OU's 
USER=$5
# Grabs the Password of a user that has been granted specific permissions just for this task from JAMF variable #6 eg. password
PASS=$6
#
ScriptName="append prefix here as needed - Update AD Object With OS Version"
#
####################################################################################################
#
#   Checking and Setting Variables Complete
#
###############################################################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputting a Dotted Line for Reporting Purposes
/bin/echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
# Outputting a Blank Line for Reporting Purposes
#/bin/echo
#
/bin/echo Ending Script '"'$ScriptName'"'
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputting a Dotted Line for Reporting Purposes
/bin/echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
# 
# Begin Processing
#
####################################################################################################
#
# Outputs a blank line for reporting purposes
/bin/echo
#
SectionEnd
#
## Grab ComputerName
CompName=$(dsconfigad -show | awk '/Computer Account/{print $NF}' | sed 's/$$//')
#
## Grab Machine's Current Version
version=$(sw_vers | grep ProductVersion | cut -c 17-)
#
## Look up Machine Object in AD read current OS Version
ADverString=$(dscl -u $USER -P $PASS "/Active Directory/$DOMAIN/All Domains" -read /Computers/${CompName}$ operatingSystemVersion)
ADver=$(/bin/echo $ADverString | cut -c 42-)
#
/bin/echo Computername : $CompName
#
/bin/echo Current AD Version : $ADver
#
/bin/echo Current Machine Version : $version
#
# Outputs a blank line for reporting purposes
/bin/echo
#
/bin/echo Checking If Machine Version and AD Version Matches
#
# Outputs a blank line for reporting purposes
/bin/echo
#
## Check if Version Currently Matches
## If it does then do nothing
## If not, then replace the current version with the correct one
#
if [ "$ADver" == "" ]
	then
		echo Version is Actually BLANK !! - Setting It
		dscl -u $USER -P $PASS "/Active Directory/$DOMAIN/All Domains" -merge /Computers/${CompName}$ operatingSystemVersion $version
		# Outputs a blank line for reporting purposes
        echo
    else
        if [ "${ADver}" == $version ]
        	then
        		echo 'Version Matches, Nothing to do'
        	else
        		echo 'Version Does Not Match, Updating it'
                dscl -u $USER -P $PASS "/Active Directory/$DOMAIN/All Domains" -change /Computers/${CompName}$ operatingSystemVersion "${ADver}" $version
        fi
fi
#
SectionEnd
ScriptEnd
