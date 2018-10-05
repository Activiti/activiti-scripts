# activiti-scripts
Activiti Scripts for Building Projects

Includes a script to checkout and build all the Activiti repositories.

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./build-all.sh

will build all the repositories listed in the index files:

* [activiti](./repos-activiti.txt)
* [activiti-cloud](./repos-activiti-cloud.txt)
* [activiti-cloud-examples](./repos-activiti-examples.txt)

To clone all:

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./clone-all.sh

To release:

    PROJECTS=release ./release-all.sh

To include a push first:

    export PUSH=true

To resume a release set the RELEASE_VERSION. The release job that invokes this is in bamboo.

To test cloud versions in the txt file are consistent without running tests:

    export CHECK_VERSIONS=true
    export MAVEN_ARGS="clean install -DskipTests"
    PROJECTS=activiti-cloud ./remove-all.sh
    PROJECTS=activiti-cloud ./build-all.sh

To test that a release can replace the versions with a release version, follow this with:

    export CHECK_VERSIONS=true
    export RELEASE_VERSION=7.0.0.TEST1
    PROJECTS=activiti-cloud ./remove-all.sh
    PROJECTS=activiti-cloud ./build-all.sh
    PROJECTS=activiti-cloud ./release-all.sh
   
Nothing should be pushed or released unless PUSH=true is set - see release.sh. Your local SRC_DIR (default to home/src/) will then contain the product.

To test a release, building images locally:

    export BRANCH=<RELEASE_TAG_NAME>
    export MAVEN_ARGS="-Pdocker clean install -DskipTests"
    PROJECTS=release ./remove-all.sh
    PROJECTS=release ./clone-all.sh
    PROJECTS=release ./build-all.sh
