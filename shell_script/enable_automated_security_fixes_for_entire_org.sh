#!/bin/bash
set -e

if [ "$#" -ne "2" ]; then
  echo "Usage: $0 <organization name> <personal access token>"
  echo "Get a personal access token at: https://github.com/settings/tokens"
  exit 1
fi

# make sure jq is installed to parse json response
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: This script requires the 'jq' utility but it's not installed."; exit 1; }

org_name=$1
api_key=$2

repo_url="https://api.github.com/orgs/$org_name/repos"

echo "Getting all repository IDs for org $org_name"
repo_ids=($(curl -s -H "Authorization: bearer $api_key" $repo_url | jq ".[].id"))
echo "Retrieved ${#repo_ids[@]} repo IDs for org $org_name"

for repo_id in ${repo_ids[@]}; do
  echo "Enabling automated security fixes for repository id: $repo_id"
  enable_url="https://api.github.com/repositories/$repo_id/automated-security-fixes"
  curl -s -X PUT -H "Authorization: bearer $api_key" -H "Accept: application/vnd.github.london-preview+json" $enable_url
done
