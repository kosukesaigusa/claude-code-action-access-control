#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize
AUTHORIZED="false"
ACTOR="${GITHUB_ACTOR}"
REPO="${GITHUB_REPOSITORY}"

# Helper function for logging
log() {
    echo -e "$1"
}

# Check if user is in allowed users list
check_allowed_users() {
    if [[ -z "$ALLOWED_USERS" ]]; then
        return 1
    fi
    
    # Parse newline-separated format (same as experimental_allowed_domains)
    while IFS= read -r user; do
        # Trim whitespace
        user=$(echo "$user" | xargs)
        
        # Skip empty lines
        if [[ -z "$user" ]]; then
            continue
        fi
        
        # Exact match only for security
        if [[ "$user" == "$ACTOR" ]]; then
            log "${GREEN}✅ User @$ACTOR is in allowed users list${NC}"
            return 0
        fi
    done <<< "$ALLOWED_USERS"
    
    return 1
}

# Check if user is in allowed teams
check_allowed_teams() {
    if [[ -z "$ALLOWED_TEAMS" || -z "$GITHUB_TOKEN" ]]; then
        return 1
    fi
    
    # Parse newline-separated format (same as experimental_allowed_domains)
    while IFS= read -r team; do
        team=$(echo "$team" | xargs)
        
        # Skip empty lines
        if [[ -z "$team" ]]; then
            continue
        fi
        
        # Parse org/team format
        if [[ "$team" =~ ^([^/]+)/(.+)$ ]]; then
            org="${BASH_REMATCH[1]}"
            team_slug="${BASH_REMATCH[2]}"
            
            # Check team membership via GitHub API
            response=$(curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/orgs/$org/teams/$team_slug/memberships/$ACTOR")
            
            if [[ "$response" == "200" ]]; then
                log "${GREEN}✅ User @$ACTOR is a member of team $org/$team_slug${NC}"
                return 0
            fi
        fi
    done <<< "$ALLOWED_TEAMS"
    
    return 1
}

# Check if user is an organization member
check_org_member() {
    if [[ "$ALLOW_ORG_MEMBERS" != "true" || -z "$GITHUB_TOKEN" ]]; then
        return 1
    fi
    
    # Extract org from repository (org/repo format)
    if [[ "$REPO" =~ ^([^/]+)/ ]]; then
        org="${BASH_REMATCH[1]}"
        
        # Check org membership via GitHub API
        response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/orgs/$org/members/$ACTOR")
        
        if [[ "$response" == "204" ]]; then
            log "${GREEN}✅ User @$ACTOR is a member of organization $org${NC}"
            return 0
        fi
    fi
    
    return 1
}

# Main logic
log "${YELLOW}🔐 Checking permissions for @$ACTOR...${NC}"

# Check each permission type
if check_allowed_users; then
    AUTHORIZED="true"
elif check_allowed_teams; then
    AUTHORIZED="true"
elif check_org_member; then
    AUTHORIZED="true"
else
    log "${RED}❌ User @$ACTOR is not authorized to use Claude${NC}"
    
    # List what would grant access (helpful for debugging)
    echo "To grant access, you can:"
    [[ -n "$ALLOWED_USERS" ]] && echo "  - Add user to allowed_users list"
    [[ -n "$ALLOWED_TEAMS" ]] && echo "  - Add user to one of the allowed teams"
    [[ "$ALLOW_ORG_MEMBERS" == "true" ]] && echo "  - Add user as organization member"
fi

# Export result for next step
if [[ -n "$GITHUB_ENV" ]]; then
    echo "USER_AUTHORIZED=$AUTHORIZED" >> "$GITHUB_ENV"
else
    # For local testing, just export to environment
    export USER_AUTHORIZED="$AUTHORIZED"
fi

# Exit successfully even if not authorized (to prevent workflow failure)
exit 0
