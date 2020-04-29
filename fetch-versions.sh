#!/usr/bin/env bash

writeVersionOnFile() {
  local pom_path=$1
  local destination_file=$2
  local current_dependency=$3
  local related_repository=$4
  echo -n "$related_repository " >>"$destination_file"
  version=$(grep -v "Downloading" <"$pom_path" | grep "$current_dependency.version" | grep -om1 "7.[0-9]*.[0-9]*")
  echo "$version" >>"$destination_file"

  # check for the existence of such version for current project
  if [ "$(curl -s -o /dev/null -w "%{http_code}" https://github.com/Activiti/"$related_repository"/releases/tag/v"$version")" != "200" ]; then
    echo "No tag $version was found for project $related_repository"
    echo "Script interrupted due to non existent version" >>"$destination_file"
    exit 1
  fi
}

parseVersions() {
  local pom_path=$1
  local property_pattern=$2
  local destination_file=$3
  local name_dependency_aggregator=$4

  if [ "$name_dependency_aggregator" == "activiti-cloud-application" ]; then
    for current_dependency in $(cat $pom_path | grep -v "Downloading" | grep $property_pattern | grep "version" | grep "7." | cut -d'<' -f 2 | cut -d'.' -f 1); do
      if [ "$current_dependency" == "activiti-cloud-build" ]; then
        writeVersionOnFile "$pom_path" "$destination_file" "$current_dependency" "activiti-cloud"
      fi
    done
  else
    for current_dependency in $(cat $pom_path | grep -v "Downloading" | grep $property_pattern | grep "version" | grep "7." | cut -d'<' -f 2 | cut -d'.' -f 1); do
      writeVersionOnFile "$pom_path" "$destination_file" "$current_dependency" "$current_dependency"
    done
  fi
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
modeling_app_file=repos-activiti-cloud-modeling-app.txt

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

# name and version of the projects in this aggregator
parseVersions "activiti-cloud-dependencies/pom.xml" "activiti" $activiti_cloud_file "$name_dependency_aggregator"

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
modeling_app_tags=$(curl -s https://api.github.com/repos/Activiti/activiti-modeling-app/tags | grep name | head -n10)
echo "Latest tags for modeling app:"
echo "$modeling_app_tags"
modeling_app_version=$(echo "$modeling_app_tags" | cut -d'v' -f 2 | cut -d'"' -f 1 | head -n1)
if [ -z "$modeling_app_version" ]; then
  echo "Error: Unable to delect latest tag for modeling app."
  exit 1
fi

echo -n "activiti-modeling-app " >>"$modeling_app_file"
echo "$modeling_app_version" >>"$modeling_app_file"

activiti_core_version=$(mvn dependency:tree | grep "activiti-dependencies:pom:" -m1 | grep -o "7\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,5\}")

echo -n "Activiti " >>"${activiti_core_file}"
echo "${activiti_core_version}" >>"${activiti_core_file}"

echo -n "$name_dependency_aggregator " >>${activiti_cloud_application_file}
echo "$version_dependency_aggregator" >>${activiti_cloud_application_file}

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
