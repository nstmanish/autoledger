function createORG() {

    ORG=$1
    FABRIC_CA_SERVER_PORT=$2

    infoln "Enrolling the CA admin"
    mkdir -p organizations/peerOrganizations/${ORG}.example.com/

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${ORG}.example.com/

    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:${FABRIC_CA_SERVER_PORT} --caname ca-${ORG} --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    echo "NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-${FABRIC_CA_SERVER_PORT}-ca-${ORG}.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-${FABRIC_CA_SERVER_PORT}-ca-${ORG}.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-${FABRIC_CA_SERVER_PORT}-ca-${ORG}.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-${FABRIC_CA_SERVER_PORT}-ca-${ORG}.pem
        OrganizationalUnitIdentifier: orderer" >${PWD}/organizations/peerOrganizations/${ORG}.example.com/msp/config.yaml

    infoln "Registering peer0"
    set -x
    fabric-ca-client register --caname ca-${ORG} --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering user"
    set -x
    fabric-ca-client register --caname ca-${ORG} --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering the org admin"
    set -x
    fabric-ca-client register --caname ca-${ORG} --id.name ${ORG}admin --id.secret ${ORG}adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Generating the peer0 msp"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:${FABRIC_CA_SERVER_PORT} --caname ca-${ORG} -M ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/msp --csr.hosts peer0.${ORG}.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/msp/config.yaml

    infoln "Generating the peer0-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:${FABRIC_CA_SERVER_PORT} --caname ca-${ORG} -M ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls --enrollment.profile tls --csr.hosts peer0.${ORG}.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/ca.crt
    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/server.crt
    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/server.key

    mkdir -p ${PWD}/organizations/peerOrganizations/${ORG}.example.com/msp/tlscacerts
    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/${ORG}.example.com/msp/tlscacerts/ca.crt

    mkdir -p ${PWD}/organizations/peerOrganizations/${ORG}.example.com/tlsca
    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/${ORG}.example.com/tlsca/tlsca.${ORG}.example.com-cert.pem

    mkdir -p ${PWD}/organizations/peerOrganizations/${ORG}.example.com/ca
    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/peers/peer0.${ORG}.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/${ORG}.example.com/ca/ca.${ORG}.example.com-cert.pem

    infoln "Generating the user msp"
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@localhost:${FABRIC_CA_SERVER_PORT} --caname ca-${ORG} -M ${PWD}/organizations/peerOrganizations/${ORG}.example.com/users/User1@${ORG}.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/${ORG}.example.com/users/User1@${ORG}.example.com/msp/config.yaml

    infoln "Generating the org admin msp"
    set -x
    fabric-ca-client enroll -u https://${ORG}admin:${ORG}adminpw@localhost:${FABRIC_CA_SERVER_PORT} --caname ca-${ORG} -M ${PWD}/organizations/peerOrganizations/${ORG}.example.com/users/Admin@${ORG}.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/peerOrganizations/${ORG}.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/${ORG}.example.com/users/Admin@${ORG}.example.com/msp/config.yaml
}

function createOrderer() {
    ORDERER=$1
    PORT=$2

    infoln "Enrolling the CA admin"
    mkdir -p organizations/ordererOrganizations/${ORDERER}.example.com

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com

    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:${PORT} --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
    { set +x; } 2>/dev/null

    echo "NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-${PORT}-ca-orderer.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-${PORT}-ca-orderer.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-${PORT}-ca-orderer.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-${PORT}-ca-orderer.pem
        OrganizationalUnitIdentifier: orderer" >${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/msp/config.yaml

    infoln "Registering orderer"
    set -x
    fabric-ca-client register --caname ca-orderer --id.name ${ORDERER} --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering the orderer admin"
    set -x
    fabric-ca-client register --caname ca-orderer --id.name ${ORDERER}Admin --id.secret ${ORDERER}Adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Generating the orderer msp"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}:ordererpw@localhost:${PORT} --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/msp --csr.hosts ${ORDERER}.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/msp/config.yaml

    infoln "Generating the orderer-tls certificates"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}:ordererpw@localhost:${PORT} --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts ${ORDERER}.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/ca.crt
    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/server.crt
    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/server.key

    mkdir -p ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/msp/tlscacerts
    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    mkdir -p ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/msp/tlscacerts
    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    infoln "Generating the admin msp"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}Admin:${ORDERER}Adminpw@localhost:${PORT} --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/${ORDERER}.example.com/users/Admin@example.com/msp/config.yaml
}
