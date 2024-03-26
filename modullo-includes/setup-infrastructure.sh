#!/bin/bash

# Local database array of provider infrastructure
provider_database=(
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
    "do:domain,iaas_provider,region,do_token,do_droplet_size"
    "aws:domain,iaas_provider,region,access_key,secret_key,route53_zone,iam_user,aws_vm"
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


            local teraform_file_project="$PROJECT_FILE_TERRAFORM"
            local teraform_file_module="terraform/module.tf"

            # empty the files file
            > $teraform_file_project
            > $teraform_file_module

            terraform_module_output_start=$(eval "echo \"$terraform_module_template_start\"")
            echo "$terraform_module_output_start" >> $teraform_file_module

            echo "ready = \"no\"" >> "$teraform_file_project"; # tfvars file(s) prepend ready tags

            # Extract the provider data from the entry
            IFS=',' read -r -a configs <<< "${entry#*:}"  # Split the entry into fields
            for config in "${configs[@]}"; do
            
                echo "$config = \"\"" >> "$teraform_file_project"; # tfvars file(s) (key value params)

                echo "  $config = var.$config" >> "$teraform_file_module"; # module.tf file (module vars)
            done

            terraform_module_output_end=$(eval "echo \"$terraform_module_template_end\"")
            echo "$terraform_module_output_end" >> $teraform_file_module


            # Resume loop to add more variables to module file
            for config in "${configs[@]}"; do

                config_var=$config
                terraform_var_output=$(eval "echo \"$terraform_var_template\"")
                echo "$terraform_var_output" >> $teraform_file_module

            done

            # Exit loop
            return
        fi
    done

    # If provider not found, return failure
    return 1
}