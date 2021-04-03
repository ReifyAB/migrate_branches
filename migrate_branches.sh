#!/usr/bin/env bash
set -euo pipefail

function usage {
  echo
  echo "usage:"
  echo
  echo "  OWNER=Jell OWNER_TYPE=user SOURCE_BRANCH=master TARGET_BRANCH=main $0"
  echo
}

case ${OWNER_TYPE:-""} in
  user|org)
  # all good
  ;;
  *)
    usage
    echo "OWNER_TYPE should be set to either user or org"
    exit 1
    ;;
esac

if [[ ${OWNER:-""} == "" ]]
then
  usage
  echo "missing OWNER"
  exit 1
fi

if [[ ${SOURCE_BRANCH:-""} == "" ]]
then
  usage
  echo "missing SOURCE_BRANCH"
  exit 1
fi

if [[ ${TARGET_BRANCH:-""} == "" ]]
then
  usage
  echo "missing TARGET_BRANCH"
  exit 1
fi

function get_repos_at_page {
  # avoid rate limiting
  sleep 0.5
  PAGE="$1"
  curl -fLsS \
       -H 'Accept: application/vnd.github.v3+json' \
       -H "Authorization: token $GITHUB_TOKEN" \
       --get -d "per_page=100&page=${PAGE}" \
       "https://api.github.com/${OWNER_TYPE}s/${OWNER}/repos" \
    | jq -rc
}

function migrate_repos {
  REPOS="$1"

  for REPO in $(echo "$REPOS" | jq -r ".[] | select( .default_branch == \"$SOURCE_BRANCH\") | .full_name")
  do
    # avoid rate limiting
    sleep 0.5
    curl \
      -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/${REPO}/branches/${SOURCE_BRANCH}/rename" \
      -d "{\"new_name\":\"${TARGET_BRANCH}\"}"
  done
}

PAGE=0
while :
do
  PAGE=$((PAGE + 1))
  REPOS=$(get_repos_at_page $PAGE)
  migrate_repos "$REPOS"

  if [[ $REPOS == "[]" ]]
  then
    break
  fi
done
