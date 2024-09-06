#!/bin/bash

# Function to generate the configuration
generate_config() {
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download WGCF
    wget https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_amd64 > /dev/null 2>&1
    chmod +x wgcf_2.2.22_linux_amd64

    # Generate account and obtain configuration
    ./wgcf_2.2.22_linux_amd64 register --accept-tos > /dev/null 2>&1
    ./wgcf_2.2.22_linux_amd64 generate > /dev/null 2>&1
    cat wgcf-profile.conf

    # Clean up the temporary directory
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Function to modify the configuration
modify_config() {
    local config="$1"
    local insert_text="Jc = 120
Jmin = 23
Jmax = 911
H1 = 1
H2 = 2
H3 = 3
H4 = 4"

    # Read the configuration line by line, modify it, and output the result
    local line_num=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        if [[ $line_num -eq 3 ]]; then
            echo "$insert_text"
        fi
        if [[ $line == "DNS ="* ]]; then
            echo "DNS = 8.8.8.8"
        elif [[ $line == "Endpoint ="* ]]; then
            echo "Endpoint = 162.159.193.5:2408"
        else
            echo "$line"
        fi
    done <<< "$config"
}

# Main code
config=$(generate_config)
modified_config=$(modify_config "$config")
apt -y install qrencode > /dev/null 2>&1
echo "$modified_config" | qrencode -t ansiutf8
echo "$modified_config"
