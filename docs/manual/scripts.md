# 脚本介绍

为了方便用户使用，WeCross提供了丰富的脚本，脚本位于WeCross跨链路由的根目录下，本章节将对这些脚步做详细介绍。

## 启动脚本

**start.sh**

启动脚本`start.sh`用于启动WeCross服务，启动过程中的完整信息记录在start.out中。

```bash
bash start.sh
```

成功输出：
```bash
Wecross start successfully
```

失败输出：
```bash
WeCross start failed 
See logs/error.log for details 
```

## 停止脚本

**stop.sh**

停止脚本`stop.sh`用于停止WeCross服务。

```bash
bash  stop.sh
```

## 构建WeCross脚本

**build_wecross.sh**

生成WeCross跨链路由网络

```
Usage:
    -n  <zone id>                   [Required]   set zone ID
    -l  <ip:rpc-port:p2p-port>      [Optional]   "ip:rpc-port:p2p-port" e.g:"127.0.0.1:8250:25500"
    -f  <ip list file>              [Optional]   split by line, every line should be "ip:rpc-port:p2p-port". eg "127.0.0.1:8250:25500"
    -c  <ca dir>                    [Optional]   dir of existing ca
    -o  <output dir>                [Optional]   default ./${router_output}/
    -z  <generate tar packet>       [Optional]   default no
    -T  <enable test mode>          [Optional]   default no. Enable test resource.
    -h  call for help
e.g
    bash $0 -n payment -l 127.0.0.1:8250:25500
    bash $0 -n payment -f ipfile
```

- **`-n`**：指定跨链分区标识
- **`-l`**：可选，指定生成一个跨链路由，与`-f`二选一，单行，如：`192.168.0.1:8250:25500`
- **`-f`**：可选，指定生成多个跨链路由，与`-l`二选一，多行，**不可有空行**，例如：

    ```
    192.168.0.1:8250:25500
    192.168.0.1:8251:25501
    192.168.0.2:8252:25502
    192.168.0.3:8253:25503
    192.168.0.4:8254:25504 
    ```
* **`-o`**：可选，指定跨链路由生成目录，默认`wecross/`
* **`-z`**：可选，若设置，则生成跨链路由的压缩包，方便拷贝至其它机器
* **`-T`**：可选，若设置，生成的跨链路由开启测试资源
* **`-h`**：可选，打印Usage

## BCOS stub配置脚本

脚本`create_bcos_stub_config.sh`用于快速创建FISCO BCOS stub的配置文件。

可通过-h查看帮助信息：

```
Usage:
    -n  <stub name>       [Required]    specify the name of stub
    -r  <root dir>        [Optional]    specify the stubs root dir, default is stubs
    -c  <conf path>       [Optional]    specify the path of conf dir, default is conf
    -p  <password>        [Optional]    password for p12 a type of FISCO BCOS account, default is null and use pem
    -h  call for help
e.g
    bash create_bcos_stub_config.sh -n bcos
    bash create_bcos_stub_config.sh -n bcos -r stubs
    bash create_bcos_stub_config.sh -n bcos -r stubs -c conf
    bash create_bcos_stub_config.sh -n bcos -r stubs -c conf -p 123456
```

- **`-n`**：指定区块链跨链标识，即stub的名字；同时也会在**`-r`**指定的目录下生成与stub相同名字的目录来保存配置文件。
- **`-r`**： 可选，指定跨链路由的stub配置根目录，默认`stubs/`，需要和根配置文件`wecross.toml`中的`[stubs.path]`保存一致。
- **`-c`**：可选，指定跨链路由的配置根目录，默认为与启动脚本同级的`conf/`目录，所有的配置文件都保存在该路径下。
- **`-p`**：可选，表示使用`p12`格式的账户文件，并指定口令。默认是`pem`格式，无需口令。

例如：
```bash
bash create_bcos_stub_config.sh -n bcos -r stubs -c conf -p 123456
```
执行后，在`conf/stubs/`目录下生成名字为`bcos`的stub目录，之后按照[接入FISCO BCOS的指引进行配置](../stubs/bcos.md)
```bash
tree conf/
conf/
├── stubs
│   └── bcos
│       ├── 0x7dfbec42690e83004687eae5d0e3738750c7c153.pem
│       ├── 0xaa8f54cce575b4cc92f48b6138d6393b2b7d3e86.p12
│       ├── ca.crt
│       ├── node.crt
│       ├── node.key
│       ├── sdk.crt
│       ├── sdk.key
│       └── stub.toml
```

## Fabric stub配置脚本

脚本`create_fabric_stub_config.sh`用于快速创建Fabric stub的配置文件。

可通过`-h`查看帮助信息：

```
Usage:
    -n  <stub name>       [Required]    specify the name of stub
    -r  <root dir>        [Optional]    specify the stubs root dir, default is stubs
    -c  <conf path>       [Optional]    specify the path of conf dir, default is conf
    -h  call for help
e.g
    bash create_fabric_stub_config.sh -n fabric
    bash create_fabric_stub_config.sh -n fabric -r stubs
    bash create_fabric_stub_config.sh -n fabric -r stubs -c conf
```


- **`-n`**：
指定区块链跨链标识，即stub的名字；同时也会生成相同名字的目录来保存配置文件。
- **`-r`**： 
指定配置文件根目录，需要和配置文件`wecross.toml`中的[stubs.path]保存一致。
- **`-c`**：
指定加载配置文件时的`classpath`路径，所有的配置文件都保存在该路径下，默认为与启动脚本同级的`conf`目录。
- **`-h`**：可选，打印Usage


例如：
```bash
bash create_fabric_stub_config -r stubs -o fabric -d conf
```

执行结果的目录结构如下:
```bash
.
├── conf
│   └── stubs
│       └── fabric
│           └── stub.toml
```

<!--

## 创建JDChain stub配置文件脚本

脚本`create_jdchain_stub_config.sh`用于快速创建JDChain stub的配置文件。

可通过-h查看帮助信息：

```
Usage:
    -r  <root dir>        [Required]    specify the stubs root dir
    -o  <stub name>       [Required]    specify the name of stub
    -d  <conf path>       [Required]    specify the path of conf dir
    -h  call for help
e.g
    bash create_jdchain_stub_config.sh -r stubs -o jd -d conf
```

- **`-r`**： 
指定配置文件根目录，需要和配置文件`wecross.toml`中的[stubs.path]保存一致。

- **`-o`**：
指定区块链跨链标识，即stub的名字；同时也会生成相同名字的目录来保存配置文件。
- **`-d`**：
指定加载配置文件时的`classpath`路径，所有的配置文件都保存在该路径下，默认为与启动脚本同级的`conf`目录。
- **`-h`**：可选，打印Usage


例如：
```bash
bash create_jdchain_stub_config.sh -r stubs -o jd -d conf
```

执行结果的目录结构如下:
```bash
├── conf
│   └── stubs
│       └── jd
│           └── stub.toml
```

-->

## 创建P2P证书脚本

**create_cert.sh**

创建P2P证书脚本`create_cert.sh`用于创建P2P证书文件。WeCross Router之间通讯需要证书用于认证，只有具有相同`ca.crt`根证书的WeCross Router直接才能建立连接。

可通过-h查看帮助信息：

```
Usage:
    -c                                  [Optional] generate ca certificate
    -C <number>                         [Optional] the number of node certificate generated, work with '-n' opt, default: 1
    -D <dir>                            [Optional] the ca certificate directory, work with '-n', default: './'
    -d <dir>                            [Required] generated target_directory
    -n                                  [Optional] generate node certificate
    -t                                  [Optional] cert.cnf path, default: cert.cnf
    -h                                  [Optional] Help
e.g
    bash create_cert.sh -c -d ./ca
    bash create_cert.sh -n -D ./ca -d ./ca/node
    bash create_cert.sh -n -D ./ca -d ./ca/node -C 10
```
- **`c`**： 
生成ca证书，只有生成了ca证书，才能生成节点证书。
- **`n`**：
生成节点证书。
- **`C`**：
配合-n，指定生成节点证书的数量。
- **`D`**：
配合-n，指定ca证书路径。
- **`d`**：
指定输出目录。
- **`t`**：
指定`cert.cnf`的路径
