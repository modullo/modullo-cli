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
    "do:do_token,do_droplet_size"
    "aws:access_key,secret_key,route53_zone,iam_user,aws_vm_business,aws_vm_enterprise,aws_vm_knowledge"
)

# Function to get create terraform data for a given provider
setup_terraform_config() {
    local provider="$1"

    # Iterate over each entry in the database array
    for entry in "${provider_database[@]}"; do
        # Check if the entry starts with the provider
        if [[ "$entry" == "$provider"* ]]; then

            # tfvars file(s) (key value params)
            # module.tf file (module initiation + params)

            local teraform_file="$PROJECT_FILE_CREDENTIALS"

            # empty file

            # update main file

            # Extract the provider data from the entry
            IFS=',' read -r -a configs <<< "${entry#*:}"  # Split the entry into fields
            for config in "${configs[@]}"; do
            
                echo "$config = \"\"" >> "$teraform_file"
            
            done

            # Exit loop
            return
        fi
    done

    # If provider not found, return failure
    return 1
}