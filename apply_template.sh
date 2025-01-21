#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to read YAML values
get_yaml_value() {
    local yaml_file="template.yaml"
    local key=$1
    grep "^$key:" "$yaml_file" | awk -F': ' '{print $2}' | sed 's/"//g'
}

echo -e "${YELLOW}Starting template application...${NC}"

# Replace example README with actual README
if [ -f "example_README.md" ]; then
    mv example_README.md README.md
    echo -e "${GREEN}✓ Replaced${NC} README.md"
fi

# Define the patterns to search for files
PATTERNS=(
    "README.md"
    "pyproject.toml"
    "SECURITY.md"
    "LICENSE"
    "CONTRIBUTING.md"
    "src/config.py"
    "src/main.py"
    "src/static/robots.txt"
    "src/templates/*.jinja"
    "src/templates/components/*.jinja"
    "src/placeholder/__init__.py"
)

# Read values from template.yaml
declare -A REPLACEMENTS=(
    ["author"]="$(get_yaml_value "author")"
    ["author_email"]="$(get_yaml_value "author_email")"
    ["author_social"]="$(get_yaml_value "author_social")"
    ["author_nickname"]="$(get_yaml_value "author_nickname")"
    ["security_email"]="$(get_yaml_value "security_email")"
    ["github_username"]="$(get_yaml_value "github_username")"
    ["github_repository"]="$(get_yaml_value "github_repository")"
    ["package_name"]="$(get_yaml_value "package_name")"
    ["package_version"]="$(get_yaml_value "package_version")"
    ["package_description"]="$(get_yaml_value "package_description")"
    ["project_name"]="$(get_yaml_value "project_name")"
    ["project_url"]="$(get_yaml_value "project_url")"
    ["project_domain"]="$(get_yaml_value "project_domain")"
)

# Function to replace placeholders in a file
replace_placeholders() {
    local file=$1
    if [ -f "$file" ]; then
        local temp_file="${file}.tmp"
        cp "$file" "$temp_file"
        
        for key in "${!REPLACEMENTS[@]}"; do
            local value=${REPLACEMENTS[$key]}
            if [[ "$file" == *".jinja" ]]; then
                # For .jinja files, use {!{ }!} format
                sed -i.bak "s/{!{ ${key} }!}/${value}/g" "$temp_file"
            else
                # For non-jinja files, use {{ }} format
                sed -i.bak "s/{{ ${key} }}/${value}/g" "$temp_file"
            fi
        done
        
        mv "$temp_file" "$file"
        rm -f "${temp_file}.bak"
        echo -e "${GREEN}✓ Updated${NC} $file"
    else
        echo -e "${RED}✗ File not found:${NC} $file"
    fi
}

# Process files
echo -e "\n${YELLOW}Processing files...${NC}"
for pattern in "${PATTERNS[@]}"; do
    # Handle both direct file paths and patterns
    if [[ "$pattern" == *"*"* ]]; then
        # It's a pattern, use find
        while IFS= read -r file; do
            replace_placeholders "$file"
        done < <(find . -path "./$pattern" -type f 2>/dev/null)
    else
        # It's a direct file path
        replace_placeholders "$pattern"
    fi
done

# Rename placeholder directory
if [ -d "src/placeholder" ]; then
    mv "src/placeholder" "src/${REPLACEMENTS[package_name]}"
    echo -e "${GREEN}✓ Renamed${NC} src/placeholder to src/${REPLACEMENTS[package_name]}"
fi

echo -e "\n${GREEN}Template application completed!${NC}"

# Ask about deletion
echo -e "\n${YELLOW}Would you like to delete the template files? (Y/N)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    rm -f template.yaml
    echo -e "${GREEN}✓ Deleted${NC} template.yaml"
    rm -f "$0"
    echo -e "${GREEN}✓ Deleted${NC} $0"
    echo -e "\n${GREEN}Template files cleaned up. Happy coding!${NC}"
else
    echo -e "\n${YELLOW}Template files kept. You can delete them manually later.${NC}"
fi
