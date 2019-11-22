#!/usr/bin/env bash

original_directory=$(pwd)

if [ ! -z "$1" ]; then
    if [ "$1" = "activiti-dependencies" ] || [ "$1" = "activiti-cloud-dependencies" ] || [ "$1" = "activiti-cloud-modeling-dependencies" ]; then
        projects=$1
    else
        echo "Incorrect project name '$1'"
        echo "Choose among: activiti-dependencies, activiti-cloud-dependencies or activiti-cloud-modeling-dependencies"
        echo "Leave blank to update all projects"
    fi
else
    projects=(activiti-dependencies activiti-cloud-dependencies activiti-cloud-modeling-dependencies)
fi

for i in "${projects[@]}"
do 
    mkdir /tmp/release-versions && cd /tmp/release-versions
    git clone -q https://github.com/Activiti/$i.git  && cd $i

    case "$i" in
    'activiti-dependencies')
        file=repos-activiti.txt
    ;;
    'activiti-cloud-dependencies')
        file=repos-activiti-cloud.txt
        bom_file=repos-activiti-cloud-bom.txt
    ;;
    'activiti-cloud-modeling-dependencies')
        file=repos-activiti-cloud-modeling.txt
    ;;
    esac

    name_dependency_aggregator=$i
    git fetch --tags

    if [ ! -z "$2" ]; then
        # adding 'v' to tag to align it with the format of internal versions: 'v7.1.68'
        for k in $(git tag --list 'v*' | cut -d'v' -f 2)
        do
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

        if [[ ${latest_tag::1} == "v" ]];then
            aggregator_tag=$(git tag --sort=-creatordate | head -n 1)            
        else
            aggregator_tag=$(git tag --sort=-creatordate | head -n 2 | grep "v")
        fi  

        git checkout -q tags/$aggregator_tag
        version_dependency_aggregator=$(echo $aggregator_tag | cut -d'v' -f 2)
    fi

    # name and version of the projects in this aggregator
    for j in $(cat pom.xml | grep -v "Downloading" | grep "activiti" | grep "version" | grep "7." | cut -d'<' -f 2 | cut -d'.' -f 1)
    do
        echo "$j \c" >> $file
        version=$(eval "mvn help:evaluate -B -Dexpression=$j.version | grep '^[^\[]'")
        echo $version >> $file

        # check for the existence of such version for current project
        if [ $(curl -s -o /dev/null -w "%{http_code}" https://github.com/Activiti/$j/releases/tag/v$version) != "200" ];then
            echo "$version version of project $j does not exist"
            echo "Script interrupted due to non existent version" >> $file
            exit 1
        fi
    done

    # addition of modeling front end project
    if [ $name_dependency_aggregator == "activiti-cloud-modeling-dependencies" ]; then
        echo "activiti-modeling-app \c" >> $file
        echo $(curl -s https://api.github.com/repos/Activiti/activiti-modeling-app/tags | grep name | cut -d'v' -f 2 | cut -d'"' -f 1 |  head -n1) >> $file
    fi

    # name and version of the dependency aggregator
    if [ $name_dependency_aggregator == "activiti-cloud-dependencies" ]; then
      echo "$name_dependency_aggregator \c" >> ${bom_file}
      echo $version_dependency_aggregator >> ${bom_file}
    else
      echo "$name_dependency_aggregator \c" >> $file
      echo $version_dependency_aggregator >> $file
    fi

    echo "--------------------------------------------------------------------"
    cat $file
    
    cd ../..
    mv release-versions/$i/$file $original_directory
    if [ $name_dependency_aggregator == "activiti-cloud-dependencies" ]; then
      cat release-versions/$i/${bom_file}
      mv release-versions/$i/${bom_file} $original_directory
    fi
    rm -rf release-versions

done
