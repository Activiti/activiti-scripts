# activiti-scripts

Activiti Scripts for Building Projects

Includes a script to checkout and build all the Activiti repositories.

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./build-all.sh

will build all the repositories listed in the index files:

* [activiti](./repos-activiti.txt)
* [activiti-cloud](./repos-activiti-cloud.txt)
* [activiti-modeling-app](repos-activiti-modeling-app.txt)
* [activiti-cloud-application](./repos-activiti-cloud-application.txt)

To get the set of versions to be released:

    ./fetch-versions.sh (fetch latest version for all sets)
    ./fetch-versions.sh 7.1.854 (fetch set of versions for all sets based on the provided version of activiti-cloud-application)

To clone all:

    PROJECTS=activiti,activiti-cloud,activiti-cloud-application,activiti-modeling-app ./clone-all.sh

To release non-example projects:

    PROJECTS=activiti,activiti-cloud ./release-all.sh

To include pushing first set:

    export GIT_PUSH=true
    export MAVEN_PUSH=true

To test cloud versions in the txt file are consistent without running tests:

    export CHECK_VERSIONS=true
    export MAVEN_ARGS="clean install -DskipTests"
    PROJECTS=activiti-cloud ./remove-all.sh
    PROJECTS=activiti-cloud ./clone-all.sh
    PROJECTS=activiti-cloud ./build-all.sh

To test that a release can replace the versions with a release version, follow this with:

    export CHECK_VERSIONS=true
    export RELEASE_VERSION=7.0.0.TEST1
    PROJECTS=activiti-cloud ./remove-all.sh
    PROJECTS=activiti-cloud ./clone-all.sh
    PROJECTS=activiti-cloud ./build-all.sh
    PROJECTS=activiti-cloud ./release-all.sh

Nothing should be pushed or released unless PUSH=true is set - see release.sh. Your local SRC_DIR (default to home/src/) will then contain the product.
The text files for the example projects do not require version numbers as for these a tag is created from develop.

To test a whole release, not pushing anything to github or nexus (because PUSH flag is blank) and pushing images to a personal dockerhub (ryandawsonuk):

    export MAVEN_ARGS="clean install -DskipTests"
    export DOCKER_PUSH=true
    export DOCKER_USER=ryandawsonuk
    export RELEASE_VERSION=7.0.0.TEST1
    export CHECK_VERSIONS=true
    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples,activiti-cloud-modeling-examples ./remove-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples,activiti-cloud-modeling-examples ./clone-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples,activiti-cloud-modeling-examples ./build-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples,activiti-cloud-modeling-examples ./release-all.sh
    PROJECTS=activiti-cloud-examples,activiti-cloud-modeling-images ./dockerpush-all.sh

To build all projects from a branch instead of a tag e.g. `7.0.x`, take the versions out of the text files and set

    export BASEBRANCH=7.0.x

If version replacement is needed ot make the branches build then the `build-all` step may need to be removed.

## CI/CD

Running on Travis, requires the following environment variable to be set:

| Name | Description |
|------|-------------|
| CLONE_MODE | Defines if the script should use `HTTPS` or `SSH` while cloning repositories|
| GPG_EXECUTABLE | |
| GPG_PASSPHRASE | |
| GPG_SECRET_KEYS | |
| GPG_OWNERTRUST | |
| DOCKER_REGISTRY | Docker registry to publish images to |
| DOCKER_REGISTRY_USERNAME | Docker registry username |
| DOCKER_REGISTRY_PASSWORD | Docker registry password |
| GITHUB_TOKEN | GitHub token to clone and push |
| GIT_AUTHOR_NAME | |
| GIT_AUTHOR_EMAIL | |
| GIT_COMMITTER_NAME | |
| GIT_COMMITTER_EMAIL | |
| MAVEN_USERNAME | Internal Maven repository username |
| MAVEN_PASSWORD | Internal Maven repository password |
| SRCCLR_API_TOKEN | SourceClear API token |
| TRAVIS_API_TOKEN | token to launch other builds |
| NEXUS_USERNAME | Username to publish artifacts to Nexus |
| NEXUS_PASSWORD | Password to publish artifacts to Nexus |
| NEXUS_PROFILE_ID | Identifier of the staging profile used to create the staging repository for the release |

## How to create a new release
1. Modify the file `VERSION` so that its content is the name of the version to be released
2. Commit this change with a commit message starting with the prefix `[RELEASE] `.
Without this prefix, the release will not start.

- Once the commit is pushed the `CI/CD` will create a new tag with the name informed in the file [VERSION](./VERSION).
- The `CI/CD` will also create a staging repository on Sonatype where the release artifacts will be published to.
- The name of the staging repository can be found in the file `maven-config/staging-repository.txt` on the new created tag.
- All the internal versions used to create the release can be found in the files `repos-*.txt`.
They are fetched from the latest tag available for [activiti-cloud-dependencies](https://github.com/Activiti/activiti-cloud-dependencies/tags).
- Once the new tag is created, the `CI/CD` will run the release from this tag.
It's safe to restart to build from where it failed in case of failure. However, if you need to restart
from scratch you need to delete the artifacts already pushed to the staging repository first.
