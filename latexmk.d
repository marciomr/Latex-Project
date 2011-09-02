#!/bin/bash

# icons
ICON_DIR="/home/marciomr/bin/.latexmk"
WARNING_ICON="$ICON_DIR/warning.png"
ERROR_ICON="$ICON_DIR/delete.png"
SUCCESS_ICON="$ICON_DIR/tick.png"

# icons from humanity
#ICON_DIR="/usr/share/icons/Humanity/status/48"
#WARNING_ICON="$ICON_DIR/dialog-warning.svg"
#ERROR_ICON="$ICON_DIR/dialog-error.svg"
#SUCCESS_ICON="$ICON_DIR/gtk-ok.svg"

# colors
txtrst=$(tput sgr0)    # Text reset
txtbld=$(tput bold)    # Bold
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow

MASTER="${PWD##*/}"

touch $MASTER.pdf

# run evince in the background
evince $MASTER.pdf &

while true; do 
    latexmk -pdf -silent $MASTER.tex > /dev/null 2>&1

    WARNING_MSG="";
    # check for errors
    ERROR_MSG=`rubber-info --errors $MASTER.tex`;
    BOXES_MSG=`rubber-info --boxes $MASTER.tex`;
    REFS_MSG=`rubber-info --refs $MASTER.tex`;

    # display warnings and error messages in a osd-notification
    if [ "$BOXES_MSG" ]; then
	WARNING_MSG="Boxes over/under-flow";
	echo "${txtylw}$BOXES_MSG${txtrst}";
    fi

    if [ "$REFS_MSG" ]; then
	WARNING_MSG="Couldn't find some refs";
	echo "${txtylw}$REFS_MSG${txtrst}";
    fi

    if [ ! "$ERROR_MSG" ]; then
	if [ "$WARNING_MSG" ]; then
	    notify-send "Rubber" "$WARNING_MSG" -i $WARNING_ICON;
	else
	    echo "${txtgrn}Working just fine :-)${txtrst}";
	    notify-send "Rubber" "Worked just fine." -i $SUCCESS_ICON;
	fi
    else
	echo "${txtred}$ERROR_MSG${txtrst}";
	NOTIFY_ERROR=`notify-send "Rubber" "${ERROR_MSG//\\/\\\\}" -i $ERROR_ICON 2>&1`;
	if [ "$NOTIFY_ERROR" ]; then
	    notify-send "Rubber" "Notification error" -i $ERROR_ICON
	fi
    fi

    echo ""

    # monitor .tex and .bib files
    MOD_FILES="*.tex"
    if [ -f *.bib ]; then MOD_FILES="$MOD_FILES *.bib"; fi
    
    echo [`date +%D\ %T`] `inotifywait -q -e modify $MOD_FILES`  
done