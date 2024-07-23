#!/bin/bash

OWNER='lithesheeli'

# Get GitLab members
GITLAB_MEMBERS=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/projects/$PROJECT_ID/members")

# Loop through members and add to GitHub
echo "${GITLAB_MEMBERS}" | jq -r '.[] | @base64' | while read row; do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    USERNAME=$(_jq '.username')
    PERMISSION="push" # Map GitLab role to GitHub permission as needed

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
