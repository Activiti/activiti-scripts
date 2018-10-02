#!/usr/bin/env bash

echo update pom versions to ${NEXT_VERSION}

PROJECTS=${PROJECTS:-activiti}
GIT_PROJECT=$(basename $(pwd))
echo $GIT_PROJECT


SED_REPLACEMENTS=''

POM_VERSION=$(xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" "pom.xml") || true

SED_REPLACEMENTS="${SED_REPLACEMENTS}-e 's@<version>${POM_VERSION}</version>@<version>${NEXT_VERSION}</version>@g'"

PARENT_VERSION=$(xmllint --xpath "//*[local-name()='parent']/*[local-name()='version']/text()" "pom.xml" 2>/dev/null) || true

if [ -z "${PARENT_VERSION}" ];
  then
    SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@<version>${PARENT_VERSION}</version>@<version>${NEXT_VERSION}</version>@g'"
  else
    echo "${REPO} HAS NO PARENT"
fi

COUNTER=0

for PROJECT in ${PROJECTS//,/ }
do
  while read REPO_LINE;
    do REPO_ARRAY=($REPO_LINE)
    REPO=${REPO_ARRAY[0]}

    SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@<${REPO}.version>.*</${REPO}.version>@<${REPO}.version>${NEXT_VERSION}</${REPO}.version>@g'"

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done

echo "PWD IS $(pwd)"

if [[ "$OSTYPE" == "darwin"* ]]
then
  echo "REPLACE ON ${REPO} USING - find . -name pom.xml -exec sed -i.bak ${SED_REPLACEMENTS} {} \;"
  eval "find . -name pom.xml -exec sed -i.bak ${SED_REPLACEMENTS} {} \;"
  find . -name pom.xml.bak -delete
else
  echo "REPLACE ON ${REPO} USING - find . -name pom.xml -exec sed -i ${SED_REPLACEMENTS} {} \;"
  eval "find . -name pom.xml -exec sed -i ${SED_REPLACEMENTS} {} \;"
fi
