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

- Maven artifacts are published to the existing `activiti-staging` repositories in Nexus and Cloudsmith. After the existing sanity checks, both Maven groups are promoted to `activiti-releases` in both services.
- All the alpha versions used to create the release are the ones listed in the file `release.yaml`.
  It's safe to restart to build from where it failed in case of failure. However, if you need to restart
  from scratch you need to delete the artifacts already pushed to the staging repository first.

### Cloudsmith rollout prerequisites

This workflow is the second phase of AAE-55031. Keep its PR in draft until the shared `alfresco-build-tools` changes are reviewed and the Cloudsmith infrastructure prerequisites are applied. The workflow pins the shared implementation commit for review; update that pin to the approved release commit before merging if it changes.

- Set the GitHub Actions repository variable `CLOUDSMITH_NAMESPACE=hyland`. The namespace is the organization slug in the existing `https://maven.cloudsmith.io/hyland/...` upload URLs.
- The OIDC identity is `activiti-activiti-scripts`, including when this workflow checks out Activiti and Activiti Cloud. It needs Write on both `activiti-staging` and `activiti-releases`, and permission to move and replace its own staged packages. The Terraform configuration owns these grants; CI does not need repository Admin.
- `cloudsmith-auth` exports the short-lived `CLOUDSMITH_USERNAME` and `CLOUDSMITH_API_KEY` values. The settings server id is `cloudsmith`. No static Cloudsmith secret is needed; keep the existing Nexus, GPG and GitHub bot secrets.
- Both Maven releases use Maven 3.10.0 and Deploy Plugin 3.x alternative-repository syntax. A source tag is created only after both staging uploads succeed. Maven continues reading staged dependencies from Nexus during this phase.
- Promotion waits for all listed Maven packages to finish synchronizing and become downloadable. Failed or quarantined packages block it, and a missing release cannot silently succeed. Mock releases upload to staging and skip promotion in both services.
- GitHub release creation waits for both promotion destinations. A partial promotion can be rerun; existing source tags skip their already completed staging uploads. A source tag that predates dual publishing needs a separate backfill before it can be promoted in Cloudsmith.

Use a new release version and ensure the release branch contains this reviewed workflow. A branch created from an older `rc` tag will still use that tag's workflow unless these changes are included. Before wider rollout, compare all Maven coordinates and attached files in both services and test an empty-cache consumer after promotion. No production release is started by this PR.

## Formatting

The local `.editorconfig` file is leveraged for automated formatting.

See documentation at [pre-commit](https://github.com/Alfresco/alfresco-build-tools/tree/master/docs#pre-commit).

To run all hooks locally:

```sh
pre-commit run -a
```
