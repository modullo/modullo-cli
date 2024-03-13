#!/bin/bash

echo "MODULLO >> CREATING A PROJECT"

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


source modullo-includes/check-project.sh # process project details


source modullo-includes/check-provider.sh # process provider details


echo -e "VALUE is $param"
exit;



if [[ "$refresh_infrastructure" == "yes" ]]; then
    # Create the Compute Machine on the IAAS Provider (e.g AWS)
    terraform -chdir=terraform/ workspace select ${project} || terraform -chdir=terraform/ workspace new ${project}
    terraform -chdir=terraform/ init

    # replace=""
    # if [[ "$replace_knowledge" == "yes" ]]; then
    #     replace+=" -replace=aws_lightsail_instance.lightsail_instance_knowledge[0]"
    # fi

    terraform -chdir=terraform/ plan -out "../projects/${project}/${project}.tfplan" -var-file="../projects/${project}/${project}.tfvars" -var="project=${project}" -var="domain=${domain}" -var="edition=${edition}" -var="setup_root=${setup_root}" -var="with_portal=${with_portal}" -var="with_marketplace=${with_marketplace}" -var="with_knowledge=${with_knowledge}" -var="with_lms=${with_lms}" -var="with_university=${with_university}" -var="with_scheduler=${with_scheduler}"
    terraform -chdir=terraform/ apply ${replace} "../projects/${project}/${project}.tfplan"
fi


ansible-galaxy install -r ./ansible/requirements.yml

if [[ "$refresh_setup" == "yes" ]]; then
    # Provision the Compute Machine (install & setup software) inside using Ansible
    # --start-at-task="Project Compute - Install Redis"
    ansible-playbook -i projects/${project}/ansible_inventory ./ansible/setup.yml --ssh-common-args="-o IdentitiesOnly=yes -o StrictHostKeyChecking=no" --extra-vars "iaas_provider=${iaas_provider}" --extra-vars "project=${project}" --extra-vars "edition=${edition}" --extra-vars "domain=${domain}" --extra-vars "email=${email}" --extra-vars="setup_root=${setup_root}" --extra-vars "db_password=${DB_PASSWORD}" --extra-vars "refresh_apps=${refresh_apps}" --extra-vars "with_portal=${with_portal}" --extra-vars "with_marketplace=${with_marketplace}" --extra-vars "with_knowledge=${with_knowledge}" --extra-vars "with_lms=${with_lms}" --extra-vars "with_university=${with_university}" --extra-vars "with_scheduler=${with_scheduler}"
fi

if [[ "$refresh_dorcas" == "yes" ]]; then
    # Setup & Configure Dorcas software using Ansible
    # --start-at-task="Optimize Installation"
    ansible-playbook -i projects/${project}/ansible_inventory ./ansible/dorcas.yml --ssh-common-args="-o IdentitiesOnly=yes -o StrictHostKeyChecking=no" --extra-vars "iaas_provider=${iaas_provider}" --extra-vars "project=${project}" --extra-vars "edition=${edition}" --extra-vars "domain=${domain}" --extra-vars "email=${email}" --extra-vars="setup_root=${setup_root}" --extra-vars "partner_name=${partner_name}" --extra-vars "partner_slug=${partner_slug}" --extra-vars "partner_logo_url=${partner_logo_url}" --extra-vars "git_user=${git_user}" --extra-vars "git_pass=${git_pass}" --extra-vars "db_password=${DB_PASSWORD}" --extra-vars "refresh_apps=${refresh_apps}" --extra-vars "with_portal=${with_portal}" --extra-vars "with_marketplace=${with_marketplace}" --extra-vars "with_knowledge=${with_knowledge}" --extra-vars "with_lms=${with_lms}" --extra-vars "with_university=${with_university}" --extra-vars "with_scheduler=${with_scheduler}"
fi


echo "PROJECT CREATION COMPLETE"
