#!/bin/bash

echo "MODULLO >> CREATING A PROJECT\n"

modulloCommand="create"

echo -e "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"


modulloCreateInfrastructure="no"
modulloCreateProvisioning="no"


source modullo-includes/check-project.sh # process project details


source modullo-includes/check-provider.sh # process provider details


if [[ "$modulloCreateInfrastructure" == "yes" ]]; then
    # Create Infrastructure using Teraform

    terraform -chdir=terraform/ workspace select ${project} || terraform -chdir=terraform/ workspace new ${project}
    terraform -chdir=terraform/ init


    terraform -chdir=terraform/ plan -out "../projects/${project}/${project}.tfplan" -var-file="../projects/${project}/${project}.tfvars"
    terraform -chdir=terraform/ apply ${replace} "../projects/${project}/${project}.tfplan"

else

    echo -e "Skipping Infrastructure Creation. Check the $PROJECT_FILE_TERRAFORM file is setup properly! \n";

fi



# Get Required Libraries for provisioning
ansible-galaxy install -r ./ansible/requirements.yml
# perhaps design to load selectively in the future

if [[ "$modulloCreateProvisioning" == "yes" ]]; then
    # Provision Infrastructure using Ansible

    echo -e "\nWaiting 60 seconds for Infrastructure to propagate fully. Skip? Press 'Y' or 'yes' to skip."

    for ((i=60; i>=0; i--)); do
        echo -ne "Time remaining: $i seconds \r"
        read -t 1 -n 1 -s input
        if [[ $input =~ [Yy] ]]; then
            echo -e "\nSkipped! Proceeding with provisioning...\n"
            break;
        fi
    done

    if [[ ! $input =~ [Yy] ]]; then
        echo -e "\nTime's up! Proceeding with provisioning...\n"
        # Add your remaining script here
    fi


    ansible-playbook -i projects/${project}/inventory ./ansible/modullo-provision.yml --ssh-common-args="-o IdentitiesOnly=yes -o StrictHostKeyChecking=no" \
    --extra-vars "@./ansible/vars/${project}.yml" \
    --extra-vars "@./ansible/group_vars/all.yml" \
    --extra-vars "params_path_project=projects/${project}/${project}.params" \
    --extra-vars "params_path_infrastructure=projects/${project}/parameters_infrastructure" \
    --extra-vars "params_path_provisioning=projects/${project}/parameters_provisioning"

else

    echo -e "Skipping Infrastructure Provisioning \n";

fi


echo "PROJECT CREATION COMPLETE"
