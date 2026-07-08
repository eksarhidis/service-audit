#!/bin/bash

if [ -z "$1" ]
then
	echo "Missing domain"
	exit 1
fi
echo "Target: $1"

checkDNS=$(host "$1" | grep "has")

if [ -z "$checkDNS" ]
then
	echo "DNS FAIL, Overall: FAIL"
	exit 1
else
	checkHTTP=$(curl -s --connect-timeout 3 -I "http://$1" | grep  "200 OK")
		if [ -z "$checkHTTP" ]
		then
			echo "DNS OK, HTTP FAIL, Overall: FAIL"
			exit 1
		else
			echo "DNS OK, HTTP OK, Overall: OK"
			exit 0
		fi
fi
