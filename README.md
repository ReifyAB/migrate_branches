# migrate_branches

Small bash script to quickly migrate branches on github.

By using the github REST API, the script will list all the repos that are still using the old branch name and rename it for each of them.

It was written to ease migration from master to main branch.

By doing it that way, it will also make sure that:

- default branch is updated
- users get a notice on the repo about the name change
- github pages setup are updated if based on the old branch name

# usage

```bash
GITHUB_TOKEN=xxxx \
OWNER=Jell \
OWNER_TYPE=user \
SOURCE_BRANCH=master \
TARGET_BRANCH=main \
./migrate_branches.sh
```
