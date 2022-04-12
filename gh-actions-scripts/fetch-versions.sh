#!/usr/bin/env bash

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

activiti_version_pattern="[0-9]*\.[0-9]*\.[0-9]*\-alpha\.[0-9]*"

mkdir /tmp/release-versions && cd /tmp/release-versions || exit 1
git clone -q https://github.com/Activiti/activiti-cloud-application.git && cd activiti-cloud-application || exit 1

activiti_core_file=repos-activiti.txt
activiti_cloud_file=repos-activiti-cloud.txt
activiti_cloud_application_file=repos-activiti-cloud-application.txt
modeling_app_file=repos-activiti-modeling-app.txt

echo "Handling activiti-cloud-application"
git fetch --tags

tag_to_fetch="$1"
tag_pattern=$activiti_version_pattern
if [ -n "${tag_to_fetch}" ]; then
  for k in $(git tag --list "$tag_pattern"); do
    if [ "$k" = "${tag_to_fetch}" ]; then
      exist=1
      break
    else
      exist=0
    fi
  done

  if [ "$exist" -eq 1 ]; then
    git checkout -q tags/"${tag_to_fetch}"
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

writeRepositoryWithoutVersionOnFile "$modeling_app_file" "activiti-modeling-app"

writeVersionOnFile "${activiti_cloud_application_file}" "${version_dependency_aggregator}" "activiti-cloud-application"

cd ../..

updateRepoFile "activiti-cloud-application" $activiti_cloud_file "${original_directory}"
updateRepoFile "activiti-cloud-application" ${activiti_cloud_application_file} "${original_directory}"
updateRepoFile "activiti-cloud-application" ${modeling_app_file} "${original_directory}"
updateRepoFile "activiti-cloud-application" ${activiti_core_file} "${original_directory}"

rm -rf release-versions
