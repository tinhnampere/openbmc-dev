#!/bin/bash

# Initialize variables
BOOTSTRAP_ACC_LIST=$(< /etc/passwd awk -F: '{print $1}' | grep obmcRedfish)

# shellcheck disable=SC2068
# shellcheck disable=SC2086

for USER_NAME in ${BOOTSTRAP_ACC_LIST[@]}
do
	USER_ID=$(ipmitool user list 1 | grep "$USER_NAME" | cut -c1-2)
	echo "Delete Bootstrap account $USER_NAME, User ID is $USER_ID"
	ipmitool user disable $USER_ID
	ipmitool user set name $USER_ID ""
done
