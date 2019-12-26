# 接入FISCO BCOS

接入FISCO BCOS需要满足底层版本和兼容性版本均不低于v2.2.0。

## FISCO BCOS环境搭建
FISCO BCOS环境搭建参考[部署文档](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html#fisco-bcos)

## FISCO BCOS stub配置
WeCross配置好之后，默认的conf目录结构如下： 
```
├── log4j2.xml
├── p2p
│   ├── ca.crt
│   ├── node.crt
│   ├── node.key
│   └── node.nodeid
├── stubs-sample
│   ├── bcos
│   │   └── stub-sample.toml
│   ├── fabric
│   │   └── stub-sample.toml
├── wecross-sample.toml
└── wecross.toml
```
假定当前目录在conf，执行如下操作:
```
    mkdir -p stubs/bcos;
    cp stubs-sample/bcos/stub-sample.toml  stubs/bcos/stub.toml
```

查看stub.toml，可以看到文件内容如下：

```
[common]
    stub = 'bcos' # stub must be same with directory name
    type = 'BCOS'

[smCrypto]
    # boolean
    enable = false

[account]
    accountFile = 'classpath:/stubs/bcos/0xa1ca07c7ff567183c889e1ad5f4dcd37716831ca.pem'
    password = ''  # if you choose .p12, then password is required


[channelService]
    timeout = 60000  # millisecond
    caCert = 'classpath:/stubs/bcos/ca.crt'
    sslCert = 'classpath:/stubs/bcos/sdk.crt'
    sslKey = 'classpath:/stubs/bcos/sdk.key'
    groupId = 1
    connectionsStr = ['127.0.0.1:20200']

# resources is a list
[[resources]]
    # name must be unique
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x8827cca7f0f38b861b62dae6d711efe92a1e3602'
[[resources]]
    name = 'HelloWorld'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x584ecb848dd84499639fbe2581bfb8a8774b485c'
           
```
```[account]```:发送交易的账户信息。

```accountFile```:发送交易的账户信息,账户产生请参考[账户创建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/manual/account.html)


```[channelService]```:连接的FISCO BCOS的节点信息配置。

```timeout```:连接超时时间，单位毫秒。

```caCert```:链证书，证书和私钥相关的文件是从FISCO BCOS链中拷贝。

```sslCert```:SDK证书，证书和私钥相关的文件是从FISCO BCOS链中拷贝。

```sslKey```:SDK私钥，证书和私钥相关的文件是从FISCO BCOS链中拷贝。

```groupId```:groupId。

```connectionsStr```:连接节点的地址，多个地址使用```,```分隔。


```[[resources]]```： 配置资源相关信息，包括资源名称，类型，合约地址等。

```name```:资源名称，需要唯一。

```type```:类型，默认都是```BCOS_CONTRACT```。

```contractAddress```:合约地址。