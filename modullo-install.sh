#!/bin/bash

echo "MODULLO >> INSTALLING MYSELF :-)"

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


installPath="~/.modullo-cli"

installRepo="https://github.com/modullo/modullo-cli.git"


# Check List of Required software


# Dowload Modullo CLI Repository


# Enable Aliases


# Run a check command


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

    ansible-playbook -i projects/${project}/ansible_inventory ./ansible/modullo-provision.yml --ssh-common-args="-o IdentitiesOnly=yes -o StrictHostKeyChecking=no" --extra-vars "@./ansible/vars/${project}.yml"

else

    echo -e "Skipping Infrastructure Provisioning \n";

fi


echo "MODULLO INSTALLATION COMPLETE"
