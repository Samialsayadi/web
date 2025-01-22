#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Add at the start, after the color definitions:
AUTO_YES=false

# Add command line flag options
while getopts "yd" opt; do
    case $opt in
        y) AUTO_YES=true ;;
        d) DRY_RUN=true ;;
    esac
done

# Function to check if yq is installed
check_yq() {
    if ! command -v yq &> /dev/null; then
        echo -e "${YELLOW}The 'yq' command is required (to parse template.yaml) but it's not installed.${NC}"
        echo -e "Would you like to install it? (Y/N)"
        if [ "$AUTO_YES" = false ]; then
            read -r install_response
        else
            install_response="y"
            echo -e "Auto-accepting yq installation"
        fi

        if [[ "$install_response" =~ ^[Yy]$ ]]; then
            if command -v brew &> /dev/null; then
                echo -e "Installing yq via Homebrew..."
                brew install yq
            elif command -v apt-get &> /dev/null; then
                echo -e "Installing yq via apt..."
                sudo apt-get update && sudo apt-get install -y yq
            elif command -v dnf &> /dev/null; then
                echo -e "Installing yq via dnf..."
                sudo dnf install -y yq
            else
                echo -e "${RED}Could not determine package manager. Please install yq manually:${NC}"
                echo -e "https://github.com/mikefarah/yq#install"
                exit 1
            fi
        else
            echo -e "${RED}yq is required for this script. Exiting.${NC}"
            exit 1
        fi
    fi
}

# Check for yq at the start
check_yq

# Function to read YAML values using yq
get_yaml_value() {
    local key=$1
    yq eval ".$key" template.yaml
}

# Function to escape special characters for sed
escape_sed() {
    # Escape special characters but preserve newlines
    echo "$1" | sed -e ':a' -e 'N' -e '$!ba' \
        -e 's/[]\/$*.^[]/\\&/g' \
        -e 's/\n/\\n/g'
}

# Preview template configuration
echo -e "${YELLOW}Template Configuration Preview:${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "📦 Project Details:"
echo -e "   Project Name: $(get_yaml_value "project_name")"
echo -e "   Package Name: $(get_yaml_value "package_name")"
echo -e "   Description: $(get_yaml_value "package_description")"
echo -e "\n👤 Author Details:"
echo -e "   Author: $(get_yaml_value "author")"
echo -e "   GitHub: $(get_yaml_value "github_username")"
echo -e "\n🔗 URLs:"
echo -e "   Repository: $(get_yaml_value "github_repository")"
echo -e "   Project URL: $(get_yaml_value "project_url")"
echo -e "\n ... more in template.yaml"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$AUTO_YES" = false ]; then
    echo -e "\n${YELLOW}Would you like to apply this configuration? (Y/N)${NC}"
    read -r config_response
else
    config_response="y"
    echo -e "\n${YELLOW}Auto-accepting configuration${NC}"
fi

if [[ ! "$config_response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Template application cancelled.${NC}"
    exit 1
fi

echo -e "\n${GREEN}Proceeding with template application...${NC}"

# Define the patterns to search for files
PATTERNS=(
    "pyproject.toml"
    "SECURITY.md"
    "LICENSE"
    "CONTRIBUTING.md"
    "src/config.py"
    "src/app.py"
    "src/static/robots.txt"
    "src/templates/*.jinja"
    "src/templates/components/*.jinja"
    "src/placeholder/__init__.py"
    "src/**/*.py"
    "src/*.py"
    "example_README.md"
)

# Read all values from template.yaml using yq and escape them
declare -A REPLACEMENTS

# First, get all the keys
mapfile -t keys < <(yq eval 'keys | .[]' template.yaml)

for key in "${keys[@]}"; do
    # Skip comments and empty lines
    if [[ "$key" =~ ^#.*$ ]] || [ -z "$key" ]; then
        continue
    fi
    
    # Get the value for this key
    value=$(yq eval ".$key" template.yaml)
    
    if [ ! -z "$value" ]; then
        REPLACEMENTS["$key"]="$(escape_sed "$value")"
    fi
done

# Function to replace placeholders in a file
replace_placeholders() {
    local file=$1
    if [ -f "$file" ]; then
        local temp_file="${file}.tmp"
        cp "$file" "$temp_file"
        
        for key in "${!REPLACEMENTS[@]}"; do
            local value=${REPLACEMENTS[$key]}
            
            if [[ "$file" == *.jinja ]]; then
                # For .jinja files, use {!{ }!} format with # as delimiter
                perl -pi -e "s#{!{ ${key} }!}#${value}#g" "$temp_file"
            else
                # For non-jinja files, use {{ }} format with # as delimiter
                perl -pi -e "s#{{ ${key} }}#${value}#g" "$temp_file"
            fi
        done

        # Additional processing for Python files
        if [[ "$file" == *.py ]]; then
            perl -pi -e "s#from placeholder\.#from ${REPLACEMENTS[package_name]}.#g" "$temp_file"
            perl -pi -e "s#import placeholder#import ${REPLACEMENTS[package_name]}#g" "$temp_file"
        fi
        
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

# Prompt for README swap with preview
if [ -f "example_README.md" ]; then
    echo -e "\n${YELLOW}Preview of README swap operation:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "📄 README.md → README.old.md"
    echo -e "📄 example_README.md → README.md"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ "$AUTO_YES" = false ]; then
        echo -e "\n${YELLOW}Would you like to use the template's README instead of the project's README? (Y/N)${NC}"
        read -r readme_response
    else
        readme_response="y"
        echo -e "\n${YELLOW}Auto-accepting README swap${NC}"
    fi
    
    if [[ "$readme_response" =~ ^[Yy]$ ]]; then
        mv README.md README.old.md
        mv example_README.md README.md
        echo -e "${GREEN}✓ Swapped${NC} README files (original backed up as README.old.md)"
    else
        echo -e "${YELLOW}Keeping original README.md${NC}"
    fi
fi

echo -e "\n${GREEN}Template application completed!${NC}"

# Show preview of files to be deleted/renamed
echo -e "\n${YELLOW}Preview of cleanup operations:${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "template.yaml" ]; then
    echo -e "🗑️  template.yaml"
fi
echo -e "🗑️  $0"
if [ -f "README.md.bak" ]; then
    echo -e "🗑️  README.md.bak"
fi
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$AUTO_YES" = false ]; then
    echo -e "\n${YELLOW}Would you like to proceed with cleanup? (Y/N)${NC}"
    read -r response
else
    response="y"
    echo -e "\n${YELLOW}Auto-accepting cleanup${NC}"
fi

if [[ "$response" =~ ^[Yy]$ ]]; then
    rm -f template.yaml
    echo -e "${GREEN}✓ Deleted${NC} template.yaml"
    if [ -f "README.md.bak" ]; then
        rm -f README.md.bak
        echo -e "${GREEN}✓ Deleted${NC} README.md.bak"
    fi
    rm -f "$0"
    echo -e "${GREEN}✓ Deleted${NC} $0"
    echo -e "\n${GREEN}Template files cleaned up.${NC}"
else
    echo -e "\n${YELLOW}Template files kept. You can delete them manually later.${NC}"
fi

# Define common strings
VENV_CREATE_CMD="python3 -m venv venv"
VENV_ACTIVATE_WIN="venv\\Scripts\\activate"
VENV_ACTIVATE_UNIX="source venv/bin/activate"
START_APP_CMD="cd src && python3 -m uvicorn app:app --host 0.0.0.0 --port 8000"

echo -e "\n${YELLOW}Preview of development environment setup:${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "📁 Create: venv/"
if [ -f "requirements.txt" ]; then
    echo -e "📦 Install: requirements from requirements.txt"
fi
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo -e "🔧 Activate: $VENV_ACTIVATE_WIN"
else
    echo -e "🔧 Activate: $VENV_ACTIVATE_UNIX"
fi
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$AUTO_YES" = false ]; then
    echo -e "\n${YELLOW}Would you like to set up the development environment now? (Y/N)${NC}"
    read -r setup_response
else
    setup_response="y"
    echo -e "\n${YELLOW}Auto-accepting development environment setup${NC}"
fi

if [[ "$setup_response" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
    
    # Set activation script path based on OS
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        ACTIVATE_SCRIPT="venv/Scripts/activate"
        echo -e "${YELLOW}Activating virtual environment (Windows)...${NC}"
    else
        ACTIVATE_SCRIPT="venv/bin/activate"
        echo -e "${YELLOW}Activating virtual environment (Unix)...${NC}"
    fi

    # Function to check if venv is activated
    check_venv() {
        if [ -n "$VIRTUAL_ENV" ]; then
            return 0
        else
            return 1
        fi
    }

    # Try to activate venv with timeout
    MAX_ATTEMPTS=10
    ATTEMPT=1
    while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
        if [ -f "$ACTIVATE_SCRIPT" ]; then
            source "$ACTIVATE_SCRIPT"
            if check_venv; then
                echo -e "${GREEN}✓ Virtual environment activated${NC}"
                break
            fi
        fi
        echo -e "${YELLOW}Waiting for virtual environment to be ready (attempt $ATTEMPT/$MAX_ATTEMPTS)...${NC}"
        ATTEMPT=$((ATTEMPT + 1))
        sleep 1
    done

    if ! check_venv; then
        echo -e "${RED}✗ Could not activate virtual environment${NC}"
        echo -e "${YELLOW}Please activate it manually after the script finishes${NC}"
    fi
    
    if [ -f "requirements.txt" ]; then
        if check_venv; then
            echo -e "\n${YELLOW}Installing requirements...${NC}"
            pip install -r requirements.txt
            echo -e "${GREEN}✓ Dependencies installed${NC}"
        else
            echo -e "${RED}✗ Skipping requirements installation (virtual environment not active)${NC}"
        fi
    fi
    
    echo -e "\n${GREEN}Development environment is ready!${NC}"
    echo -e "\n${YELLOW}To activate the environment:${NC}"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -e "$VENV_ACTIVATE_WIN"
    else
        echo -e "$VENV_ACTIVATE_UNIX"
    fi
    echo -e "\n${YELLOW}To start the application:${NC}"
    echo -e "$START_APP_CMD"
else
    echo -e "\n${YELLOW}To set up the development environment later:${NC}"
    echo -e "1. Create and activate a virtual environment:"
    echo -e "   $VENV_CREATE_CMD"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -e "   $VENV_ACTIVATE_WIN  # On Windows"
    else
        echo -e "   $VENV_ACTIVATE_UNIX  # On Unix-like systems"
    fi
    echo -e "\n2. Install the requirements:"
    echo -e "   pip install -r requirements.txt"
    echo -e "\n3. Start the application:"
    echo -e "   $START_APP_CMD"
fi

echo -e "\n${GREEN}Happy coding!${NC}"