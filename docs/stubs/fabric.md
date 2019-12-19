# 接入Fabric

## Fabric环境搭建

## 前置准备工作
#### docker安装
##### centos环境下docker安装
docker安装需要满足内核版本不低于3.10。
###### 卸载旧版本
```
sudo yum remove docker docker-common docker-selinux docker-engine
```
###### 安装依赖
```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

###### 设置yum源
```
sudo  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

###### 安装docker
```
sudo yum install docker-ce
```

###### 启动docker
```
service docker start
```

##### ubuntu环境下docker安装
###### 卸载旧版本
```
sudo apt-get remove docker docker-engine docker-ce docker.io
```

###### 更新apt包索引
```
sudo apt-get update
```

###### 安装HTTPS依赖库
```
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```

###### 添加Docker官方的GPG密钥
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
###### 设置stable存储库
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

###### 更新apt包索引
```
sudo apt-get update
```

###### 安装最新版本的Docker-ce
```
sudo apt-get install -y docker-ce
```

###### 启动docker
```
service docker start
```

#### docker-compose安装
##### 安装docker-compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.18.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

##### 查看docker-compose版本
```
    docker-compose --version
    docker-compose version 1.18.0, build 8dd22a9
```

#### go安装
##### 安装go
```
    wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
    sudo tar zxvf go1.11.5.linux-amd64.tar.gz -C /usr/local
```
#####  环境变量配置
###### 创建文件夹和软链
```
cd ~
mkdir /data/go
ln -s /data/go go
```

###### 修改环境变量

```
sudo vim /etc/profile
```
添加如下内容:
```
export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
export GOPATH=/home/app/go/
export PATH=$PATH:$GOROOT/bin
```

修改完成后,执行如下操作:
```
    source /etc/profile
```

###### 确认go环境安装成功
新增helloworld.go文件，内容如下：
```
    package main
    import "fmt"
    func main() {
    fmt.Println("hello world.")
    }
```

运行helloworld.go文件
```
    go run helloworld.go
```
如果安装和配置成功,将输出:
```
    hello world.
```

#### Fabric链搭建
##### 目录准备
```
    cd ~
    mkdir go/src/github.com/hyperledger -p
    cd go/src/github.com/hyperledger
```
##### 源码下载
```
    git clone -b release-1.4 https://github.com/hyperledger/fabric.git
    git clone -b release-1.4 https://github.com/hyperledger/fabric-samples.git
```
##### 源码编译
```
    cd ~/go/src/github.com/hyperledger/fabric
    make release
```
##### 环境变量修改
sudo vi /etc/profile 新增如下一行
```
    export PATH=$PATH:$GOPATH/src/github.com/hyperledger/fabric/release/linux-amd64/bin
```
修改完成后执行
```
    source /etc/profile
```
##### 节点启动
```
    cd ~/go/src/github.com/hyperledger/fabric-samples/first-network
    ./byfn.sh up
```

##### 验证
执行如下命令，进入容器
```
    sudo docker exec -it cli bash
```
进入操作界面，执行如下命令:
```
    peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
    peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","b","a","1"]}'
    peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
```

## Fabric stub配置
WeCross配置好之后，默认的conf目录结构如下：
```
├── log4j2.xml
├── p2p
│   ├── ca.crt
│   ├── node.crt
│   ├── node.key
│   └── node.nodeid
├── stubs
│   ├── bcos
│   │   └── stub-sample.toml
│   ├── fabric
│   │   └── stub-sample.toml
│   └── jd
│       └── stub-sample.toml
├── wecross-sample.toml
└── wecross.toml
```
假定当前目录在conf，执行如下操作:
```
    cd fabric;
    cp stub-sample.toml  stub.toml
```
查看stub.toml，可以看到文件内容如下：
```
[common]
    stub = 'fabric'
    type = 'FABRIC'

# fabricServices is a list
[fabricServices]
     channelName = 'mychannel'
     orgName = 'Org1'
     mspId = 'Org1MSP'
     orgUserName = 'Admin'
     orgUserKeyFile = 'classpath:/fabric/5895923570c12e5a0ba4ff9a908ed10574b475797b1fa838a4a465d6121b8ddf_sk'
     orgUserCertFile = 'classpath:/fabric/Admin@org1.example.com-cert.pem'
     ordererTlsCaFile = 'classpath:/fabric/tlsca.example.com-cert.pem'
     ordererAddress = 'grpcs://127.0.0.1:7050'
     
[peers]
    [peers.a]
        peerTlsCaFile = 'classpath:/fabric/tlsca.org1.example.com-cert.pem'
        peerAddress = 'grpcs://127.0.0.1:7051'
    [peers.b]
         peerTlsCaFile = 'classpath:/fabric/tlsca.org2.example.com-cert.pem'
         peerAddress = 'grpcs://127.0.0.1:9051'
           
# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWorldContract'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'mycc'
    chainLanguage = "go"
    peers=['a','b']
```

再讲述配置文件配置之前，需要讲述下fabric的交易运行过程：
![fabricExecute](../images/stubs/fabricExecute.png)


```[fabricServices] ```:配置的是fabric的用户证书以及连接的order节点信息。
```channelName```：channel名称，每个Channel之间是相互隔离。
```orgName```：机构名称，使用默认即可。
```mspId```：使用默认即可。
```orgUserName```：机构用户名称，使用默认即可。也可以配置成```User1```，配置不一样会影响```orgUserKeyFile```和```orgUserCertFile```配置。
```orgUserKeyFile```：用户私钥文件，如果```orgUserName```为```Admin```则此文件的源路径为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk```，如果为```User1```，则此文件的源路径为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/*_sk```
```ordererTlsCaFile```：连接的order节点的证书。上述搭链生成的证书路径为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem```。
```orgUserCertFile```：用户私钥文件，如果```orgUserName```为```Admin```则此文件的源路径为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem```，如果为```User1```，则此文件的源路径为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem```
```ordererTlsCaFile```：连接的order节点的证书。上述搭链生成的证书路径为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem```。
```ordererAddress```：连接的order节点的地址，默认将```ordererAddress```中127.0.0.1替换为实际ip地址的即可。


```[peers]```:用于配置背书节点集合信息，包括证书文件和地址。默认将```peerAddress```中127.0.0.1替换为实际ip地址的即可，上述搭链的证书路径分别为```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network//crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem```和```$GOPATH/src/github.com/hyperledger/fabric-samples/first-network//crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem```。

```[[resources]]```:用于配置合约信息

```name```:资源名称，需要唯一。
```type```:类型，默认都是```FABRIC_CONTRACT```。
```chainCodeName```:chainCode名称，由链码初始化时指定。
```chainLanguage```:合约代码的开发语言，当前包括```go```,```node```,```java```；分别代表go，nodejs和java语言。
```peers```: 背书节点列表，必须是```[peers]```的子集。

