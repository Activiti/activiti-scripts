#!/usr/bin/env bash

writeVersionOnFile() {
  local pom_path=$1
  local destination_file=$2
  local current_dependency=$3
  local related_repository=$4
  echo -n "$related_repository " >>"$destination_file"
  version=$(grep -v "Downloading" < "$pom_path" | grep "$current_dependency.version" | grep -om1 "7.[0-9]*.[0-9]*")
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

  if [ "$name_dependency_aggregator" == "activiti-cloud-dependencies" ]; then
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

activiti_core_file=repos-activiti.txt

if [ -n "$1" ]; then
  if [ "$1" = "Activiti" ] || [ "$1" = "activiti-cloud" ] || [ "$1" = "activiti-cloud-dependencies" ]; then
    projects=$1
  else
    echo "Incorrect project name '$1'"
    echo "Choose among: Activiti or activiti-cloud-dependencies"
    echo "Leave blank to update all projects"
  fi
else
  projects=(Activiti activiti-cloud activiti-cloud-dependencies)
fi

for project in "${projects[@]}"; do
  mkdir /tmp/release-versions && cd /tmp/release-versions
  git clone -q https://github.com/Activiti/$project.git && cd $project

  case "$project" in
  'Activiti')
    file=${activiti_core_file}
    ;;
  'activiti-cloud')
    file=repos-activiti-cloud-mono.txt
    ;;
  'activiti-cloud-dependencies')
    file=repos-activiti-cloud.txt
    examples_file=repos-activiti-cloud-examples.txt
    bom_file=repos-activiti-cloud-bom.txt
    modeling_app_file=repos-activiti-cloud-modeling-app.txt
    ;;
  esac

  name_dependency_aggregator=$project
  echo "Handling $name_dependency_aggregator"
  git fetch --tags

  if [ -n "$2" ]; then
    # adding 'v' to tag to align it with the format of internal versions: 'v7.1.68'
    for k in $(git tag --list 'v*' | cut -d'v' -f 2); do
      if [ "$k" = "$2" ]; then
        exist=1
        break
      else
        exist=0
      fi
    done

    if [ "$exist" -eq 1 ]; then
      git checkout -q tags/v$2
      version_dependency_aggregator=$2
    else
      echo "The provided version does not exist"
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

    git checkout -q tags/$aggregator_tag
    version_dependency_aggregator=$(echo $aggregator_tag | cut -d'v' -f 2)
  fi

  # name and version of the projects in this aggregator
  parseVersions pom.xml "activiti" $file "$name_dependency_aggregator"
  if [ -n "$examples_file" ]; then
    parseVersions dependencies-tests/pom.xml "activiti\|example-" $examples_file
  fi

  if [ "$name_dependency_aggregator" == "activiti-cloud-dependencies" ]; then
    # addition of modeling front end project
    modeling_app_version=$(curl -s https://api.github.com/repos/Activiti/activiti-modeling-app/tags | grep name | cut -d'v' -f 2 | cut -d'"' -f 1 | head -n1)
    echo -n "activiti-modeling-app " >>$file
    echo "$modeling_app_version" >>$file

#    write also on repos-activiti-cloud-modeling-app.txt that's used by docker push
    echo -n "activiti-modeling-app " >>"$modeling_app_file"
    echo "$modeling_app_version" >>"$modeling_app_file"

    activiti_core_version=$(mvn dependency:tree | grep "activiti-dependencies:pom:" -m1 | grep -o "7\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,5\}")

    echo -n "Activiti " >>"${activiti_core_file}"
    echo "${activiti_core_version}" >>"${activiti_core_file}"


    echo -n "$name_dependency_aggregator " >>${bom_file}
    echo "$version_dependency_aggregator" >>${bom_file}
  else
    echo -n "$name_dependency_aggregator " >>$file
    echo "$version_dependency_aggregator" >>$file
  fi

  cd ../..
  updateRepoFile "${project}" $file "${original_directory}"
  if [ "$name_dependency_aggregator" == "activiti-cloud-dependencies" ]; then
    updateRepoFile "${project}" ${bom_file} "${original_directory}"
    updateRepoFile "${project}" ${modeling_app_file} "${original_directory}"
    updateRepoFile "${project}" ${activiti_core_file} "${original_directory}"
  fi
  if [ -n "$examples_file" ]; then
    updateRepoFile "${project}" ${examples_file} "${original_directory}"
  fi

  rm -rf release-versions

done
