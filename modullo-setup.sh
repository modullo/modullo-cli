#!/bin/bash

echo -e "MODULLO >> SETTING UP A PROJECT \n"

echo -e "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"


if [ -z "${project}" ]
then
      echo -e "Project Name (project) MUST be provided. \n";
      exit;
else
    
    echo -e "Project Name Selected is: ${project} \n"
fi

# Specify all necessary project files
PROJECT_FILE_CONFIG="projects/${project}/${project}.config"
PROJECT_FILE_CREDENTIALS="projects/${project}/${project}.credentials"
PROJECT_FILE_TERRAFORM="projects/${project}/${project}.tfvars"
PROJECT_FILE_ANSIBLE="ansible/vars/${project}.yml"
PROJECT_FILE_BACKUP="projects/${project}/${project}.backup"
#PROJECT_EXTRA_FILES="files"


if test -f "$PROJECT_FILE_CONFIG";
then
    echo -e "Project Config File exists already"
else
    mkdir -p "$(dirname ${PROJECT_FILE_CONFIG})" && touch "$PROJECT_FILE_CONFIG"
    echo -e "Project Config File ($PROJECT_FILE_CONFIG) created";

    # Read the template file, replace placeholders, and store the result in Project Config File
    PROJECT_ID=$(openssl rand -hex 3 | tr -dc 'a-zA-Z0-9' | head -c 6 | tr '[:upper:]' '[:lower:]')
    MODULLO_PROJECT_ID="$project-$PROJECT_ID"
    sed -e "s/{{MODULLO_PROJECT_NAME}}/$project/g" \
        -e "s/{{MODULLO_PROJECT_ID}}/$MODULLO_PROJECT_ID/g" \
        "modullo-templates/config.yml" > "$PROJECT_FILE_CONFIG"

fi


if test -f "$PROJECT_FILE_CREDENTIALS";
then
    echo -e "Project Credentials File exists already"
else
    mkdir -p "$(dirname ${PROJECT_FILE_CREDENTIALS})" && touch "$PROJECT_FILE_CREDENTIALS"

    # Read the template file, replace placeholders, and store the result in Project Credentials File
    SAMPLE_PARAMETER1="sample-value-1"
    SAMPLE_PARAMETER2="sample-value-2"
    sed -e "s/{{SAMPLE_VALUE_1}}/$SAMPLE_PARAMETER1/g" \
        -e "s/{{SAMPLE_VALUE_2}}/$SAMPLE_PARAMETER2/g" \
        "modullo-templates/credentials.tmpl" > "$PROJECT_FILE_CREDENTIALS"

    echo -e "Project Credentials File ($PROJECT_FILE_CREDENTIALS) created";
fi


if test -f "$PROJECT_FILE_TERRAFORM";
then
    echo -e "Terraform Parameter File exists already"

    # Run Provider Infrastructure setup if necessary
    if [ -z "${provider}" ]
    then
        # Do nothing if nor flagged
    else
        source modullo-includes/parse-config.sh # parse configuration file and extract data

        source modullo-includes/setup-infrastructure.sh # process project details
        # Create Terraform files for the infrastructure
        setup_terraform_config "$terraformConfig"

    fi


else
    mkdir -p "$(dirname ${PROJECT_FILE_TERRAFORM})" && touch "$PROJECT_FILE_TERRAFORM"

    # Read the template file, replace placeholders, and store the result in Project Credentials File
    READY_STATE="no"
    sed -e "s/{{READY_STATE_VALUE}}/$READY_STATE/g" \
        "modullo-templates/terraform.tmpl" > "$PROJECT_FILE_TERRAFORM"

    echo -e "Terraform Parameter File ($PROJECT_FILE_TERRAFORM) created";
fi


if test -f "$PROJECT_FILE_ANSIBLE";
then
    echo -e "Ansible Parameter File exists already"
else
    mkdir -p "$(dirname ${PROJECT_FILE_ANSIBLE})" && touch "$PROJECT_FILE_ANSIBLE"

    echo -e "Ansible Parameter File ($PROJECT_FILE_ANSIBLE) created";
fi

if test -f "$PROJECT_FILE_BACKUP";
then
    echo -e "Backup Parameter File exists already"
else
    mkdir -p "$(dirname ${PROJECT_FILE_BACKUP})" && touch "$PROJECT_FILE_BACKUP"

    echo -e "Backup Parameter File ($PROJECT_FILE_BACKUP) created";
fi

# if test -f "$PROJECT_EXTRA_FILES";
# then
#     echo -e "Extra project files exists already"
# else
#     cp -R "$PROJECT_EXTRA_FILES" projects/"${project}/$PROJECT_EXTRA_FILES/"

#     echo -e "Extra project files ($PROJECT_EXTRA_FILES) copied";
# fi





echo -e "\n PROJECT SETUP COMPLETE \n"
