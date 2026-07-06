#!/bin/bash

file="$1"

if [ -z "$file" ]
then
	echo "Config file is missing"
	exit 1
fi

if [ ! -f "$file" ]
then
	echo "File not found: $file"
	exit 1
fi

echo "Config file found: $file"

totalS=0
totalUP=0
totalDOWN=0
priorityCOUNT=0
totalWRONG=0

while read name port priority expectedProcess
do
	checkP=$(ss -tlnp | grep "$port")
	if [ -z "$checkP" ]
	then
		echo "$name: DOWN, port $port, $priority"
		totalDOWN=$((totalDOWN + 1))
			if [ "$priority" = "required" ]
			then
				priorityCOUNT=$((priorityCOUNT + 1))
			fi
	else
			checkProcess=$( echo "$checkP" | grep "$expectedProcess" )
			if [ -z "$checkProcess" ]
			then
				totalWRONG=$((totalWRONG + 1))
				echo "$name, WRONG_PROCESS, port $port, expected $expectedProcess"
					if [ "$priority" = "required" ]
					then
						priorityCOUNT=$((priorityCOUNT + 1))
					fi
			else
				localBind=$( echo "$checkP" | grep "127.0.0.1:$port")
				allBind=$( echo "$checkP" | grep "0.0.0.0:$port")
				if [ -n "$localBind" ]
				then
					echo "$name: UP, port $port, $priority, bind=LOCAL"
				elif [ -n "$allBind" ]
				then
					echo "$name: UP, port $port, $priority, bind=ALL"
				else
					echo "$name: UP, port $port, $priority, bind=SPECIFIC"
				fi
				totalUP=$((totalUP + 1))
			fi
	fi
	totalS=$((totalS + 1))
done < "$file"

echo "Summary: total=$totalS, UP=$totalUP, DOWN=$totalDOWN, WRONG=$totalWRONG"

if [ "$priorityCOUNT" -eq 0 ]
then
	echo "Overall: OK"
	exit 0
elif [ "$priorityCOUNT" -gt 0 ]
then
	echo "Overall: FAIL, required services down: $priorityCOUNT"
	exit 1
fi
