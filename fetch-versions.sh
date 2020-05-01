#!/usr/bin/env bash

writeVersionOnFile() {
  local destination_file=$1
  local version=$2
  local related_repository=$3

  echo "${related_repository}: ${version}"
  echo -n "$related_repository " >>"$destination_file"
  echo "$version" >>"$destination_file"

  # check for the existence of such version for current project
  if [ "$(curl -s -o /dev/null -w "%{http_code}" https://github.com/Activiti/"$related_repository"/releases/tag/v"$version")" != "200" ]; then
    echo "No tag $version was found for project $related_repository"
    echo "Script interrupted due to non existent version" >>"$destination_file"
    exit 1
  fi
}

parseActivitiCloudVersion() {
  local pom_path="activiti-cloud-dependencies/pom.xml"
  local property_pattern="activiti-cloud\.version"

  local activiti_cloud_version=$(grep "activiti-cloud\.version" <"$pom_path" -m1 | grep -om1 "${activiti_version_pattern}")
  writeVersionOnFile "$activiti_cloud_file" "$activiti_cloud_version" "activiti-cloud"

  local cloud_api_url="https://raw.githubusercontent.com/Activiti/activiti-cloud/v${activiti_cloud_version}/activiti-cloud-api/pom.xml"
  echo "Getting Activiti core version from: ${cloud_api_url} "
  local activiti_core_version=$(curl https://raw.githubusercontent.com/Activiti/activiti-cloud/v${activiti_cloud_version}/activiti-cloud-api/pom.xml \
    | grep "activiti\.version" -m1 | grep -o "${activiti_version_pattern}")
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
activiti_version_pattern="7\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,6\}"

mkdir /tmp/release-versions && cd /tmp/release-versions || exit 1
git clone -q https://github.com/Activiti/$name_dependency_aggregator.git && cd $name_dependency_aggregator || exit 1

activiti_core_file=repos-activiti.txt
activiti_cloud_file=repos-activiti-cloud.txt
activiti_cloud_application_file=repos-activiti-cloud-application.txt
modeling_app_file=repos-activiti-modeling-app.txt

echo "Handling $name_dependency_aggregator"
git fetch --tags

tag_to_fetch="$1"

if [ -n "${tag_to_fetch}" ]; then
  # adding 'v' to tag to align it with the format of internal versions: 'v7.1.68'
  for k in $(git tag --list 'v*' | cut -d'v' -f 2); do
    if [ "$k" = "${tag_to_fetch}" ]; then
      exist=1
      break
    else
      exist=0
    fi
  done

  if [ "$exist" -eq 1 ]; then
    git checkout -q tags/v"${tag_to_fetch}"
    version_dependency_aggregator=${tag_to_fetch}
  else
    echo "The provided version '${tag_to_fetch}' does not exist"
    cd ../..
    rm -rf release-versions
    exit 1
  fi

else
  # if no second argument is provided, we get the latest tag
  latest_tag=$(git tag --sort=-creatordate | head -n 1)

  if [[ ${latest_tag::1} == "v" ]]; then
    aggregator_tag=$(git tag --sort=-creatordate | head -n 1)
  else
    aggregator_tag=$(git tag --sort=-creatordate | head -n 2 | grep "v")
  fi

  git checkout -q tags/"$aggregator_tag"
  version_dependency_aggregator=$(echo "$aggregator_tag" | cut -d'v' -f 2)
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

# addition of modeling front end project
modeling_app_tags=$(curl -s https://api.github.com/repos/Activiti/activiti-modeling-app/tags | grep name | head -n3)
echo "Latest tags for modeling app:"
echo "$modeling_app_tags"
modeling_app_version=$(echo "$modeling_app_tags" | cut -d'v' -f 2 | cut -d'"' -f 1 | head -n1)
if [ -z "$modeling_app_version" ]; then
  echo "Error: Unable to detect latest tag for modeling app."
  exit 1
fi

writeVersionOnFile "$modeling_app_file" "$modeling_app_version" "activiti-modeling-app"

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
