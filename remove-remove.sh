#!/bin/bash

echo "DORCAS PROJECT REMOVAL AUTOMATION"

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


if [ -z "${project}" ]
then
      echo -e "Project Name (project) MUST be provided."; exit;
else
      echo -e "Project Name Selected is: ${project}"
fi


# Extract Variables passed to the parent Make Command OR read from file
PROJECT_PARAMETERS_FILE="projects/${project}/${project}.params"

if test -f "$PROJECT_PARAMETERS_FILE";
then
    echo -e "Dorcas Parameter File exists ($PROJECT_PARAMETERS_FILE); proceeding to use this..."

    while IFS=: read -r key pair
    do
    echo "Reading $key..."
      if [[ "$key" == "domain" ]]; then
          domain="$pair"
          echo -e "Dorcas Domain READ: $pair"
      fi
    
      if [[ "$key" == "email" ]]; then
          email="$pair"
          echo -e "Administrative Email READ: $pair"
      fi
    
      if [[ "$key" == "edition" ]]; then
          edition="$pair"
          echo -e "Dorcas Edition READ: $pair"
      fi
    
      if [[ "$key" == "setup_root" ]]; then
          setup_root="$pair"
          echo -e "Setup Root Path READ: $pair"
      fi

      if [[ "$key" == "refresh_apps" ]]; then
          refresh_apps="$pair"
          echo -e "Refresh Other Applicationn Software READ: $pair"
      fi

      if [[ "$key" == "with_portal" ]]; then
          with_portal="$pair"
          echo -e "Add Portal Software READ: $pair"
      fi
    
      if [[ "$key" == "with_marketplace" ]]; then
          with_marketplace="$pair"
          echo -e "Add Marketplace Software READ: $pair"
      fi

      if [[ "$key" == "with_knowledge" ]]; then
          with_knowledge="$pair"
          echo -e "Add Knowledge Software READ: $pair"
      fi

      if [[ "$key" == "with_lms" ]]; then
          with_lms="$pair"
          echo -e "Add LMS Software READ: $pair"
      fi

      if [[ "$key" == "with_university" ]]; then
          with_university="$pair"
          echo -e "Add University Software READ: $pair"
      fi

      if [[ "$key" == "with_scheduler" ]]; then
          with_scheduler="$pair"
          echo -e "Add Scheduler Software READ: $pair"
      fi

    done < "$PROJECT_PARAMETERS_FILE"

else 

    echo -e "Project Automation Parameter File Not Found; please create this and retry..."; exit;

fi

# Create the Compute Machine on the IAAS Provider (e.g AWS)

read -p "Are you sure you wish to destroy the ($project) project? (Y or N) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    terraform -chdir=terraform/ workspace select ${project} || terraform -chdir=terraform/ workspace new ${project}

    terraform -chdir=terraform/ plan -destroy -out "../projects/${project}/${project}.tfplan" -var-file="../projects/${project}/${project}.tfvars" -var="project=${project}" -var="edition=${edition}"  -var="setup_root=${setup_root}" -var="with_portal=${with_portal}" -var="with_marketplace=${with_marketplace}" -var="with_knowledge=${with_knowledge}" -var="with_lms=${with_lms}" -var="with_university=${with_university}" -var="with_scheduler=${with_scheduler}"
    terraform -chdir=terraform/ apply "../projects/${project}/${project}.tfplan"
fi


echo "REMOVAL OF DORCAS PROJECT ($project) COMPLETE!"
#so