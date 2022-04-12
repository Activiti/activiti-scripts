#!/usr/bin/env bash
set -e

writeVersionOnFile() {
  local destination_file=$1
  local version=$2
  local related_repository=$3

  echo "${related_repository}: ${version}"
  echo -n "$related_repository " >>"$destination_file"
  echo "$version" >>"$destination_file"

  # check for the existence of such version for current project
  if [ "$(curl -s -o /dev/null -w "%{http_code}" https://github.com/Activiti/"$related_repository"/releases/tag/"$version")" != "200" ]; then
    echo "No tag $version was found for project $related_repository"
    echo "Script interrupted due to non existent version" >>"$destination_file"
    exit 1
  fi
}

writeRepositoryWithoutVersionOnFile() {
  local destination_file=$1
  local related_repository=$2

  echo "${related_repository}: ${version}"
  echo "$related_repository" >>"$destination_file"
}

parseActivitiCloudVersion() {
  readonly pom_path="activiti-cloud-dependencies/pom.xml"
  readonly activiti_cloud_version=$(yq -p=xml e '.project.properties."activiti-cloud.version"' $pom_path)
  writeVersionOnFile "$activiti_cloud_file" "$activiti_cloud_version" "activiti-cloud"

  local cloud_api_url="https://raw.githubusercontent.com/Activiti/activiti-cloud/${activiti_cloud_version}/activiti-cloud-api/pom.xml"
  echo "Getting Activiti core version from: ${cloud_api_url} "
  readonly ACTIVITI_CLOUD_POM=$(curl "https://raw.githubusercontent.com/Activiti/activiti-cloud/${activiti_cloud_version}/activiti-cloud-api/pom.xml")

  readonly activiti_core_version=$(echo "$ACTIVITI_CLOUD_POM" | yq -p=xml e '.project.properties."activiti.version"')

  writeVersionOnFile "${activiti_core_file}" "${activiti_core_version}" "Activiti"
}

updateRepoFile() {
  local current_dependency=$1
  local file_to_update=$2
  local destination_folder=$3
  echo "--------------------------------------------------------------------"
  cat release-versions/${current_dependency}/${file_to_update}
  mv release-versions/${current_dependency}/${file_to_update} ${destination_folder}
}

original_directory=$(pwd)
name_dependency_aggregator=activiti-cloud-application

mkdir /tmp/release-versions && cd /tmp/release-versions || exit 1
git clone -q https://github.com/Activiti/$name_dependency_aggregator.git && cd $name_dependency_aggregator || exit 1

activiti_core_file=repos-activiti.txt
activiti_cloud_file=repos-activiti-cloud.txt
activiti_cloud_application_file=repos-activiti-cloud-application.txt
modeling_app_file=repos-activiti-modeling-app.txt

echo "Handling $name_dependency_aggregator"
git fetch --tags

tag_to_fetch="$1"
tag_pattern=${tag_pattern:-"[0-9]*\.[0-9]*\.[0-9]*\-alpha\.[0-9]*"}
if [ -n "${tag_to_fetch}" ]; then
  set +e
  git checkout -q tags/"${tag_to_fetch}"
  set -e
  if [ "$?" -eq "0" ]; then
    version_dependency_aggregator=${tag_to_fetch}
  else
    echo "The provided version '${tag_to_fetch}' does not exist"
    cd ../..
    rm -rf release-versions
    exit 1
  fi

else
  # if no second argument is provided, we get the latest tag
  aggregator_tag=$(git tag --list "$tag_pattern" --sort=-creatordate | head -n 1)

  git checkout -q tags/"$aggregator_tag"
  version_dependency_aggregator=$(echo "$aggregator_tag")
fi

parseActivitiCloudVersion $activiti_cloud_file

if [ -n "$SHOULD_INCREMENT_VERSION" ]; then
  ls
  BETA_SUFFIX_PATTERN="\-beta[[:digit:]]\{1,3\}"
  VERSION_PREFIX=$(curl https://raw.githubusercontent.com/Activiti/activiti-cloud-application/develop/pom.xml |
    grep "<version>" | grep "\-SNAPSHOT" | grep -o -m1 "[[:digit:]]\{1,2\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}")
  LATEST_BETA_VERSION=$(git tag --sort=-creatordate | grep -m1 "${VERSION_PATTERN}${BETA_SUFFIX_PATTERN}")
  if [ -z "$LATEST_BETA_VERSION" ]; then
    NEXT_BETA_VERSION="${VERSION_PREFIX}-beta1"
  else
    echo "Latest beta version: ${LATEST_BETA_VERSION}"
    CURRENT_COUNT=$(echo "${LATEST_BETA_VERSION}" | grep -o "${BETA_SUFFIX_PATTERN}" | grep -o "[[:digit:]]\{1,3\}")
    echo "Current count: $CURRENT_COUNT"
    NEXT_BETA_VERSION="${VERSION_PREFIX}-beta$((CURRENT_COUNT + 1))"
  fi
  echo "Next version: $NEXT_BETA_VERSION"
  echo "${NEXT_BETA_VERSION}" >VERSION
fi

writeRepositoryWithoutVersionOnFile "$modeling_app_file" "activiti-modeling-app"

writeVersionOnFile "${activiti_cloud_application_file}" "${version_dependency_aggregator}" "${name_dependency_aggregator}"

cd ../..
updateRepoFile "${name_dependency_aggregator}" $activiti_cloud_file "${original_directory}"
if [ "$name_dependency_aggregator" == "activiti-cloud-application" ]; then
  updateRepoFile "${name_dependency_aggregator}" ${activiti_cloud_application_file} "${original_directory}"
  updateRepoFile "${name_dependency_aggregator}" ${modeling_app_file} "${original_directory}"
  updateRepoFile "${name_dependency_aggregator}" ${activiti_core_file} "${original_directory}"
fi

if [ -n "$SHOULD_INCREMENT_VERSION" ]; then
  updateRepoFile "${name_dependency_aggregator}" "VERSION" "${original_directory}"
fi

rm -rf release-versions
