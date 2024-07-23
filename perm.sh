#!/bin/bash

# GitLab Configuration
GITLAB_TOKEN="your_gitlab_token"
GITLAB_URL="https://gitlab.example.com/api/v4"
PROJECT_ID="your_project_id"

# GitHub Configuration
GITHUB_TOKEN="your_github_token"
GITHUB_URL="https://api.github.com"
REPO_NAME="your_repo_name"
OWNER="your_github_owner"

# Get GitLab members
GITLAB_MEMBERS=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/projects/$PROJECT_ID/members")

# Loop through members and add to GitHub
for row in $(echo "${GITLAB_MEMBERS}" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    USERNAME=$(_jq '.username')
    PERMISSION="push"  # Map GitLab role to GitHub permission as needed

    # Add member to GitHub
    RESPONSE=$(curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$GITHUB_URL/repos/$OWNER/$REPO_NAME/collaborators/$USERNAME" \
        -d "{\"permission\":\"$PERMISSION\"}")

    if [ $? -eq 0 ]; then
        echo "Successfully added $USERNAME to GitHub with $PERMISSION permission"
    else
        echo "Failed to add $USERNAME: $RESPONSE"
    fi
done
