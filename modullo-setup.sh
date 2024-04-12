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
    echo -e "Project Config File exists already \n"
else
    mkdir -p "$(dirname ${PROJECT_FILE_CONFIG})" && touch "$PROJECT_FILE_CONFIG"
    echo -e "Project Config File ($PROJECT_FILE_CONFIG) created \n";

    # Read the template file, replace placeholders, and store the result in Project Config File
    PROJECT_ID=$(openssl rand -hex 3 | tr -dc 'a-zA-Z0-9' | head -c 6 | tr '[:upper:]' '[:lower:]')
    MODULLO_PROJECT_ID="$project-$PROJECT_ID"
    sed -e "s/{{MODULLO_PROJECT_NAME}}/$project/g" \
        -e "s/{{MODULLO_PROJECT_ID}}/$MODULLO_PROJECT_ID/g" \
        "modullo-templates/config.yml" > "$PROJECT_FILE_CONFIG"

fi


if test -f "$PROJECT_FILE_CREDENTIALS";
then
    echo -e "Project Credentials File exists already \n"
else
    mkdir -p "$(dirname ${PROJECT_FILE_CREDENTIALS})" && touch "$PROJECT_FILE_CREDENTIALS"

    # Read the template file, replace placeholders, and store the result in Project Credentials File
    SAMPLE_PARAMETER_1="sample-parameter-1"
    SAMPLE_VALUE_1="sample-value-1"
    sed -e "s/{{SAMPLE_PARAM_1}}/$SAMPLE_PARAMETER_1/g" \
        -e "s/{{SAMPLE_VAL_1}}/$SAMPLE_VALUE_1/g" \
        "modullo-templates/credentials.tmpl" > "$PROJECT_FILE_CREDENTIALS"

    echo -e "Project Credentials File ($PROJECT_FILE_CREDENTIALS) created \n";
fi


if test -f "$PROJECT_FILE_TERRAFORM";
then
    echo -e "Terraform Parameter File exists already \n"

    # Run Provider Infrastructure setup if necessary
    if [ -z "${plan}" ]
    then
        # Do nothing if nor flagged
        echo -e "...\n"
    else

        source modullo-includes/parse-config.sh # parse configuration file and extract data

        source modullo-includes/setup-infrastructure.sh # process project details

        proceedWithPlanning="no"

        if grep -q "^ready = " "$PROJECT_FILE_TERRAFORM"; then

            # Prompt the user Advise on overite of existing tfvars and tplan (in fact delete tfplan)
            read -rp "Proceeding with the \"plan\" flag will re-create your terraform files ($PROJECT_FILE_TERRAFORM) and (terraform/module.tf). Do you want to continue? (Y/N): " response
            response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

            if [[ "$response" == "y" || "$response" == "yes" ]]; then

                proceedWithPlanning="yes"
                
                echo -e "Planning infrastructure setup for provider ($config_infrastructure_provider)...\n"

            else
                echo -e "Skipping the infrastructure planning for provider ($config_infrastructure_provider)...\n"
            fi

        else
            proceedWithPlanning="yes"

            echo -e "Planning infrastructure setup for provider ($config_infrastructure_provider)...\n"
        fi

        if [[ "$proceedWithPlanning" == "yes" ]]; then
            declare -A providerConfig
            determine_terraform_config "$config_infrastructure_provider" providerConfig

            if [ ${#providerConfig[@]} -eq 0 ]; then
                echo -e "Issue determining for $config_infrastructure_provider."; exit;
            else
                # Access values when column name is a variable
                infra="${config_infrastructure_type}"
                config_infrastructure_type_local="${providerConfig[$infra]}"
            fi

            # Create Terraform files for the infrastructure
            setup_terraform_config "$config_infrastructure_provider"
        fi


    fi


else
    mkdir -p "$(dirname ${PROJECT_FILE_TERRAFORM})" && touch "$PROJECT_FILE_TERRAFORM"

    # Read the template file, replace placeholders, and store the result in Project Credentials File
    READY_STATE="no"
    sed -e "s/{{READY_STATE_VALUE}}/$READY_STATE/g" \
        "modullo-templates/terraform.tmpl" > "$PROJECT_FILE_TERRAFORM"

    echo -e "Terraform Parameter File ($PROJECT_FILE_TERRAFORM) created \n";
fi


if test -f "$PROJECT_FILE_ANSIBLE";
then
    echo -e "Ansible Parameter File exists already \n"
else
    mkdir -p "$(dirname ${PROJECT_FILE_ANSIBLE})" && touch "$PROJECT_FILE_ANSIBLE"

    echo -e "Ansible Parameter File ($PROJECT_FILE_ANSIBLE) created \n";
fi

if test -f "$PROJECT_FILE_BACKUP";
then
    echo -e "Backup Parameter File exists already \n"
else
    mkdir -p "$(dirname ${PROJECT_FILE_BACKUP})" && touch "$PROJECT_FILE_BACKUP"

    echo -e "Backup Parameter File ($PROJECT_FILE_BACKUP) created \n";
fi

# if test -f "$PROJECT_EXTRA_FILES";
# then
#     echo -e "Extra project files exists already"
# else
#     cp -R "$PROJECT_EXTRA_FILES" projects/"${project}/$PROJECT_EXTRA_FILES/"

#     echo -e "Extra project files ($PROJECT_EXTRA_FILES) copied";
# fi

source modullo-includes/check-project.sh # process project details



echo -e "\n PROJECT SETUP COMPLETE \n"
