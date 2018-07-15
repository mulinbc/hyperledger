#!/bin/sh

printHelp(){
    echo
    echo "Usage: bootstrap.sh [init upnet upexp down]"
    echo "  -------------------------------------------"
    echo "  - init - Initialize system and pull docker."
    echo "  - upnet - Bring up the hyperledger network."
    echo "  - upexp - Bring up the blockchain explorer."
    echo "  - down - Clear the hyperledger environment."
    echo "  ---------------Author: MuLin---------------"
    echo
}

init(){
    # Use mirrors
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
    # Docker pull images
    export VERSION=1.2.0
    export THIRDPARTY_IMAGE_VERSION=0.4.10
    export CA_VERSION=$VERSION
    
    export FABRIC_TAG=$VERSION
    export THIRDPARTY_TAG=$THIRDPARTY_IMAGE_VERSION
    export CA_TAG=$CA_VERSION

    for IMAGES in peer orderer ccenv tools; do
    echo "==> FABRIC IMAGE: $IMAGES"
    docker pull hyperledger/fabric-$IMAGES:$FABRIC_TAG
    docker tag hyperledger/fabric-$IMAGES:$FABRIC_TAG hyperledger/fabric-$IMAGES
    echo
    done

    for IMAGES in couchdb kafka zookeeper; do
    echo "==> THIRDPARTY DOCKER IMAGE: $IMAGES"
    docker pull hyperledger/fabric-$IMAGES:$THIRDPARTY_TAG
    docker tag hyperledger/fabric-$IMAGES:$THIRDPARTY_TAG hyperledger/fabric-$IMAGES
    echo
    done

    echo "==> FABRIC CA IMAGE"
    docker pull hyperledger/fabric-ca:$CA_TAG
    docker tag hyperledger/fabric-ca:$CA_TAG hyperledger/fabric-ca
    echo

    echo "==> Other IMAGE: postgres:alpine"
    docker pull postgres:alpine
    echo

    echo "==> Other IMAGE: hyperledger/composer-playground"
    docker pull hyperledger/composer-playground
    echo
}

upnet(){
    # Run postgres images
    docker run -p 5432:5432 --name postgres -e POSTGRES_PASSWORD=password -d -v ~/hyperledger/blockchain-explorer/app/persistence/postgreSQL/db/explorerpg.sql:/docker-entrypoint-initdb.d/explorerpg.sql -v ~/hyperledger/blockchain-explorer/app/persistence/postgreSQL/db/updatepg.sql:/docker-entrypoint-initdb.d/updatepg.sql postgres:alpine
    # Up fabric network
    cd ~/hyperledger/fabric-samples/first-network
    echo "y" | ./byfn.sh up
    # Run composer images
    docker run --name composer-playground -p 80:8080 -d hyperledger/composer-playground
}

upexp(){
    # Configure and start blockchain explorer
    sed -i "s/fabric-path/\/root\/hyperledger/g" ~/hyperledger/blockchain-explorer/app/platform/fabric/config.json
    cd ~/hyperledger/blockchain-explorer && ./start.sh
}

down(){
    docker rm $(docker stop postgres composer-playground)
    cd ~/hyperledger/fabric-samples/first-network
    echo "y" | ./byfn.sh down
    pkill node
}

MODE=$1
if [ "$MODE" == "init" ]; then
    init
elif [ "$MODE" == "upnet" ]; then
    upnet
elif [ "$MODE" == "upexp" ]; then
    upexp
elif [ "$MODE" == "down" ]; then
    down
else
    printHelp
    exit 1
fi