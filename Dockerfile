FROM docker:dind

COPY tools/ /usr/local/bin/

ENV HYPERLEDGER_VERSION=1.2.0 GLIBC_VERSION=2.27-r0 DOCKER_COMPOSE_VERSION=1.21.2 ROOT_PASSWORD=root

RUN apk add --no-cache ca-certificates wget curl g++ make nodejs go git bash python findutils openssh && \
    # Configure sshd
    sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
    echo "root:${ROOT_PASSWORD}" | chpasswd && \
    # Configure docker registry mirrors
    mkdir -p /etc/docker && mv /usr/local/bin/daemon.json /etc/docker/ && \
    # Install alpines glibc
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    apk add --no-cache glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk && \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk && \
    # Install docker-compose
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    # Install hyperledger fabric
    mkdir -p ~/hyperledger && cd ~/hyperledger && \
    git clone https://github.com/hyperledger/fabric-samples.git && \
    cd fabric-samples && git checkout v${HYPERLEDGER_VERSION} && \
    cd fabcar && npm install && cd ../.. && \
    wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/linux-amd64-${HYPERLEDGER_VERSION}/hyperledger-fabric-linux-amd64-${HYPERLEDGER_VERSION}.tar.gz && \
    tar -xzvf hyperledger-fabric-linux-amd64-${HYPERLEDGER_VERSION}.tar.gz -C fabric-samples && \
    rm hyperledger-fabric-linux-amd64-${HYPERLEDGER_VERSION}.tar.gz && \
    wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric-ca/hyperledger-fabric-ca/linux-amd64-${HYPERLEDGER_VERSION}/hyperledger-fabric-ca-linux-amd64-${HYPERLEDGER_VERSION}.tar.gz && \
    tar -xzvf hyperledger-fabric-ca-linux-amd64-${HYPERLEDGER_VERSION}.tar.gz -C fabric-samples && \
    rm hyperledger-fabric-ca-linux-amd64-${HYPERLEDGER_VERSION}.tar.gz && \
    # Install blockchain explorer
    cd ~/hyperledger && git clone https://github.com/hyperledger/blockchain-explorer.git && \
    cd ~/hyperledger/blockchain-explorer && npm install && \
    cd ~/hyperledger/blockchain-explorer/app/test && npm install && npm run test && \
    cd ~/hyperledger/blockchain-explorer/client && npm install && npm test -- -u --coverage && npm run build

COPY ssh_host_key/ /etc/ssh/

WORKDIR /root/hyperledger

ENTRYPOINT ["entrypoint.sh"]
