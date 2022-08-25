export PATH=./bin:$PATH

#
#
#
#

function init () {

    docker stop $(docker ps -q)

    cp /dev/null ./docker/dockerComposer/docker-compose-ca.yaml

    cp ./docker/temp/docker-temp.yaml ./docker/dockerComposer/docker-compose-ca.yaml

    # rm -r organizations/*

}

#
#
#
#
function createCA () {
 
    ORG=$1
    FABRIC_CA_SERVER_PORT=$2
    FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=$3

    ./docker/docker-ca.sh $ORG $FABRIC_CA_SERVER_PORT $FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS

}

#
#   script start's From here    
#
#
. utils.sh

COMPOSE_FILE_CA=docker/dockerComposer/docker-compose-ca.yaml

init

read -p "Enter Number Of Org to create: " TOTAL_ORG

for (( i=1; i <= $TOTAL_ORG; i++ )) 
do  
    read -p "Enter Org-$i name: " ORG_NAME[$i]
done  

read -p "Number of Orderer to Create " TOTAL_ORDERER

#
# Creating CA
#

FABRIC_CA_SERVER_PORT=7054

FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=17054



for org in ${ORG_NAME[@]}; 
do
    infoln "Creating CA For Org $org"
    createCA $org $FABRIC_CA_SERVER_PORT $FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS
    FABRIC_CA_SERVER_PORT=$[FABRIC_CA_SERVER_PORT + 1000]
    FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=$[FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS + 1000]
done
createCA orderer $FABRIC_CA_SERVER_PORT $FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS
CA_ORDERER_PORT=$FABRIC_CA_SERVER_PORT

#
# Running CA
#

IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

#
# Register Org
#

FABRIC_CA_SERVER_PORT=7054

. registerEnrole.sh

for org in ${ORG_NAME[@]}; 
do
    infoln "Registering CA For Org $org"
    while :
    do
      if [ ! -f "organizations/fabric-ca/${org}/tls-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done
    createORG $org $FABRIC_CA_SERVER_PORT
    FABRIC_CA_SERVER_PORT=$[FABRIC_CA_SERVER_PORT + 1000]
done

for (( i=1; i <= $TOTAL_ORDERER; i++ )) 
do  
    infoln "Registering Orderer orderer${i}"
    infoln "createOrderer orderer${i} $CA_ORDERER_PORT"
    createOrderer orderer${i} $CA_ORDERER_PORT
done 