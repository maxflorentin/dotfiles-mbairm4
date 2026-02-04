#!/bin/bash

# Example: Using KS contexts with JIRA
# This script demonstrates how to use secrets from the current KS context

set -e  # Exit on error

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if ks is installed
if ! command_exists ks; then
    echo "Error: ks is not installed"
    echo "Install with: brew install ks"
    exit 1
fi

# Check if ks-get is available
if ! command_exists ks-get; then
    echo "Error: ks-get script not found"
    echo "Make sure scripts are in your PATH"
    exit 1
fi

# Get current context
echo "Getting secrets from current KS context..."
echo ""

# Retrieve secrets
JIRA_URL=$(ks-get JIRA_URL 2>/dev/null)
JIRA_EMAIL=$(ks-get JIRA_EMAIL 2>/dev/null)
JIRA_TOKEN=$(ks-get JIRA_TOKEN 2>/dev/null)

# Check if all required secrets exist
if [ -z "$JIRA_URL" ] || [ -z "$JIRA_EMAIL" ] || [ -z "$JIRA_TOKEN" ]; then
    echo "Error: Missing required JIRA secrets in current context"
    echo ""
    echo "Required secrets:"
    echo "  - JIRA_URL"
    echo "  - JIRA_EMAIL"
    echo "  - JIRA_TOKEN"
    echo ""
    echo "Add them with:"
    echo "  ks-add JIRA_URL 'https://your-domain.atlassian.net'"
    echo "  ks-add JIRA_EMAIL 'your-email@example.com'"
    echo "  ks-add JIRA_TOKEN 'your-api-token'"
    exit 1
fi

echo "✓ JIRA_URL: $JIRA_URL"
echo "✓ JIRA_EMAIL: $JIRA_EMAIL"
echo "✓ JIRA_TOKEN: [hidden]"
echo ""

# Example: Get JIRA project info
echo "Fetching JIRA projects..."
echo ""

response=$(curl -s \
    -u "${JIRA_EMAIL}:${JIRA_TOKEN}" \
    -H "Accept: application/json" \
    "${JIRA_URL}/rest/api/3/project")

# Check if jq is installed for pretty printing
if command_exists jq; then
    echo "$response" | jq -r '.[] | "  - \(.key): \(.name)"'
else
    echo "$response"
fi

echo ""
echo "✓ Successfully connected to JIRA"
