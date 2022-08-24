function createCA () {
 
    ORG=$1
   
    FABRIC_CA_SERVER_PORT=$[FABRIC_CA_SERVER_PORT + 1000]

    FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=$[FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS + 1000]

    ./docker/docker-ca.sh $ORG $FABRIC_CA_SERVER_PORT $FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS

}


FABRIC_CA_SERVER_PORT=7054

FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=17054

COMPOSE_FILE_CA=docker/dockerComposer/docker-compose-ca.yaml

cp /dev/null ./docker/dockerComposer/docker-compose-ca.yaml

cp ./docker/temp/docker-temp.yaml ./docker/dockerComposer/docker-compose-ca.yaml

# Script Start's From Here

if [[ $# -lt 1 ]] ; then
    printHelp
    exit 0
else
    MODE=$1
    shift
fi

while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
    -org )
        createCA $2
        shift
        ;;
    * )
        echo "Unknown flag: $key"
        exit 1
        ;;
    esac
    shift
done



# IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

