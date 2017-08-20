#!/usr/bin/env bash
# Options must include -m <commit message> and -p <pattern to find>
# Optionals include -n which is whether to use nonce to find hash or not.

use_nonce=false

while getopts ":m:p:n" opt; do
	case $opt in
		m)
			commit_message=$OPTARG
			;;
		p)
			pattern=$OPTARG
			;;
		n)
			use_nonce=true
			;;
		*)
			echo "Usage pow_commit.sh -m <commit_message> -p <pattern> -n"
			exit 1
			;;
		\?)
			echo "Unknown option $OPTARG"
			exit 1
			;;
		:)
			echo "Missing option argument for $OPTARG"
			exit 1
			;;
	esac
done


if [ ! $"commit_message" ] || [ ! "$pattern" ]
then
	echo "Missing options."
	exit 1
fi

added_files=$(git add .)

if [ ! -z $added_files ]
then
	echo "Nothing is staged for commit! Aborting!"
	exit 1
fi

tries=1

if [ $use_nonce = true ]
then
	git commit --quiet -m "${commit_message} Nonce: 1."
else
	git commit --quiet -m "${commit_message}"
fi

function commit {
	if [ $use_nonce = true ] 
	then
		git commit --amend --quiet -m "${commit_message} Nonce: ${tries}."
	else
		git commit --amend --quiet -m "${commit_message}"
	fi
}

commit_hash=$(git rev-parse HEAD)

while [[ $commit_hash != $pattern* ]] 
do
tries=$(($tries+1))
commit
commit_hash=$(git rev-parse HEAD)
done
