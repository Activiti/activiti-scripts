#!/usr/bin/env bash
set -e

# double checks if a tag/version found is available in it's repo
#
# $1 - repository
# $2 - tag/version to check
check_ver_tag_exists_in_repo() {
  local REPO_POM_URL="https://github.com/Activiti/$1/releases/tag/$2"

  if [ "$(curl -s -o /dev/null -w "%{http_code}" $REPO_POM_URL)" != "200" ]; then
    echo "Error: in the repo $1 there is no tag matching or equals to '$2'."
    exit 1
  fi
}

# fetches and print the latest tag committed folliwing a certain pattern
# ex: print_activiti_cloud_applicaton_ver "7.2.0-*"
#
# $1 - pattern
print_activiti_cloud_applicaton_ver() {
  git fetch --tags
  TAG=$(git tag --list "$1" --sort=-creatordate | head -n 1)
  echo $TAG
}

# prints out the activiti-cloud version found in the repository checked out in the current dir
# the repository must be  checked out by an external process (like a github action)
print_activiti_cloud_ver() {
  yq -p=xml e '.project.properties."activiti-cloud.version"' "activiti-cloud-dependencies/pom.xml"
}

# fetches the pom.xml of activiti-cloud and prints the Activiti core version out of it
#
# $1 - activiti cloud version
print_activiti_core_ver() {
  local ACT_CLOUD_API_URL="https://raw.githubusercontent.com/Activiti/activiti-cloud/${1}/activiti-cloud-api/pom.xml"
  local ACT_CLOUD_POM=$(curl -s $ACT_CLOUD_API_URL)
  echo "$ACT_CLOUD_POM" | yq -p=xml e '.project.properties."activiti.version"'
}

usage() {
  APP_NAME=$(basename $0)
cat<<EOF
Usage: $APP_NAME -t <tag-pattern> -p <path-to-repo>

The application fetches the three tags coming from the repos
activiti-cloud-application, activiti-cloud and Activiti eligible to release the
community edition of Activiti Cloud and creates three files contiaining the tags.

It is possible to get the tags using a pattern with wildcards in using the same
notation of the filesystem. See glob(7).

    -t    tag to be fetched or pattern matching the tag
    -p    is where the activiti-cloud-application has been checked out.

Examples:
  $APP_NAME -t "7.3.0-*" -p repo/activiti-cloud-application
  $APP_NAME -t "7.3.0-alpha.*" -p repo/activiti-cloud-application
  $APP_NAME -t "7.3.0-alpha.1" -p repo/activiti-cloud-application
EOF
  exit 1;
}

while getopts ":p:t:" o; do
    case "${o}" in
        p)
            PATH_REPO=${OPTARG}
            echo
            ;;
        t)
            TAG_PATTERN=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${PATH_REPO}" ] || [ -z "${TAG_PATTERN}" ]; then
    usage
fi

# check if the path exists
[ ! -d "$PATH_REPO" ] && echo -e "The path '$PATH_REPO' does not exists or not accessible.\n" && usage

# enter the path
pushd "$PATH_REPO" > /dev/null

# check if the repo downloaded is activiti-cloud-application

ACT_CLOUD_APP_VER=$(print_activiti_cloud_applicaton_ver $TAG_PATTERN)
check_ver_tag_exists_in_repo "activiti-cloud-application" ${ACT_CLOUD_APP_VER:-$TAG_PATTERN}

git checkout -q tags/"$ACT_CLOUD_APP_VER"

ACT_CLOUD_VER=$(print_activiti_cloud_ver)
check_ver_tag_exists_in_repo "activiti-cloud" $ACT_CLOUD_VER

ACT_CORE_VER=$(print_activiti_core_ver $ACT_CLOUD_VER)
check_ver_tag_exists_in_repo "Activiti" $ACT_CORE_VER

echo "activiti-cloud-application-tag=$ACT_CLOUD_APP_VER" >> $GITHUB_OUTPUT
echo "activiti-cloud-tag=$ACT_CLOUD_VER" >> $GITHUB_OUTPUT
echo "activiti-tag=$ACT_CORE_VER" >> $GITHUB_OUTPUT

popd > /dev/null
