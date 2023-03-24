# 脚本

为了方便用户使用，WeCross提供了丰富的脚本，脚本位于WeCross跨链路由的根目录下(如：`~/wecross-demo/routers-payment/127.0.0.1-8250-25500/`)，本章节将对这些脚步做详细介绍。

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
bash stop.sh
```

## 构建WeCross脚本

**build_wecross.sh**

生成WeCross跨链路由网络

```bash
Usage:
    -n  <zone id>                   [Required]   set zone ID
    -l  <ip:rpc-port:p2p-port>      [Optional]   "ip:rpc-port:p2p-port" e.g:"127.0.0.1:8250:25500"
    -f  <ip list file>              [Optional]   split by line, every line should be "ip:rpc-port:p2p-port". eg "127.0.0.1:8250:25500"
    -c  <ca dir>                    [Optional]   dir of existing ca
    -o  <output dir>                [Optional]   default <your pwd>
    -z  <generate tar packet>       [Optional]   default no
    -T  <enable test mode>          [Optional]   default no. Enable test resource.
    -h  call for help
e.g
    bash build_wecross.sh -n payment -l 127.0.0.1:8250:25500
    bash build_wecross.sh -n payment -f ipfile
    bash build_wecross.sh -n payment -f ipfile -c ./ca/
```

- **`-n`**：指定跨链分区标识
- **`-l`**：可选，指定生成一个跨链路由，与`-f`二选一，单行，如：`192.168.0.1:8250:25500`
- **`-f`**：可选，指定生成多个跨链路由，与`-l`二选一，多行，**不可有空行**，例如：

```bash
    192.168.0.1:8250:25500
    192.168.0.1:8251:25501
    192.168.0.2:8252:25502
    192.168.0.3:8253:25503
    192.168.0.4:8254:25504 
```

- **`-c`**：可选，指定跨链路由基于某个路径下的ca证书生成
- **`-o`**：可选，指定跨链路由生成目录，默认`wecross/`
- **`-z`**：可选，若设置，则生成跨链路由的压缩包，方便拷贝至其它机器
- **`-T`**：可选，若设置，生成的跨链路由开启测试资源
- **`-h`**：可选，打印Usage

## 添加新接入链脚本

**add_chain.sh**

脚本`add_chain.sh`用于在router中创建特定区块链的连接配置

```bash
Usage:
    -t <type>                           [Required] type of chain: BCOS2.0, GM_BCOS2.0, BCOS3_ECDSA_EVM, BCOS3_GM_EVM, Fabric1.4, Fabric2.0
    -n <name>                           [Required] name of chain
    -d <dir>                            [Optional] generated target_directory, default conf/chains/
    -h                                  [Optional] Help
e.g
    bash add_chain.sh -t BCOS2.0 -n my_bcos_chain
    bash add_chain.sh -t GM_BCOS2.0 -n my_gm_bcos_chain
    bash add_chain.sh -t BCOS3_ECDSA_EVM -n my_bcos3_chain
    bash add_chain.sh -t BCOS3_GM_EVM -n my_gm_bcos3_chain
    bash add_chain.sh -t Fabric1.4 -n my_fabric_chain
    bash add_chain.sh -t Fabric2.0 -n my_fabric_chain

```

- **`-t`**：连接类型，按照插件选择，如BCOS2.0或Fabric1.4
- **`-n`**：连接名，账户名称
- **`-d`**：连接配置目录，默认生成在conf/chains/下

不同的链有不同的操作方法，具体操作请查看（操作后，请重启router，让router重启加载配置）：

- [BCOS3.0 接入配置](../stubs/bcos3.md)
- [BCOS2.0 接入配置](../stubs/bcos.md)
- [Fabric1.4 接入配置](../stubs/fabric.md)

## 系统合约工具脚本

**deploy_system_contract.sh**

`deploy_system_contract.sh`脚本用于部署或者更新代理合约/桥接合约。

帮助信息：

```shell
$ bash deploy_system_contract.sh -h

Usage:
    -c <chain name>                     [Required] chain name
    -u <upgrade>                        [Optional] upgrade proxy/hub contract if proxy/hub contract has been deployed, default deploy proxy/hub contract
    -t <type>                           [Required] type of chain, support: BCOS2.0, GM_BCOS2.0, Fabric1.4, Fabric2.0, BCOS3_ECDSA_EVM, BCOS3_GM_EVM
    -P <proxy contract>                 [Optional] upgrade/deploy operation on proxy contract
    -H <hub contract>                   [Optional] upgrade/deploy operation on hub contract
    -h                                  [Optional] Help
e.g
    bash deploy_system_contract.sh -t BCOS2.0    -c chains/bcos -P
    bash deploy_system_contract.sh -t BCOS2.0    -c chains/bcos -H
    bash deploy_system_contract.sh -t BCOS2.0    -c chains/bcos -u -P
    bash deploy_system_contract.sh -t BCOS2.0    -c chains/bcos -u -H
    bash deploy_system_contract.sh -t BCOS3_ECDSA_EVM    -c chains/bcos3 -P
    bash deploy_system_contract.sh -t BCOS3_ECDSA_EVM    -c chains/bcos3 -H
    bash deploy_system_contract.sh -t BCOS3_ECDSA_EVM    -c chains/bcos3 -u -P
    bash deploy_system_contract.sh -t BCOS3_ECDSA_EVM    -c chains/bcos3 -u -H
    bash deploy_system_contract.sh -t Fabric1.4  -c chains/fabric -P
    bash deploy_system_contract.sh -t Fabric1.4  -c chains/fabric -H
    bash deploy_system_contract.sh -t Fabric1.4  -c chains/fabric -u -P
    bash deploy_system_contract.sh -t Fabric1.4  -c chains/fabric -u -H
    bash deploy_system_contract.sh -t Fabric2.0  -c chains/fabric2 -P
    bash deploy_system_contract.sh -t Fabric2.0  -c chains/fabric2 -H
    bash deploy_system_contract.sh -t Fabric2.0  -c chains/fabric2 -u -P
    bash deploy_system_contract.sh -t Fabric2.0  -c chains/fabric2 -u -H

```

- **`-t`**：操作类型，根据链的类型选择，支持`BCOS3_ECDSA_EVM`、`BCOS3_GM_EVM`、`BCOS2.0`、`GM_BCOS2.0`、`Fabric1.4`五种类型
- **`-c`**：链配置路径，链配置位于`chains`目录下
- **`-u`**：更新合约操作，默认情况下为部署合约操作，只有在合约已经部署时才可以更新
- **`-P`**：操作对象为代理合约
- **`-H`**：操作对象为桥接合约
- **`-h`**：帮助信息

## 创建P2P证书脚本

**create_cert.sh**

创建P2P证书脚本`create_cert.sh`用于创建P2P证书文件。WeCross Router之间通讯需要证书用于认证，只有具有相同`ca.crt`根证书的WeCross Router直接才能建立连接。

可通过-h查看帮助信息：

```bash
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

- **`c`**：生成ca证书，只有生成了ca证书，才能生成节点证书。
- **`C`**：配合`-n`，指定生成节点证书的数量。
- **`D`**：配合`-n`，指定ca证书路径。
- **`d`**：指定输出目录。
- **`n`**：生成节点证书。
- **`t`**：指定`cert.cnf`的路径

## 升级脚本

已经部署的环境需要升级至最新版本时可以使用升级脚本，包括`upgrade_wecross.sh、upgrade_console.sh、upgrade_account_manager.sh`三个工具，分别升级对应服务。
**注意: 升级的版本与部署的版本必须保持兼容，才能够进行升级操作，各个版本之间的兼容性参见[WeCross程序版本](https://wecross.readthedocs.io/zh_CN/latest/docs/version/index.html)对应版本的兼容性章节。**

- **upgrade_wecross.sh**

升级`Router`

```shell
$ bash upgrade_wecross.sh -h

Usage:
    -s <upgrade dir>                    [Optional] the router's upgrade dir
    -d <router dir>                     [Optional] the router's deploy dir
    -h                                  [Optional] Help
e.g
    bash upgrade_wecross.sh -d ~/wecross-demo/router/127.0.0.1-8250-25500/
```

参数:
- `-s`: 待升级的安装包的目录，默认为当前目录
- `-d`: 已部署环境的目录

- **upgrade_console.sh**

升级控制台

```shell
$ bash upgrade_console.sh -h

Usage:
    -s <upgrade dir>                    [Optional] the WeCross Console's upgrade dir
    -d <console's dir>                  [Optional] the WeCross Console's deploy dir
    -h                                  [Optional] Help
e.g
    bash upgrade_console.sh -d ~/wecross-demo/WeCross-Console
```

参数:
- `-s`: 待升级的安装包的目录，默认为当前目录
- `-d`: 已部署环境的目录

- **upgrade_account_manager.sh**

```shell
$ bash upgrade_account_manager.sh -h

升级`Account-Manager`

Usage:
    -s <upgrade dir>                    [Optional] the WeCross Account Manager's upgrade dir
    -d <account manager's dir>          [Optional] the WeCross Account Manager's deploy dir
    -h                                  [Optional] Help
e.g
    bash upgrade_account_manager.sh -d ~/wecross-demo/WeCross-Account-Manager
```

参数:
- `-s`: 待升级的安装包的目录，默认为当前目录
- `-d`: 已部署环境的目录
