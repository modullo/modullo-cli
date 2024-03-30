#!/bin/bash

# Determing IAAS provider
available_providers="aws do"

provider_exists() {
    local provider_list="$1"
    local target_provider="$2"

    # Convert the space-separated list to an array
    IFS=' ' read -ra providers <<< "$provider_list"

    # Iterate over the array and check for a match
    for provider in "${providers[@]}"; do
        if [ "$provider" == "$target_provider" ]; then
        return 0  # Match found, return true (0)
        fi
    done

    return 1  # No match found, return false (1)
}



if provider_exists "$available_providers" "$config_infrastructure_provider"; then
    echo -e "Specified IAAS Provider would be used"
    iaas_provider="${config_infrastructure_provider}"
else
    echo -e "Specified IAAS Provider is not valid or not permitted. \n"; exit;
fi


source modullo-includes/setup-infrastructure.sh # process project details

# Determine infrastructure config based on Modullo config
declare -A terraformConfig  # Declare an associative array to store contact data
#terraformConfig=determine_terraform_config "$config_infrastructure_provider"

determine_terraform_config "$iaas_provider" terraformConfig

if [ ${#terraformConfig[@]} -eq 0 ]; then
    echo -e "Provider Data NOT FOUND for $iaas_provider."; exit;
else
    echo -e "Provider data FOUND for $iaas_provider \n"

    # Access values when column name is a variable
    infrastructure="${config_infrastructure_type}"
    echo -e "Infrastructure: ${terraformConfig[$infrastructure]} \n"
    #echo -e "Infratructure: ${terraformConfig[$infrastructure]:-Not available} \n"
fi


# Run final check if terraform file is ready to go
if grep -q "^ready = \"yes\"" "$PROJECT_FILE_TERRAFORM" && grep -q "^plan = \"$config_plan_id\"" "$PROJECT_FILE_TERRAFORM"; then
    modulloCreateInfrastructure="yes"
fi

# Run final check if ansible file file is ready to go
if grep -q "^provisioning_ready:yes" "$PROJECT_FILE_PROVISIONING" && grep -q "^provisioning_plan:$config_plan_id" "$PROJECT_FILE_PROVISIONING"; then
    modulloCreateProvisioning="yes"
fi