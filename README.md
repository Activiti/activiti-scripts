# activiti-scripts

[![Build Status](https://travis-ci.com/Activiti/activiti-scripts.svg?branch=master)](https://travis-ci.com/Activiti/activiti-scripts)

Activiti Scripts for Building Projects

Includes a script to checkout and build all the Activiti repositories.

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./build-all.sh

will build all the repositories listed in the index files:

* [activiti](./repos-activiti.txt)
* [activiti-cloud](./repos-activiti-cloud.txt)
* [activiti-cloud-modeling](./repos-activiti-cloud-modeling.txt)
* [activiti-cloud-examples](./repos-activiti-cloud-examples.txt)
* [activiti-cloud-modeling-examples](./repos-activiti-cloud-modeling-examples.txt)

To get the set of versions to be released:

    ./fetch-versions.sh (fetch latest version for all sets)
    ./fetch-versions.sh activiti-dependencies (fetch latest versions for the provided set)
    ./fetch-versions.sh activiti-dependencies 7.1.18 (fetch set of versions for the provided set in the provided version set)
    
To clone all:

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./clone-all.sh

To release non-example projects:

    PROJECTS=activiti,activiti-cloud ./release-all.sh

To include pushing first set:

    export GIT_PUSH=true
    export MAVEN_PUSH=true

To resume a release set the RELEASE_VERSION. The release job that invokes this is in bamboo.

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
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-cloud-examples,activiti-cloud-modeling-examples ./remove-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-cloud-examples,activiti-cloud-modeling-examples ./clone-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-cloud-examples,activiti-cloud-modeling-examples ./build-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-cloud-examples,activiti-cloud-modeling-examples ./release-all.sh
    PROJECTS=activiti-cloud-examples,activiti-cloud-modeling-images ./dockerpush-all.sh

To build all projects from a branch instead of a tag e.g. `7.0.x`, take the versions out of the text files and set

    export BASEBRANCH=7.0.x

If version replacement is needed ot make the branches build then the `build-all` step may need to be removed.

## CI/CD

Running on Travis, requires the following environment variable to be set:

| Name | Description |
|------|-------------|
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
