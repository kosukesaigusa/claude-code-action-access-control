#!/bin/bash
# Check for updates in the official claude-code-action

set -e

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Checking for updates in official claude-code-action...${NC}"

# Save original directory before creating temp directory
ORIGINAL_DIR="$(pwd)"

# Temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone the official repo (shallow clone for speed)
git clone --depth 1 https://github.com/anthropics/claude-code-action.git official

# Extract inputs from official action.yml
echo -e "\n${YELLOW}📋 Official inputs:${NC}"
yq eval '.inputs | keys' official/action.yml | sort > official-inputs.txt
cat official-inputs.txt

# Extract inputs from our action.yml
echo -e "\n${YELLOW}📋 Our inputs:${NC}"
# Look for action.yml in original directory
OUR_ACTION_FILE="$ORIGINAL_DIR/action.yml"
if [[ ! -f "$OUR_ACTION_FILE" ]]; then
    # Try parent directory (in case script is run from scripts/ dir)
    OUR_ACTION_FILE="$(dirname "$ORIGINAL_DIR")/action.yml"
fi

if [[ ! -f "$OUR_ACTION_FILE" ]]; then
    echo "Error: Cannot find action.yml. Tried:"
    echo "  - $ORIGINAL_DIR/action.yml"
    echo "  - $(dirname "$ORIGINAL_DIR")/action.yml"
    exit 1
fi

echo "Using action.yml at: $OUR_ACTION_FILE"
yq eval '.inputs | keys' "$OUR_ACTION_FILE" | grep -v "allowed_users\|allowed_teams\|allow_org_members" | sort > our-inputs.txt
cat our-inputs.txt

# Find differences
echo -e "\n${YELLOW}🔄 Comparing...${NC}"
if diff -u our-inputs.txt official-inputs.txt > diff.txt; then
    echo -e "${GREEN}✅ No new parameters found! You're up to date.${NC}"
else
    echo -e "${YELLOW}📊 Differences found:${NC}"
    cat diff.txt
    
    # Check if there are actual new parameters (not just comments)
    NEW_PARAMS=$(grep "^+" diff.txt | grep -v "^+++" | grep -v "^+#" | sed 's/^+- //')
    if [[ -n "$NEW_PARAMS" ]]; then
        echo -e "\n${RED}⚠️ New parameters to add:${NC}"
        echo "$NEW_PARAMS"
    else
        echo -e "\n${GREEN}✅ No new parameters to add (only comment differences)${NC}"
    fi
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo -e "\n${YELLOW}📝 To see parameter details, check:${NC}"
echo "https://github.com/anthropics/claude-code-action/blob/main/action.yml"
