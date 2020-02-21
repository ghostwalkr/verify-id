#!/bin/bash
# Generates hashes to identify users that are verifiable by people that know how to make the hash
usage() {
	echo -e "usage: $0 <option>\n-g --generate | generate fingerprint hash\n-v --verify | verify fingerprint hash"
}

generate_hash() {
	time=`date -u +%S%M%k%d%m%Y` # date frmt: UTC second-minute-hour-dayofmonth-monthofyear-year
	secretstring="secretstring" # Could be username to verify specific person or just random string
	randomword=`shuf -n 1 wordlist`
	echo -e "\nTimestamp: $time"
	echo "$time$secretstring$randomword" | tr -d " " | sha512sum | tr -d " \-"
}

verify_hash() {
	secretstring="secretstring"
	read -p "time: " time
	read -p "hash: " hash

	try_number=0

	for word in `cat wordlist`
	do
		try=`echo "$time$secretstring$word" | tr -d " " | sha512sum | tr -d " \-"`
		if test $try == "$hash"; then
			echo "found hash after $try_number tries"
			return 0
		else
			let try_number++
			continue
		fi
	done

	return 1
}

if test $# == 0; then
	usage
	exit
fi

while test $# != 0
do
	case $1 in
		"-v"|"--verify")
			shift 1
			verify_hash
			if test $? == 0; then
				echo "Hash: OK"
			elif test $? == 1; then
				echo "Hash: Verification failed"
			else
				echo "unknown error in function verify_hash"
			fi
			;;
		"-g"|"--generate")
			shift 1
			generate_hash
			;;
		*)
			echo "invalid option: \"$1\""
			usage
			exit
	esac
done
