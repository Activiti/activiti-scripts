# activiti-scripts
Activiti Scripts for Building Projects

Includes a script to checkout and build all the Activiti repositories.

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./build-all.sh

will build all the repositories listed in the index files:

* [activiti](./repos-activiti.txt)
* [activiti-cloud](./repos-activiti-cloud.txt)
* [activiti-examples](./repos-activiti-examples.txt)
* [activiti-cloud-examples](./repos-activiti-cloud-examples.txt)

To clone all:

    PROJECTS=activiti,activiti-cloud,activiti-examples,activiti-cloud-examples ./clone-all.sh

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

If cloud is released separately from non-cloud, then cloud can be pointed at a non-cloud release version e.g. 7.0.0.TEST1. Set:

    export EXTRA_SED="'s@<activiti-dependencies.version>.*</activiti-dependencies.version>@<activiti-dependencies.version>7.0.0.TEST1</activiti-dependencies.version>@g'"

Releasing activiti-examples requires the same sed in order to replace the cloud version in the examples.

To release activiti-cloud-examples a sed is also required to set the activiti-cloud-dependencies version in the poms:

    export EXTRA_SED="'s@<activiti-cloud-dependencies.version>.*</activiti-cloud-dependencies.version>@<activiti-cloud-dependencies.version>7.0.0.TEST1</activiti-cloud-dependencies.version>@g'"

There is a similar situation for cloud-modeling, where `cloud-service-common.version` needs to be added to the `sed` and likewise for `modeling-examples`, for which `activiti-cloud-modeling-dependencies` needs to be added.

The text files for the example projects do not require version numbers as for these a tag is created from develop.

To test a whole release, not pushing anything to github or nexus (because PUSH flag is blank) and pushing images to a personal dockerhub (ryandawsonuk):

    export MAVEN_ARGS="clean install -DskipTests"
    export DOCKER_PUSH=true
    export DOCKER_USER=ryandawsonuk
    export RELEASE_VERSION=7.0.0.TEST1
    export CHECK_VERSIONS=true
    export EXTRA_SED="'s@<activiti-dependencies.version>.*</activiti-dependencies.version>@<activiti-dependencies.version>7.0.0.TEST1</activiti-dependencies.version>@g' -e 's@<activiti-cloud-dependencies.version>.*</activiti-cloud-dependencies.version>@<activiti-cloud-dependencies.version>7.0.0.TEST1</activiti-cloud-dependencies.version>@g' -e 's@<activiti-cloud-service-common.version>.*</activiti-cloud-service-common.version>@<activiti-cloud-service-common.version>7.0.0.TEST1</activiti-cloud-service-common.version>@g' -e 's@<activiti-cloud-modeling-dependencies.version>.*</activiti-cloud-modeling-dependencies.version>@<activiti-cloud-modeling-dependencies.version>7.0.0.TEST1</activiti-cloud-modeling-dependencies.version>@g'"
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-examples,activiti-cloud-modeling-examples,activiti-cloud-examples,activiti-cloud-quickstarts ./remove-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-examples,activiti-cloud-modeling-examples,activiti-cloud-examples,activiti-cloud-quickstarts ./clone-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-examples,activiti-cloud-modeling-examples,activiti-cloud-examples,activiti-cloud-quickstarts ./build-all.sh
    PROJECTS=activiti,activiti-cloud,activiti-cloud-modeling,activiti-examples,activiti-cloud-modeling-examples,activiti-cloud-examples,activiti-cloud-quickstarts ./release-all.sh
    PROJECTS=activiti-cloud-examples,activiti-cloud-modeling-examples ./dockerpush-all.sh
