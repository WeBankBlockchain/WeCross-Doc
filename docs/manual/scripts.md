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
    -t <type>                           [Required] type of chain, BCOS2.0 or GM_BCOS2.0 or Fabric1.4
    -n <name>                           [Required] name of chain
    -d <dir>                            [Optional] generated target_directory, default conf/stubs/
    -h                                  [Optional] Help
```

- **`-t`**：连接类型，按照插件选择，如BCOS2.0或Fabric1.4
- **`-n`**：连接名，账户名称
- **`-d`**：连接配置目录，默认生成在conf/chains/下

不同的链有不同的操作方法，具体操作请查看（操作后，请重启router，让router重启加载配置）：

- [BCOS2.0 接入配置](../stubs/bcos.md)
- [Fabric1.4 接入配置](../stubs/fabric.md)

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

- **`c`**： 生成ca证书，只有生成了ca证书，才能生成节点证书。
- **`C`**：配合`-n`，指定生成节点证书的数量。
- **`D`**：配合`-n`，指定ca证书路径。
- **`d`**：指定输出目录。
- **`n`**：生成节点证书。
- **`t`**：指定`cert.cnf`的路径
