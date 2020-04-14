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
    -p  <enable plugin>             [Optional]   enabled plugins, split by ',', e.g: BCOS2.0,Fabric1.4, default enable all plugins
    -d  <dependencies dir>          [Optional]   dependencies dir, default './deps'
    -h  call for help
e.g
    bash $0 -n payment -l 127.0.0.1:8250:25500
    bash $0 -n payment -f ipfile

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
* **`-p`**：可选，若设置，配置需要启用的插件，可以选择BCOS2.0、Fabric1.4或更多插件，默认是包括所有插件
* **`-p`**：可选，若设置，配置插件所处的路径，避免网络下载的开销，默认是./deps
* **`-h`**：可选，打印Usage

## 账号管理脚本

脚本`generate_account.sh`用于快速创建特定区块链的账号

可通过-h查看帮助信息

```
Usage: 
    -t <type>                           [Required] type of account, BCOS2.0 or Fabric1.4
    -n <name>                           [Required] name of account
    -d <dir>                            [Optional] generated target_directory, default conf/accounts/
    -h                                  [Optional] Help
e.g 
    bash $0 -t BCOS2.0 -n my_bcos_account
    bash $0 -t Fabric1.4 -n my_fabric_account
```

- **`-t`**：账号类型，按照插件选择，如BCOS2.0或Fabric1.4
- **`-n`**：账号名，账号名称
- **`-d`**：账号目录，默认生成在conf/accounts下

例如：
```bash
bash generate_account.sh -t BCOS2.0 -n my_bcos_account
```

执行后，在conf/accounts下生成了my_bcos_account的目录：

```bash
my_bcos_account/
├── account.key
└── account.toml
```

注意，BCOS2.0类型的账号，创建后可以直接使用，Fabric1.4类型仅创建了account.toml配置文件，用户仍需手工生成密钥和证书，放入账号目录中才可使用，详情参考Fabric插件文档。

## 连接管理脚本

脚本`generate_connection.sh`用于快速创建特定区块链的连接

```
Usage: 
    -t <type>                           [Required] type of account, BCOS2.0 or Fabric1.4
    -n <name>                           [Required] name of account
    -d <dir>                            [Optional] generated target_directory, default conf/stubs/
    -h                                  [Optional] Help
e.g 
    bash $0 -t BCOS2.0 -n my_bcos_connection
    bash $0 -t Fabric1.4 -n my_fabric_connection
```

- **`-t`**：连接类型，按照插件选择，如BCOS2.0或Fabric1.4
- **`-n`**：连接名，账号名称
- **`-d`**：连接配置目录，默认生成在conf/stubs/下

例如：
```bash
bash generate_connection.sh -t BCOS2.0 -n my_bcos_connection
```

```bash
my_bcos_connection/
└── stub.toml
```

注意，连接管理脚本仅生成连接的配置模板，具体连接到哪些区块链节点，使用什么证书，仍需用户根据模板手工配置才可使用，详情参考各插件的文档。

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
