#!/bin/bash
#Written by Manuel Iglesias. glesialo@gmail.com

CommandName=${0##*/}
BackUpDir="$HOME/var"
ListOfCommandsFile="${BackUpDir}/$CommandName"
ListOfCommandsDefaultContents="#   ###### $CommandName: Applications to launch ######
#####################################################################
# No comments in 'Command line'. If necessary add them in previous line.
# 'Command line' can include environment variables.
# Comment out/add 'Command lines':
#
# Start all peer to peer applications
#StartAllDownloadingClients
# Default Internet browser (you can add Url [-tab Url]...)
#DefaultBrowser
# Internet mail client '--pa' means previously used account (In case there are several accounts)
#InternetMail --pa
# Play system music
#PlayAudioFilesList_Music"



echoE(){
echo -e "$*" 1>&2
echo -e "$*" | Dialog_MessageTimed --title "$CommandName: Error:" --timeout 0 --file - &
return 0
}

Usage(){
echoE "'$CommandName' launches start of session applications
as listed in file '\$HOME_VAR_DIR/$CommandName'.
File will be created (and offered for editing) if it doesn't exist.

Usage: '$CommandName'.

Note:
  '$CommandName' logs to 'CommonLog'
  ('CommonLog --help')."
return 0
}



if [ "$1" == "-h" ] || [ "$1" == "-?" ] || [ "$1" == "--help" ] || [ "$1" == "-help" ]
  then
    Usage
    exit 64
fi

if [ ! -f "$ListOfCommandsFile" ]
  then
    if [ ! -d "$BackUpDir" ]
      then
        if mkdir $BackUpDir &>/dev/null
          then
            echo "$CommandName: Directory '\$HOME_VAR_DIR' created.." | CommonLog --echo-out
          else
            echoE "$CommandName: '\$HOME_VAR_DIR' can not be created. Aborting." 2>&1 | CommonLog --echo-err
            exit 73
        fi
    fi
    echo "$ListOfCommandsDefaultContents" >"$ListOfCommandsFile"
    DefaultTextEditor "$ListOfCommandsFile"
    exit 0
fi

Error=false
OldIFS=$IFS;IFS=$'\n'
for Application in $(cat "$ListOfCommandsFile") # Background processes launched in a 'while read' loop are not seen as jobs of this script
  do
    if [ -n "$Application" ] && [ "$Application" == "${Application#\#}" ] # If line not empty and doesn't start with '#'
      then
        if type "${Application%% *}" &>/dev/null
          then
            bash -c "$Application" & # bash so that this script goes on even if $Application fails
            if [ -n "$!" ] # If "$Application" was launched in background
              then
                echo "$CommandName: '$Application' launched." | CommonLog --echo-out
              else
                echoE "$CommandName: Failed to launch '$Application' in background." 2>&1 | CommonLog --echo-err
                Error=true
            fi
          else
            echoE "$CommandName: Application '${Application%% *}' not found. Skipped." 2>&1 | CommonLog --echo-err
            Error=true
        fi
    fi
  done
IFS=$OldIFS

if $Error
  then
    echoE "$CommandName: Warning! Failed to launch some start-session applications." 2>&1 | CommonLog --echo-err
    exit 1
  else
    echo "$CommandName: All start-session applications started." | CommonLog --echo-out
    exit 0
fi