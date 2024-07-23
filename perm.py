import requests

# GitLab Configuration
GITLAB_TOKEN = 'your_gitlab_token'
GITLAB_URL = 'https://gitlab.example.com/api/v4'
PROJECT_ID = 'your_project_id'

# GitHub Configuration
GITHUB_TOKEN = 'your_github_token'
GITHUB_URL = 'https://api.github.com'
REPO_NAME = 'your_repo_name'
OWNER = 'your_github_owner'

# Get GitLab members
gitlab_headers = {'PRIVATE-TOKEN': GITLAB_TOKEN}
gitlab_members_url = f'{GITLAB_URL}/projects/{PROJECT_ID}/members'
gitlab_members = requests.get(gitlab_members_url, headers=gitlab_headers).json()

# Add members to GitHub
github_headers = {
    'Authorization': f'token {GITHUB_TOKEN}',
    'Accept': 'application/vnd.github.v3+json'
}

for member in gitlab_members:
    username = member['username']
    permission = 'push'  # Map GitLab role to GitHub permission as needed
    github_url = f'{GITHUB_URL}/repos/{OWNER}/{REPO_NAME}/collaborators/{username}'
    response = requests.put(github_url, headers=github_headers, json={'permission': permission})
    if response.status_code == 201:
        print(f'Successfully added {username} to GitHub with {permission} permission')
    else:
        print(f'Failed to add {username}: {response.json()}')
