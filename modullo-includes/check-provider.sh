#!/bin/bash

# Determing IAAS provider
available_providers="aws-lightsail do-droplet"

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

if [ -z "${provider}" ]
then
    iaas_provider="aws-lightsail"
else

    if provider_exists "$available_providers" "$provider"; then
        echo -e "Specified IAAS Provider would be used"
        iaas_provider="${provider}"
        #"../terraform-modules/${var.iaas_provider}"
    else
        echo -e "Specified IAAS Provider is not valid or not permitted."; exit;
    fi

fi
echo -e "IAAS Provider is: ${iaas_provider}"