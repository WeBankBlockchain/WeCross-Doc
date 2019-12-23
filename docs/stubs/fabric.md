# 接入Fabric

## Fabric环境搭建

## 前置准备工作
#### docker安装

docker安装需要满足内核版本不低于3.10。

##### centos环境下docker安装
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

请确保这一步可以正常输出，如果不能正常输出，请检查go的版本以及环境变量配置。

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
    cd stubs/fabric;
    cp stub-sample.toml  stub.toml
```

执行上述命令之后，目录结构变成如下：
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
│   │   └── ordererTlsCaFile
│   │   └── orgUserCertFile
│   │   └── orgUserKeyFile
│   │   └── peerOrg1CertFile
│   │   └── peerOrg2CertFile
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
     orgUserKeyFile = 'classpath:/stub/fabric/orgUserKeyFile'
     orgUserCertFile = 'classpath:/stub/fabric/orgUserCertFile'
     ordererTlsCaFile = 'classpath:/stub/fabric/ordererTlsCaFile'
     ordererAddress = 'grpcs://127.0.0.1:7050'
     
[peers]
    [peers.org1]
        peerTlsCaFile = 'classpath:/stub/fabric/peerOrg1CertFile'
        peerAddress = 'grpcs://127.0.0.1:7051'
    [peers.org2]
         peerTlsCaFile = 'classpath:/stub/fabric/peerOrg2CertFile'
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


### Fabric环境搭建常见问题定位

1.  启动docker提示:```dial unix /var/run/docker.sock: connect: `permission denied````
解决方案：将当前用户加入到docker用户组
```
    sudo gpasswd -a ${USER} docker
```


2 节点启动或者停止过程出现类似```ERROR: for peer0.org2.example.com  container 4cd74d7c81ed915ebee257e1b9d73a0b53dd92447a44f7654aa36563adabbd06: driver "overlay2" failed to remove root filesystem: unlinkat /var/lib/docker/overlay2/14bc15bfac499738c5e4f12083b2e9907f5a304ff234d68d3ba95eef839f4a31/merged: device or resource busy```错误。

解决方案:获得所有和docker相关的进程，找到正在使用的设备号对应的进程，kill掉进程。

```
    grep docker /proc/*/mountinfo | grep 14bc15bfac499738c5e4f12083b2e9907f5a304ff234d68d3ba95eef839f4a31 | awk -F ':' '{print $1}' | awk -F'/' '{print $3}'
```


