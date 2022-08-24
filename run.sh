function init () {

    cp /dev/null ./docker/dockerComposer/docker-compose-ca.yaml

    cp ./docker/temp/docker-temp.yaml ./docker/dockerComposer/docker-compose-ca.yaml

}

function createCA () {
 
    ORG=$1
   
    FABRIC_CA_SERVER_PORT=$[FABRIC_CA_SERVER_PORT + 1000]

    FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=$[FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS + 1000]

    ./docker/docker-ca.sh $ORG $FABRIC_CA_SERVER_PORT $FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS

}

#
#   script start's From here    
#

FABRIC_CA_SERVER_PORT=7054

FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=17054

COMPOSE_FILE_CA=docker/dockerComposer/docker-compose-ca.yaml

init

read -p "Enter Number Of Org to create: " TOTAL_ORG

for (( i=1; i <= $TOTAL_ORG; i++ )) 
do  
    read -p "Enter Org-$i name: " ORG_NAME[$i]
done  


#
# Creating CA
#

for org in ${ORG_NAME[@]}; do
  echo "Creating CA For Org $org"
  createCA $org
done

#
# Running CA
#

IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

#
# Register Org
#
