#!/bin/bash



# Install yaml2json if not present
# command -v yaml2json >/dev/null 2>&1 || sudo apt-get update && sudo apt-get install -y yq # Not in standard ubuntu

if command -v yq >/dev/null 2>&1; then
    echo -e "yq is installed... \n"
else
    echo -e "yq is not installed. Attempting to install... \n"

    # Download yq binary
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O yq
    wget https://github.com/bronze1man/yaml2json/releases/download/v1.3/yaml2json_linux_386 -O ccccccc

    # Make the downloaded file executable
    chmod +x yq
    chmod +x yaml2json

    # Move the binary to a directory in your PATH (e.g., /usr/local/bin)
    sudo mv yq /usr/local/bin/
    sudo mv yaml2json /usr/local/bin/

    if command -v yq >/dev/null 2>&1; then
        echo -e "yq installed successfully. \n"
    else
        echo -e "Failed to install yq. Please install it manually. \n"
        exit;
    fi
fi


# Function to validate YAML syntax
validate_yaml_syntax() {
    local yaml="$1"
    if yaml2json <<< "$yaml" >/dev/null 2>&1; then
        echo -e "Modullo Config Syntax is valid \n"
    else
        echo -e "Modullo Config Syntax is not valid."
        exit;
    fi
}


# Read YAML file content
yaml_content=$(<"$PROJECT_FILE_CONFIG")

# Validate YAML syntax
validate_yaml_syntax "$yaml_content"

# Extract Necessary Variables from Project CONFIG file
config_project_name="$(yq '.modulloProject.name' $PROJECT_FILE_CONFIG)"; echo "Project Name: $config_project_name"
config_project_id="$(yq '.modulloProject.id' $PROJECT_FILE_CONFIG)"; echo "Project ID: $config_project_id"
config_plan_id="$(yq '.modulloProject.plan' $PROJECT_FILE_CONFIG)"; echo "Plan ID: $config_plan_id"
config_project_setup_root="$(yq '.modulloProject.setup_root' $PROJECT_FILE_CONFIG)"; echo "ProjectSetup Root: $config_project_setup_root"
config_project_project_root="$(yq '.modulloProject.project_root' $PROJECT_FILE_CONFIG)";
config_project_domain="$(yq '.modulloProject.domain' $PROJECT_FILE_CONFIG)"; echo "Plan ID: $config_project_domain"
config_project_email="$(yq '.modulloProject.email' $PROJECT_FILE_CONFIG)"; echo "Project Email: $config_project_email"
config_project_deployment="$(yq '.modulloProject.deployment' $PROJECT_FILE_CONFIG)"; echo "Project Deployment: $config_project_deployment"
config_infrastructure_provider="$(yq '.modulloProject.infrastructure.provider' $PROJECT_FILE_CONFIG)"; echo "Project Infrastructure Provider: $config_infrastructure_provider"
config_infrastructure_type="$(yq '.modulloProject.infrastructure.type' $PROJECT_FILE_CONFIG)"; echo "Project Infrastructure Type: $config_infrastructure_type"
config_infrastructure_options="$(yq '.modulloProject.infrastructure.options' $PROJECT_FILE_CONFIG)"; echo "Project Infrastructure Options: $config_infrastructure_options"
config_provisioning_database="$(yq '.modulloProject.provisioning.database' $PROJECT_FILE_CONFIG)"; echo "Project Provisioning Database: $config_provisioning_database"
config_provisioning_type="$(yq '.modulloProject.provisioning.type' $PROJECT_FILE_CONFIG)";
config_provisioning_software_os="$(yq '.modulloProject.provisioning.software_os' $PROJECT_FILE_CONFIG)";
config_provisioning_software_system="$(yq '.modulloProject.provisioning.software_system' $PROJECT_FILE_CONFIG)";
config_provisioning_software_framework="$(yq '.modulloProject.provisioning.software_framework' $PROJECT_FILE_CONFIG)";
config_provisioning_options="$(yq '.modulloProject.provisioning.options' $PROJECT_FILE_CONFIG)";
config_provisioning_commands="$(yq '.modulloProject.provisioning.commands' $PROJECT_FILE_CONFIG)";
config_provisioning_commands="$(yq '.modulloProject.provisioning.commands' $PROJECT_FILE_CONFIG)";

echo -e "\n"