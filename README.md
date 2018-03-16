# activiti-scripts
Activiti Scripts for Building Projects

Includes a script to checkout and build all the Activiti repositories.

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./build-all.sh
    
will build all the repositories listed in the index files:

* [activiti](./repos-activiti.txt)
* [activiti-cloud](./repos-activiti.txt)
* [activiti-cloud-examples](./repos-activiti.txt)

To clone all:

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./clone-all.sh

To release:

    PROJECTS=release ./release-all.sh

To include a push first:

    export PUSH=true

To resume a release or use a custom version set the RELEASE_VERSION and NEXT_SNAPSHOT_VERSION
