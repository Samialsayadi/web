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

# Function to escape special characters for sed
escape_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g'
}

echo -e "${YELLOW}Starting template application...${NC}"

# Prompt for README swap with preview
if [ -f "example_README.md" ]; then
    echo -e "\n${YELLOW}Preview of README swap operation:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "📄 README.md → README.md.bak"
    echo -e "📄 example_README.md → README.md"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "\n${YELLOW}Would you like to use the template's README instead of the project's README? (Y/N)${NC}"
    read -r readme_response
    if [[ "$readme_response" =~ ^[Yy]$ ]]; then
        mv README.md README.md.bak
        mv example_README.md README.md
        echo -e "${GREEN}✓ Swapped${NC} README files (original backed up as README.md.bak)"
    else
        echo -e "${YELLOW}Keeping original README.md${NC}"
    fi
fi

# Define the patterns to search for files
PATTERNS=(
    "README.md"
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
    "src/routers/*.py"
    "src/**/*.py"
)

# Read values from template.yaml and escape them
declare -A REPLACEMENTS=(
    ["author"]="$(escape_sed "$(get_yaml_value "author")")"
    ["author_email"]="$(escape_sed "$(get_yaml_value "author_email")")"
    ["author_social"]="$(escape_sed "$(get_yaml_value "author_social")")"
    ["author_nickname"]="$(escape_sed "$(get_yaml_value "author_nickname")")"
    ["security_email"]="$(escape_sed "$(get_yaml_value "security_email")")"
    ["github_username"]="$(escape_sed "$(get_yaml_value "github_username")")"
    ["github_repository"]="$(escape_sed "$(get_yaml_value "github_repository")")"
    ["package_name"]="$(escape_sed "$(get_yaml_value "package_name")")"
    ["package_version"]="$(escape_sed "$(get_yaml_value "package_version")")"
    ["package_description"]="$(escape_sed "$(get_yaml_value "package_description")")"
    ["project_name"]="$(escape_sed "$(get_yaml_value "project_name")")"
    ["project_url"]="$(escape_sed "$(get_yaml_value "project_url")")"
    ["project_domain"]="$(escape_sed "$(get_yaml_value "project_domain")")"
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

        # Additional replacement for Python imports if it's a .py file
        if [[ "$file" == *.py ]]; then
            # Replace "from placeholder" with "from package_name"
            sed -i.bak "s/from placeholder\./from ${REPLACEMENTS[package_name]}\./g" "$temp_file"
            # Replace "import placeholder" with "import package_name"
            sed -i.bak "s/import placeholder/import ${REPLACEMENTS[package_name]}/g" "$temp_file"
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

# Ask about deletion
echo -e "\n${YELLOW}Would you like to proceed with cleanup? (Y/N)${NC}"
read -r response
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

echo -e "\n${YELLOW}Would you like to set up the development environment now? (Y/N)${NC}"
read -r setup_response
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