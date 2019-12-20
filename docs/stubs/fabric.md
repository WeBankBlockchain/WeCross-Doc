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
export GOPATH=/data/go/
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

### Fabric证书文件拷贝

在fabric链的服务器，执行如下命令。
```
    cd ~
    touch copyFile.sh
```
将下面内容拷贝到```copyFile.sh```。
```
#!/bin/bash

cd ~
if [ ! -d "fabricFile" ]; then
  mkdir fabricFile
fi
rm -f fabricFile/*;
cd fabricFile;
echo "gopath:$GOPATH"
orgUserKeyFile="$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk"
echo "orgUserKeyFile:$orgUserKeyFile"
orgUserKeyFile=`ls  $orgUserKeyFile `
echo "orgUserKeyFile:$orgUserKeyFile"
if [  ! -f "$orgUserKeyFile" ];then
	echo "orgUserKeyFile:$orgUserKeyFile not exist please check!";
	exit;
fi
cp $orgUserKeyFile	./orgUserKeyFile
orgUserCertFile="$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem"
echo "orgUserCertFile:$orgUserCertFile"
if [  ! -f "$orgUserCertFile" ];then
	echo "orgUserCertFile:$orgUserCertFile not exist please check!";
	exit;
fi
cp $orgUserCertFile	./orgUserCertFile
ordererTlsCaFile="$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"
echo "ordererTlsCaFile:$ordererTlsCaFile"
if [  ! -f "$ordererTlsCaFile" ];then
	echo "ordererTlsCaFile:$ordererTlsCaFile not exist please check!";
	exit;
fi
cp $ordererTlsCaFile	./ordererTlsCaFile
peerOrg1CertFile="$GOPATH/src/github.com/hyperledger/fabric-samples/first-network//crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem"
echo "peerOrg1CertFile:$peerOrg1CertFile"
if [  ! -f "$peerOrg1CertFile" ];then
	echo "peerOrg1CertFile:$peerOrg1CertFile not exist please check!";
	exit;
fi
cp $peerOrg1CertFile	./peerOrg1CertFile
peerOrg2CertFile="$GOPATH/src/github.com/hyperledger/fabric-samples/first-network//crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem"
echo "peerOrg2CertFile:$peerOrg2CertFile"

if [  ! -f "$peerOrg2CertFile" ];then
	echo "peerOrg2CertFile:$peerOrg2CertFile not exist please check!";
	exit;
fi
cp $peerOrg2CertFile	./peerOrg2CertFile
echo "all cert files copy successfully"
```

执行如下命令进行参数拷贝

```
    dos2Unix copyFile.sh
    sh copyFile.sh
```

如果证书拷贝成功，```fabricFile```目录下会有如下证书文件目录。
```
[app@VM_105_134_centos ~]$ tree fabricFile/
fabricFile/
├── ordererTlsCaFile
├── orgUserCertFile
├── orgUserKeyFile
├── peerOrg1CertFile
└── peerOrg2CertFile
0 directories, 5 files
```

### Fabric stub证书文件拷贝
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
    mkdir fabric;
    cd stubs/fabric;
    cp stub-sample.toml  stub.toml
```

执行上述命令之后，目录结构变成如下：
```
├── log4j2.xml
├── fabric
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
│   │   └── stub.toml
│   │
│   └── jd
│       └── stub-sample.toml
├── wecross-sample.toml
└── wecross.toml
```

将上一步从fabric链上拷贝的五个证书文件拷贝到```conf/fabric```。拷贝完成后通过```tree conf```命令可以看到如下目录结构：
```
├── log4j2.xml
├── fabric
│   ├── ordererTlsCaFile
│   ├── orgUserCertFile
│   ├── orgUserKeyFile
│   ├── peerOrg1CertFile
│   ├── peerOrg2CertFile
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
│   │   └── stub.toml
│   │
│   └── jd
│       └── stub-sample.toml
├── wecross-sample.toml
└── wecross.toml
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
     orgUserKeyFile = 'classpath:/fabric/orgUserKeyFile'
     orgUserCertFile = 'classpath:/fabric/orgUserCertFile'
     ordererTlsCaFile = 'classpath:/fabric/ordererTlsCaFile'
     ordererAddress = 'grpcs://127.0.0.1:7050'
     
[peers]
    [peers.org1]
        peerTlsCaFile = 'classpath:/fabric/peerOrg1CertFile'
        peerAddress = 'grpcs://127.0.0.1:7051'
    [peers.org2]
         peerTlsCaFile = 'classpath:/fabric/peerOrg2CertFile'
         peerAddress = 'grpcs://127.0.0.1:9051'
           
# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWorldContract'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'mycc'
    chainLanguage = "go"
    peers=['org1','org2']
```
### Fabric stub配置文件修改
将```ordererAddress```和```peerAddress```修改成为实际ip地址。
