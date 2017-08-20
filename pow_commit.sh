#!/usr/bin/env bash
# Options must include -m <commit message> and -z <zeroes in pattern to find>
# Optionals include -n which is whether to use nonce to find hash or not.

use_nonce=false

while getopts ":m:z:n" opt; do
	case $opt in
		m)
			commit_message=$OPTARG
			;;
		z)
			zeroes=$OPTARG
			;;
		n)
			use_nonce=true
			;;
		*)
			echo "Usage pow_commit.sh -m <commit_message> -z <zeroes> -n"
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


if [ ! $"commit_message" ] || [ ! "$zeroes" ]
then
	echo "Missing options."
	exit 1
fi

zero_regex_string=$(printf "%0${zeroes}d" 0)

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

while [[ $commit_hash != ${zero_regex_string}* ]] 
do
tries=$(($tries+1))
commit
commit_hash=$(git rev-parse HEAD)
done
