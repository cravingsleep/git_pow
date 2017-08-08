commit_message=$1
# How many zeros at the start of the commit hash?
zeros_at_start=$2
zero_regex_string=$(printf "%0${zeros_at_start}d" 0)

added_files=$(git add .)

if [ ! -z $added_files ]
then
	echo "Nothing is staged for commit! Aborting!"
	exit 1
fi

git commit --quiet -m "${commit_message}. Nonce: 1."
commit_hash=$(git rev-parse HEAD)

tries=1

while [[ $commit_hash != ${zero_regex_string}* ]] 
do
tries=$(($tries+1))
git commit --amend --quiet -m "${commit_message}. Nonce: ${tries}."
commit_hash=$(git rev-parse HEAD)
end_time=$(date +%s.%N)
done
