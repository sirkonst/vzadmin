#!/bin/bash

#------------------------------------------------------------------------------

## Config
DG=`which dialog`
VZC=`which vzctl`
VZL=`which vzlist`

if [[ -z "$DG" || -z "$VZC" || -z "$VZL" ]]; then
    echo "[!] Ensure that installed: dialog, vzctl and vzlist"
    exit 1
fi


## temp file
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

#------------------------------------------------------------------------------


_menu_enter() {
    CTLIST=$(printf "%s\\%s [ip:%s]\\" `$VZL -H -o ctid,hostname,ip`)

    IFS='\'

    $DG --clear --backtitle "OpenVZ Control Panel" --title "List of running VPS" \
        --ok-label "Select" --cancel-label "Exit" \
        --menu "Select VPS:" 0 0 0 \
        "" "Display all VPS ->" $CTLIST 2> $tempfile

    retval=$?

    unset IFS

    choice=`cat $tempfile`

    if [ $retval == 0 ] ; then
            if [ -z $choice ]; then
                    _menu_list
            else
                    $VZC enter $choice
            fi
    else
            exit
    fi
}


_menu_list() {
    CTLIST=$(printf "%s\\%s [%s]\\" `$VZL -a -H -o ctid,hostname,status`)

    IFS='\'

    $DG --clear --backtitle "OpenVZ Control Panel" --title "List of all VPS" \
            --nocancel --ok-label "Go back" \
            --menu "List of all VPS:" 0 0 0 \
            $CTLIST 2> $tempfile

    unset IFS
}


while true; do
    _menu_enter
done
