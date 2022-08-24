#!/bin/bash

function yaml_ccp {
   
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${CAPORT}/$2/g" \
        -e "s#\${CAPORTL}#$3#g" \
        docker/docker-ca-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=$1
CAPORT=$2
CAPORTL=$3

echo "$(yaml_ccp $ORG $CAPORT $CAPORTL )" >> docker/dockerComposer/docker-compose-ca.yaml
