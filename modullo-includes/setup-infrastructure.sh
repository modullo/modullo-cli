#!/bin/bash


# Local database array of provider infrastructure
provider_database=(
    "local:vm=local,storage=local"
    "do:vm=droplet,storage=spaces"
    "aws:vm=lightsail,storage=s3,compute=ec2"
)

# Function to get provider data for a given provider
determine_terraform_config() {
    local provider="$1"
    local -n provider_data=$2  # Create a reference to the associative array

    # Iterate over each entry in the database array
    for entry in "${provider_database[@]}"; do
        # Check if the entry starts with the provider
        if [[ "$entry" == "$provider"* ]]; then
            # Extract the provider data from the entry
            IFS=',' read -r -a fields <<< "${entry#*:}"  # Split the entry into fields
            for field in "${fields[@]}"; do
                IFS='=' read -r key value <<< "$field"  # Split the field into key and value
                provider_data["$key"]="$value"  # Store key-value pair in associative array
            done

            # Exit loop
            return
        fi
    done

    # If provider not found, return failure
    return 1
}



# Local database array of provider infrastructure
terraform_database=(
    "local:project,plan,ready,domain,email,deployment,iaas_provider,options,region,setup_root,project_root,db,do_token,do_droplet_size"
    "do:project,plan,ready,domain,email,deployment,iaas_provider,options,region,setup_root,project_root,db,do_token,do_droplet_size"
    "aws:project,plan,ready,domain,email,deployment,iaas_provider,options,region,setup_root,project_root,db,access_key,secret_key,route53_zone,iam_user,aws_vm"
)

# Terraform Vars Template
terraform_module_template_start=$(cat << 'EOF'
module \"iaas_provider_module\" {
  source = \"../terraform-modules/$config_infrastructure_provider/$config_infrastructure_type_local\"

EOF
)

terraform_module_template_end=$(cat << 'EOF'

}


EOF
)

terraform_var_template=$(cat << 'EOF'

variable \"$config_var\" {
  description = \"Terraform Variable $config_var\"
}

EOF
)

# Function to get create terraform data for a given provider
setup_terraform_config() {
    local provider="$1"

    # Iterate over each entry in the database array
    for entry in "${terraform_database[@]}"; do
        # Check if the entry starts with the provider
        if [[ "$entry" == "$provider"* ]]; then


            local ansible_file_project="$PROJECT_FILE_ANSIBLE"
            local teraform_file_project="$PROJECT_FILE_TERRAFORM"
            local teraform_file_module="terraform/module.tf"

            local parameters_file_provisioning="projects/${project}/parameters_provisioning"

            # empty the files file
            > $ansible_file_project
            > $teraform_file_project
            > $teraform_file_module
            touch $parameters_file_provisioning > $parameters_file_provisioning # create and/or empty

            terraform_module_output_start=$(eval "echo \"$terraform_module_template_start\"")
            echo "$terraform_module_output_start" >> $teraform_file_module

            #echo "ready = \"no\"" >> "$teraform_file_project"; # tfvars file(s) prepend ready tags

            echo "---" >> "$ansible_file_project"; # yaml file prepend line

            # Extract the provider data from the entry
            IFS=',' read -r -a configs <<< "${entry#*:}"  # Split the entry into fields
            for config in "${configs[@]}"; do
            
                echo "$config = \"\"" >> "$teraform_file_project"; # tfvars file(s) (key value params)

                echo "  $config = var.$config" >> "$teraform_file_module"; # module.tf file (module vars)

                echo "$config: \"\"" >> "$ansible_file_project"; # project.yml ansible

            done

            terraform_module_output_end=$(eval "echo \"$terraform_module_template_end\"")
            echo "$terraform_module_output_end" >> $teraform_file_module

            # Resume loop to add more variables to module file
            for config in "${configs[@]}"; do

                config_var=$config
                terraform_var_output=$(eval "echo \"$terraform_var_template\"")
                echo "$terraform_var_output" >> $teraform_file_module

            done

            # if we need to escape more => escaped_new_value=$(sed 's/[][\.^$*+?{}\\()|]/\\&/g' <<< "$new_value")

            # Fill some key tfvars
            sed -i "s/^project = .*/project = \"$config_project_name\"/" "$teraform_file_project"
            sed -i "s/^domain = .*/domain = \"$(sed 's/[\.\/&]/\\&/g' <<< "$config_project_domain")\"/" "$teraform_file_project"
            sed -i "s/^email = .*/email = \"$config_project_email\"/" "$teraform_file_project"
            sed -i "s/^deployment = .*/deployment = \"$config_project_deployment\"/" "$teraform_file_project"
            sed -i "s/^iaas_provider = .*/iaas_provider = \"$config_infrastructure_provider\"/" "$teraform_file_project"
            sed -i "s/^setup_root = .*/setup_root = \"$(sed 's/[\/&]/\\&/g' <<< "$config_project_setup_root")\"/" "$teraform_file_project"
            sed -i "s/^project_root = .*/project_root = \"$(sed 's/[\/&]/\\&/g' <<< "$config_project_project_root")\"/" "$teraform_file_project"
            sed -i "s/^options = .*/options = \"$config_infrastructure_options\"/" "$teraform_file_project"

            # Fill some key yaml
            sed -i "s/^project: .*/project: \"$config_project_name\"/" "$ansible_file_project"
            sed -i "s/^domain: .*/domain: \"$(sed 's/[\.\/&]/\\&/g' <<< "$config_project_domain")\"/" "$ansible_file_project"
            sed -i "s/^email: .*/email: \"$config_project_email\"/" "$ansible_file_project"
            sed -i "s/^deployment: .*/deployment: \"$config_project_deployment\"/" "$ansible_file_project"
            sed -i "s/^iaas_provider: .*/iaas_provider: \"$config_infrastructure_provider\"/" "$ansible_file_project"
            sed -i "s/^setup_root: .*/setup_root: \"$(sed 's/[\/&]/\\&/g' <<< "$config_project_setup_root")\"/" "$ansible_file_project"
            sed -i "s/^project_root: .*/project_root: \"$(sed 's/[\/&]/\\&/g' <<< "$config_project_project_root")\"/" "$ansible_file_project"
            sed -i "s/^db: .*/db: \"modullo\"/" "$ansible_file_project"
            sed -i "s/^options: .*/options: \"$config_infrastructure_options\"/" "$ansible_file_project"

            # update the plan ID in both tfvars, config and yml
            PLAN_ID=$(openssl rand -hex 3 | tr -dc '0-9' | head -c 10 | tr '[:upper:]' '[:lower:]')
            sed -i "s/^plan = .*/plan = \"$PLAN_ID\"/" "$PROJECT_FILE_TERRAFORM"
            sed -i "s/^  plan: .*/  plan: $PLAN_ID/" "$PROJECT_FILE_CONFIG"
            sed -i "s/^plan: .*/plan: \"$PLAN_ID\"/" "$ansible_file_project"


            # prepare parameters_provisioning file so it can be used during provisioning like parameters_infrastructure
            echo "provisioning_ready:yes" >> "$parameters_file_provisioning";
            echo "provisioning_plan:$PLAN_ID" >> "$parameters_file_provisioning";
            echo "provisioning_type:$config_provisioning_type" >> "$parameters_file_provisioning";
            echo "provisioning_software_os:$config_provisioning_software_os" >> "$parameters_file_provisioning";
            echo "provisioning_software_system:$config_provisioning_software_system" >> "$parameters_file_provisioning";
            echo "provisioning_software_framework:$config_provisioning_software_framework" >> "$parameters_file_provisioning";
            echo "provisioning_options:$config_provisioning_options" >> "$parameters_file_provisioning";
            echo "provisioning_database:$config_provisioning_database" >> "$parameters_file_provisioning";
            echo "provisioning_database_root_username:$db_root_username" >> "$parameters_file_provisioning";
            echo "provisioning_database_root_password:$db_root_password" >> "$parameters_file_provisioning";


            echo -e "Infrastructure files successfully created/re-created for provider ($config_infrastructure_provider)...\n"

            echo -e "YOU MAY NEED TO STILL NEED TO FILL MORE VARIABLES. PLEASE CHECK ($teraform_file_project)...\n"


            # Exit loop
            return
        fi
    done

    # If provider not found, return failure
    return 1
}