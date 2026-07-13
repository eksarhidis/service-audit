#!/bin/bash

if [ -z "$1" ]
then
	echo "Missing name"
	exit 1
fi

if [ -z "$2" ]
then
	echo "Missing target"
	exit 1
fi


checkCON=$(docker ps -a | grep "$1")
if [ -n "$checkCON" ]
then
	echo "[$(date)] CONTAINER EXISTS"
		checkCONRUN=$(docker ps | grep "$1")
			if [ -n "$checkCONRUN" ]
			then
				echo "[$(date)] CONTAINER RUNNING"
					checkCONPORT=$(ss -ltnp | grep ":$2")
					if [ -n "$checkCONPORT" ]
					then
						echo "[$(date)] PORT OK"
							httpCHECK=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$2")
							if [ "$httpCHECK" != "000" ]
							then
								echo "[$(date)] HTTP RESPONSE: $httpCHECK"
							else
								echo "[$(date)] HTTP FAIL"
							fi
					else
						echo "[$(date)] PORT FAIL"
					fi
			else
				echo "[$(date)] CONTAINER NOT RUNNING"
			fi
else
	echo "[$(date)] NOT FOUND CONTAINER"
fi
