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

# Parse YAML using yq and store it in a single variable
# parsed_yaml=$(yq "$PROJECT_FILE_CONFIG")


