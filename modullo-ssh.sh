#!/bin/bash

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


if [ -z "${project}" ]
then
      echo -e "Project Name (project) MUST be provided.\n";
      exit;
else
    
    echo -e "Project Name Selected is: ${project}\n"
fi


# Check Necessary Connection Parameters

PROJECT_FILE_ANSIBLE="projects/${project}/ansible_inventory"

if test -f "$PROJECT_FILE_ANSIBLE";
then
    echo -e "Project Connection Details Exists...\n"
else
    echo -e "Project Connection Details Does Not Exist. Exiting...\n";
    exit;
fi

PROJECT_FILE_SSH="projects/${project}/instance-sshkey"
if test -f "$PROJECT_FILE_SSH";
then
    echo -e "Project Instance SSH Key Exists...\n"
else
    echo -e "Project Instance SSH Key Does Not Exist. Exiting...\n";
    exit;
fi

#EXTRACT SSH PARAMETERS

# Extract the IP address following the keyword
INSTANCE_DATA=$(grep -A1 "\[compute\]" "$PROJECT_FILE_ANSIBLE" | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print; exit}')
IFS=' # ' read -ra instance_data_parts <<< "$INSTANCE_DATA"
INSTANCE_IP="${instance_data_parts[0]}"

# Check if an IP address was found
if [ -n "$INSTANCE_IP" ]; then
    echo -e "Instance IP address found: $INSTANCE_IP\n"
else
    echo -e "No Instance IP address found\n";
    exit;
fi


INSTANCE_LOGIN=$(grep -m1 "^ansible_ssh_user=" "$PROJECT_FILE_ANSIBLE")
IFS='=' read -ra instance_login_parts <<< "$INSTANCE_LOGIN"
INSTANCE_USERNAME="${instance_login_parts[1]}"


# Check if Username is found
if [ -n "$INSTANCE_USERNAME" ]; then
    echo -e "Instance Username found: $INSTANCE_USERNAME\n"
else
    echo -e "No value found for 'ansible_ssh_user'\n"
    exit;
fi


echo -e "CONNECTING TO PROJECT INSTANCE...\n\n"

ssh -i $PROJECT_FILE_SSH $INSTANCE_USERNAME@$INSTANCE_IP -o="StrictHostKeyChecking=false"
