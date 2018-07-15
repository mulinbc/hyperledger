# Hyperledger

[![Docker Automated build](https://img.shields.io/docker/automated/mulinbc/hyperledger.svg)][docker url]
[![Docker Build Status](https://img.shields.io/docker/build/mulinbc/hyperledger.svg)][docker url]
[![Docker Pulls](https://img.shields.io/docker/pulls/mulinbc/hyperledger.svg)][docker url]
[![MicroBadger Size](https://img.shields.io/microbadger/image-size/mulinbc/hyperledger.svg)][docker url]
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/mulinbc/hyperledger.svg)][docker url]
![license](https://img.shields.io/github/license/mulinbc/hyperledger.svg)

## 简介

[Hyperledger Fabric]是一个区块链框架的实现，它是Linux基金会托管的Hyperledger项目之一，最初由Digital Asset和IBM贡献。Hyperledger Fabric允许组件即插即用(例如共识和成员服务)，这作为开发具有模块化架构的应用程序或解决方案的基础。Hyperledger Fabric利用容器技术来托管被称为“链代码”的智能合约，其中包含系统的应用程序逻辑。

## 本项目的由来

由于众所周知的网络原因以及Hyperledger Fabric环境配置的复杂性，本项目通过docker in docker技术简化的环境配置，只需要**一步**即可完成环境搭建，只需要**一条**命令就可以构建第一个fabric网络。本项目的docker镜像提供的组件如下：

- [Hyperledger Fabric]
- [Hyperledger Explorer]
- [Hyperledger Composer]
- [OpenSSH]

## 版本说明

- [v0.1.0 - 20180715](https://github.com/mulinbc/hyperledger/blob/master/release_notes/v0.1.0.md)

## 如何使用

1. 准备工作

    ```bash
    docker pull mulinbc/hyperledger # 下载docker镜像文件
    mkdir -p ~/.mulin/hyperledger/var-lib-docker # 创建存放fabric镜像的文件夹
    ```
1. 运行docker镜像

    ```bash
    docker run --privileged -p 22222:22 -p 80:8080 -p 8080:80 --name hyperledger -v ~/.mulin/hyperledger/var-lib-docker:/var/lib/docker -d mulinbc/hyperledger
    # 参数含义
    # --privileged: 以特权模式运行容器
    # -p: 端口映射，22222:22，将本机的22222端口映射到容器的22端口
    # -v: 添加数据卷，/test:/soft，将本机的/test目录挂载到容器的/soft目录
    # -d: 容器在后台运行
    # -e: 指定环境变量，-e ROOT_PASSWORD=password，指定root 用户的密码为password
    # 例如: docker run --privileged -e ROOT_PASSWORD=password -p 22222:22 -p 80:8080 -p 8080:80 --name hyperledger -v ~/.mulin/hyperledger/var-lib-docker:/var/lib/docker -d mulinbc/hyperledger
    ```
1. 进入容器
    - 方法一
    ```bash
    docker exec -it hyperledger sh
    ```
    - 方法二
    ```bash
    ssh -p 22222 root@127.0.0.1 # 默认密码: root
    ```
1. 初始化hyperledger环境
    ```bash
    bootstrap.sh init # 下载必要的fabric镜像
    ```
1. 测试hyperledger环境
    ```bash
    bootstrap.sh upnet # 启动第一个hyperledger网络
    bootstrap.sh upexp # 启动hyperledger区块链浏览器
    ```
    - 区块链浏览器：打开浏览器访问 <http://localhost>
    - Composer：打开浏览器访问 <http://localhost:8080>
1. 关闭hyperledger网络
    ```bash
    bootstrap.sh down # 测试完后需要清除hyperledger网络
    ```

## 注意事项

1. 如遇到fabric网络不能启动，可以先运行`bootstrap.sh down`后重试
1. 如遇到explorer不能访问的情况检查
    - 由于导入数据库需要一段时间，检查postgres容器是否启动完成，运行`docker logs postgres`查看docker容器的日志，如果输出`database system is ready to accept connections`则说明容器启动成功，运行`bootstrap.sh upexp`重试
    - 检查`～/hyperledger/blockchain-explorer/app/platform/fabric/config.json`配置文件中的路径是否正确，配置方法参考<https://github.com/hyperledger/blockchain-explorer#Fabric-Network-Setup>
1. 如有建议或BUG可以创建issue，创建方法参考<https://guides.github.com/features/issues>

## 致谢

- 感谢[sgerrand][alpine glibc]提供的alpine glibc库

### 官方文档：

- [Hyperledger fabric][docFabric]
- [Hyperledger explorer][docExplorer]
- [Hyperledger composer][docComposer]
- [Docker][docComposer]
- [Docker compose][dockerCompose]
- [OpenSSH][docOpenSSH]
- [Alpine glibc library][alpine glibc]

[Hyperledger Fabric]: https://www.hyperledger.org/projects/fabric "Fabric"
[Hyperledger Explorer]: https://www.hyperledger.org/projects/explorer "Explorer"
[Hyperledger Composer]: https://www.hyperledger.org/projects/composer "Composer"
[OpenSSH]: http://www.openssh.com "OpenSSH"
[docker url]: https://hub.docker.com/r/mulinbc/hyperledger "Mu LIN"
[docFabric]: http://hyperledger-fabric.readthedocs.io/en/latest/whatis.html "Fabric document"
[docExplorer]: https://github.com/hyperledger/blockchain-explorer "Explorer document"
[docComposer]: https://hyperledger.github.io/composer/latest/introduction/introduction "Composer document"
[docker]: https://docs.docker.com "Docker"
[dockerCompose]: https://docs.docker.com/compose "Docker-compose"
[docOpenSSH]: http://www.openssh.com/manual.html "OpenSSH document"
[alpine glibc]: https://github.com/sgerrand/alpine-pkg-glibc "Alpine glibc"
