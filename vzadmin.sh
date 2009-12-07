#!/bin/bash

#------------------------------------------------------------------------------

## Config
DG=/usr/bin/dialog
VZC=/usr/sbin/vzctl
VZL=/usr/sbin/vzlist

## temp file
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

#------------------------------------------------------------------------------

## Меню - входа в VPS
_menu_enter() {
	CTLIST=$(printf "%s\\%s [ip:%s]\\" `$VZL -H -o ctid,hostname,ip`)

	IFS='\'

	$DG --clear --backtitle "OpenVZ Control Panel" --title "Список запущенных VPS" \
		--ok-label "Выбрать" --cancel-label "Выход" \
		--menu "Выберите VPS:" 0 0 0 \
		"" "Вывести cписок всех VPS ->" $CTLIST 2> $tempfile

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

# Меню - список VPS
_menu_list() {
	CTLIST=$(printf "%s\\%s [%s]\\" `$VZL -a -H -o ctid,hostname,status`)

	IFS='\'

	$DG --clear --backtitle "OpenVZ Control Panel" --title "Список всех VPS" \
		--nocancel --ok-label "Назад" \
		--menu "Список всех VPS:" 0 0 0 \
		$CTLIST 2> $tempfile

#	retval=$?

	unset IFS

#	choice=`cat $tempfile`

# 	if [ $retval == 0 ] ; then
# 		if [ -z $choice ]; then
# 			_menu_list
# 		else
# 			$VZC enter $choice
# 		fi
# 	else
# 		exit
# 	fi
}

while true; do
	_menu_enter
done