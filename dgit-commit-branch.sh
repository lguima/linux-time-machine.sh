#!/bin/bash -i
### dgit-commit-branch
# This script's purpouse is to commit all changes made to $HOME directory using dgit, which is a previously set alias for git with some specific parameters. This script is part of linux-home-timemachine project
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2018 - 08 - 04

# check environment requirements
function check-env () {
	
	echo -e "Checking if working environment is ok"

	cd $HOME
	echo -e "Current directory is $PWD"

	# Check whether git is a valid command
	echo -ne "git status is: "
	if command git --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: git check"
		exit 1
	fi

	# Check whether dgit alias works or not
	echo -ne "dgit status is: "
	if dgit --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: dgit check"
		exit 2
	fi

	# Check which branch we are
	CUR_BRANCH="$(dgit branch | grep \* | cut -d\  -f2 2> /dev/null)"
	echo -e "Current branch is: ${CUR_BRANCH}"
	# Go add new files
	# add-files

	# Remove deleted files
	remove-files


	# Go commit the changes
	commit-changes
}

function remove-files () {

	if dgit status | egrep 'deleted'
	then
		# Delete files using dgit status and dgit rm
		dgit rm --cached -f -r $(dgit status | egrep 'deleted:' | cut -d\: -f2 | xargs)
	fi
	
}

function add-files () {

	# Add files using find
	find . -maxdepth 1 -mindepth 1 -not -name '.dotfiles' -not -name '.mozilla' -not -name '.cache' -not -name '.xsession-errors' -not -name 'git' -not -name '.viminfo' -not -name '.gnupg' -not -name '.pki' -not -name '.local' -not -iname '*.iso' -not -iname '*.mp4' -not -iname '*.srt' | while read line ; do dgit add -f "${line}"; done
	#find . -maxdepth 1 -mindepth 1 -not -name '.dotfiles' -not -name '.mozilla' -not -name '.cache' | while read line ; do dgit add -f "${line}"; done

}

function commit-changes () {

	export EDITOR=$(which nano)
	COMMIT_DATE="$(date +'%Y.%m.%d-%H.%M')"

	# Check if we need to commit
	# main command: dgit status | grep 'working tree clean' && echo OK || echo FAIL
	if dgit status | grep 'working tree clean' > /dev/null 2>&1
	then
		echo -e "${COMMIT_DATE}: Working tree is clean :)"
	else
		echo -e "Starting commit ${COMMIT_DATE}"
		# Commit changes to branch
		if dgit commit -a -m "Automated commit at ${COMMIT_DATE}"
		then
			echo Commit is ok
		else
			echo Commit failed
		fi	
	fi

}

function main () {
	check-env
}


main
