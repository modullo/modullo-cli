#!/bin/bash

# Check if the function already exists
if ! type modullo &>/dev/null; then
    # Function does not exist, create it

modullo_function=$(cat <<'EOF'
function modullo() {
    case "$1" in
        setup)
            make modullo-setup ${@:2}
            ;;
        create)
            make modullo-create ${@:2}
            ;;
        *)
            echo "Usage: modullo [setup|create] project=<project_name>"
            ;;
    esac
}
EOF
)

    # Echo the multiline text to a file
    echo "$modullo_function" > ~/.bashrc
    source ~/.bashrc
    echo "Function 'modullo' created successfully!"
else
    echo "Function 'modullo' already exists!"
fi