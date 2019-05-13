#!/usr/bin/env bash

if [ ! -z "$1" ]; then
    if [ "$1" = "activiti-dependencies" ] || [ "$1" = "activiti-cloud-dependencies" ] || [ "$1" = "activiti-cloud-modeling-dependencies" ]; then
        projects=($1)
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
    mkdir .temp && cd .temp
    git clone -q https://github.com/Activiti/$i.git  && cd $i

    case "$i" in
    'activiti-dependencies')
        file=repos-activiti.txt
    ;;
    'activiti-cloud-dependencies')
        file=repos-activiti-cloud.txt
    ;;
    'activiti-cloud-modeling-dependencies')
        file=repos-activiti-cloud-modeling.txt
    ;;
    esac

    # name and version of the dependency aggregator
    echo -n "$i " >> $file

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
            echo $2 >> $file 
        else
            echo "The provided version does not exist"
            cd ../..
            rm -rf .temp
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
        echo $aggregator_tag | cut -d'v' -f 2 >> $file
    fi

    # name and version of the projects in this aggregator
    for j in $(cat pom.xml | grep -v "Downloading" | grep "activiti" | grep "version" | grep "7." | cut -d'<' -f 2 | cut -d'.' -f 1)
    do
        echo -n "$j " >> $file
        echo $(eval "mvn help:evaluate -Dexpression=$j.version | grep '^[^\[]'") >> $file
    done

    echo "-------------------------------------------"
    cat $file
    
    cd ../..
    mv .temp/$i/$file .
    rm -rf .temp
done