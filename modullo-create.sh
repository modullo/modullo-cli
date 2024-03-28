#!/bin/bash

echo "MODULLO >> CREATING A PROJECT"

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


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


exit;


# Get Required Libraries for provisioning
ansible-galaxy install -r ./ansible/requirements.yml
# perhaps design to load selectively in the future

if [[ "$modulloCreateProvisioning" == "yes" ]]; then
    # Provision Infrastructure using Ansible

    ansible-playbook -i projects/${project}/ansible_inventory ./ansible/dorcas.yml --ssh-common-args="-o IdentitiesOnly=yes -o StrictHostKeyChecking=no" --extra-vars "iaas_provider=${iaas_provider}" --extra-vars "project=${project}" --extra-vars "edition=${edition}" --extra-vars "domain=${domain}" --extra-vars "email=${email}" --extra-vars="setup_root=${setup_root}" --extra-vars "partner_name=${partner_name}" --extra-vars "partner_slug=${partner_slug}" --extra-vars "partner_logo_url=${partner_logo_url}" --extra-vars "git_user=${git_user}" --extra-vars "git_pass=${git_pass}" --extra-vars "db_password=${DB_PASSWORD}" --extra-vars "refresh_apps=${refresh_apps}" --extra-vars "with_portal=${with_portal}" --extra-vars "with_marketplace=${with_marketplace}" --extra-vars "with_knowledge=${with_knowledge}" --extra-vars "with_lms=${with_lms}" --extra-vars "with_university=${with_university}" --extra-vars "with_scheduler=${with_scheduler}"

else

    echo -e "Skipping Infrastructure Provisioning \n";

fi


echo "PROJECT CREATION COMPLETE"
