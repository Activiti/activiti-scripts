# activiti-scripts

- [![status](https://github.com/Activiti/activiti-scripts/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/Activiti/activiti-scripts/actions/workflows/pre-commit.yml)
- [![status](https://github.com/Activiti/activiti-scripts/actions/workflows/run-release.yml/badge.svg)](https://github.com/Activiti/activiti-scripts/actions/workflows/run-release.yml)

Activiti Scripts for releasing Activiti Projects.

## CI/CD

Running on GH Actions.

### How to create a new release

1. Switch to the latest `rc` tag and create a branch out of it with the following name pattern `releases/main/<VERSION_TO_BE_RELEASED>`
2. Modify the file activiti-scripts/release.yaml by updating the `version`, the `nextVersion` and the `notesStartTag` fields
3. Commit the changes and push the branch `releases/main/<VERSION_TO_BE_RELEASED>`

- The `CI/CD` will create a staging repository on Alfresco Nexus where the release artifacts will be published to.
- The name of the staging repository can be found in the file `maven-config/staging-repository.txt`.
- All the alpha versions used to create the release are the ones listed in the file `release.yaml`.
  It's safe to restart to build from where it failed in case of failure. However, if you need to restart
  from scratch you need to delete the artifacts already pushed to the staging repository first.

## Formatting

The local `.editorconfig` file is leveraged for automated formatting.

See documentation at [pre-commit](https://github.com/Alfresco/alfresco-build-tools/tree/master/docs#pre-commit).

To run all hooks locally:

```sh
pre-commit run -a
```
