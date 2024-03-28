#!/bin/bash

echo "MODULLO >> REMOVING A PROJECT"

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


if [ -z "${project}" ]
then
      echo -e "Project Name (project) MUST be provided."; exit;
else
      echo -e "Project Name Selected is: ${project}"
fi

read -p "Are you sure you wish to destroy the ($project) project? This will IRREVERSIBLY delete all resources previously created (Y or N) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    terraform -chdir=terraform/ workspace select ${project} || terraform -chdir=terraform/ workspace new ${project}

    terraform -chdir=terraform/ plan -destroy -out "../projects/${project}/${project}.tfplan" -var-file="../projects/${project}/${project}.tfvars"
    terraform -chdir=terraform/ apply "../projects/${project}/${project}.tfplan"
fi



echo "PROJECT REMOVAL COMPLETE"