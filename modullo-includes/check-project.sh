#!/bin/bash

if [ -z "${project}" ]
then
      echo -e "Project Name (project) MUST be provided."; exit;
fi


# Check if all necessary project files are presentt
PROJECT_FILE_CONFIG="projects/${project}/${project}.config"
PROJECT_FILE_CREDENTIALS="projects/${project}/${project}.credentials"
PROJECT_FILE_TERRAFORM="projects/${project}/${project}.tfvars"
PROJECT_FILE_ANSIBLE="ansible/vars/${project}.yml"
PROJECT_FILE_BACKUP="projects/${project}/${project}.backup"
PROJECT_FILE_PROVISIONING="projects/${project}/parameters_provisioning"



if test -f "$PROJECT_FILE_CREDENTIALS" || test -f "$PROJECT_FILE_TERRAFORM" || test -f "$PROJECT_FILE_ANSIBLE" || test -f "$PROJECT_FILE_CONFIG" || test -f "$PROJECT_FILE_BACKUP";
then
    echo -e "All Required Project Files exists ($PROJECT_FILE_CREDENTIALS, $PROJECT_FILE_TERRAFORM, $PROJECT_FILE_ANSIBLE, $PROJECT_FILE_CONFIG, $PROJECT_FILE_BACKUP); proceeding to use these..."

    source modullo-includes/parse-config.sh # parse configuration file and extract data

    # Extract Necessary Variables from Project CREDENTIALS file
    while IFS=: read -r key pair
    do
    echo -e "\n Reading $key..."

      if [[ "$key" == "git_user" ]]; then
          credentials_git_user="$pair"
          echo -e "Github Username READ: $pair \n"
      fi
    
      if [[ "$key" == "git_pass" ]]; then
          credentials_git_pass="$pair"
          echo -e "Github Password / Token READ \n"
      fi
    
    done < "$PROJECT_FILE_CREDENTIALS"

else 

    echo -e "Project Files ($PROJECT_FILE_CREDENTIALS, $PROJECT_FILE_TERRAFORM, $PROJECT_FILE_ANSIBLE, $PROJECT_FILE_CONFIG, $PROJECT_FILE_BACKUP) NOT FOUND! \nPlease GENERATE with "make modullo-setup project=abc123", CONFIGURE necessary parameters and then retry...\n";
    exit;

fi


# Create a database password if a database is to be provisioned

# Function to generate a random alphanumeric string
generate_random_string() {
    head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10
}

create_database_password() {
    local db="$1"
    local acceptable_dbs=("mysql") #("mysql" "value2" "value3")

    if [ -z "$db" ]; then
        echo -e "Database NOT specified. Exiting password creation... \n"
        return
    fi

    local found=false
    for value in "${acceptable_dbs[@]}"; do
        if [ "$db" == "$value" ]; then
            found=true
            break
        fi
    done

    if ! $found; then
        echo -e "Database ($db) NOT supported. Exiting password creation... \n"
        return
    fi

    # Check if key exists in file
    local file="$PROJECT_FILE_CREDENTIALS"
    local file_key="db_root_password"

    if grep -q "^$file_key:" "$file"; then
        echo "db_root_password already exists in $file."
    else
        local file_value=$(generate_random_string)
        if grep -q "leave this line" "$file"; then
            sed -i "/leave this line/i $file_key:$file_value" "$file"
            echo "db_root_password added to $file."
        else
            echo "$file_key=$file_value" >> "$file"
            echo "db_root_password added to $file."
        fi
    fi
}

# Create Database Password if database is selected
create_database_password "$config_provisioning_database"




# Validate config setup_root before creating infrastructure/provisioning (proposed) => check specific root file or exist