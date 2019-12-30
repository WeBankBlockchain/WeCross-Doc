## 控制台

[控制台](https://github.com/WeBankFinTech/WeCross-Console)是WeCross重要的交互式客户端工具，它通过[WeCross-Java-SDK](./sdk.html)与WeCross 跨链代理建立连接，实现对跨链资源的读写访问请求。控制台拥有丰富的命令，包括获取跨链资源列表，查询资源状态，以及所有的JSON-RPC接口命令。


### 控制台命令

控制台命令可分为两类，普通命令和交互式命令。

#### 普通命令
普通命令由两部分组成，即指令和指令相关的参数：   
- **指令**: 指令是执行的操作命令，包括获取跨链资源列表，查询资源状态指令等，其中部分指令调用JSON-RPC接口，因此与JSON-RPC接口同名。
**使用提示： 指令可以使用tab键补全，并且支持按上下键显示历史输入指令。**
  
- **指令相关的参数**: 指令调用接口需要的参数，指令与参数以及参数与参数之间均用空格分隔。与JSON-RPC接口同名命令的输入参数和获取信息字段的详细解释参考[JSON-RPC API](./api.html)。

#### 交互式命令
WeCross控制台为了方便用户使用，还提供了交互式的使用方式，比如将跨链资源标识赋值给变量，初始化一个类，并用`.command`的方式访问方法。
详见：[交互式命令](#id14)

### 常用命令链接

#### 普通命令

- call(不发交易): [call](#call)
- sendTransaction(发交易)): [sendTransaction](#sendtransaction)

```eval_rst
.. important::
    - `call <#call>`_和 `call <#sendTransaction>`_需要传入返回值类型，多个返回值类型使用逗号分隔，不能有空格。
    - 目前支持的类型包括：Int(整型)，IntArray(整型数组)，String(字符串)，StringArray(字符串数组)。
    - 如果返回值为空，控制台需要传入关键字：Void。
    - 参数列表传入字面量，因此字符串需要用单引号或双引号括起来。
```

#### 交互式命令

- 初始化资源实例: [WeCross.getResource](#wecross-getresource)
- 访问资源UBI接口: [\[resource\].\[command\]](#resource-command)

### 快捷键
- `Ctrl+A`：光标移动到行首
- `Ctrl+E`：光标移动到行尾
- `Ctrl+R`：搜索输入的历史命令
- &uarr;：  向前浏览历史命令
- &darr;：  向后浏览历史命令
- `table`： 自动补全，支持命令、变量名、资源名以及其它固定参数的补全


### 控制台响应
当发起一个控制台命令时，控制台会获取命令执行的结果，并且在终端展示执行结果，执行结果分为2类：
- **正确结果:** 命令返回正确的执行结果，以字符串或是json的形式返回。       
- **错误结果:** 命令返回错误的执行结果，以字符串或是json的形式返回。 
- **状态码:** 控制台的命令调用JSON-RPC接口时，状态码[参考这里](./api.html#rpc)。


### 控制台配置与运行

```eval_rst
.. important::
    前置条件：部署WeCross请参考 `快速部署 <../tutorial/setup.html>`_。
```

#### 获取控制台

可通过脚本`download_console.sh`获取控制台。

```bash
cd ~ && mkdir -p wecross && cd wecross
# 获取控制台
bash <(curl -s https://raw.githubusercontent.com/WeBankFinTech/WeCross-Console/master/scripts/download_console.sh)
```

执行成功后，会生成`WeCross-Console`目录，结构如下：

```bash
├── apps
│   └── wecross-console.jar  # 控制台jar包
├── conf
│   ├── console-sample.xml   # 配置示例文件
│   └── log4j2.xml           # 日志配置文件
├── download_console.sh      # 获取控制台脚本
├── lib                      # 相关依赖的jar包目录
├── logs                     # 日志文件
└── start.sh                 # 启动脚本

```

#### 配置控制台

配置前需要将`console-sample.xml`拷贝成`console.xml`，再配置`console.xml`文件。

控制台唯一需要配置的是所连接的WeCross跨链代理的服务地址，包括IP和端口号。

```xml
<?xml version="1.0" encoding="UTF-8" ?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">

    <bean id="weCrossServers" class="com.webank.wecross.console.common.WeCrossServers">
        <property name="servers">
            <map>
                <!-- 配置需要连接的WeCross跨链代理服务列表 -->
                <entry key="server1" value="127.0.0.1:8250"/>
                <entry key="server2" value="127.0.0.1:8251"/>
            </map>
        </property>
        <!-- 启动控制台默认连接的WeCross跨链代理 -->
        <property name="defaultServer" value="server1"/>
    </bean>

</beans>
```
  **注：**配置中的`key`只能是字母和数字的组合，不能出现其他字符。

#### 启动控制台

在WeCross服务已经开启的情况下，启动控制台：

```bash
cd ~/wecross/WeCross-Console
bash start.sh
# 输出下述信息表明启动成功
=============================================================================================
Welcome to WeCross console(1.0.0-rc1)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.

=============================================================================================
```

### 普通命令

以下所有跨链资源相关命令的执行结果以实际配置为准，此处只是示例。

#### **help**
输入help或者h，查看控制台所有的命令。

```bash
[server1]> help
---------------------------------------------------------------------------------------------
quit                               Quit console.
currentServer                      Show currently connected WeCross server.
listServers                        List all configured WeCross servers.
switch                             Switch to a specific WeCross server.
listLocalResources                 List local resources configured by WeCross server.
listResources                      List all resources including remote resources.
status                             Check if the resource exists.
getData                            Get data from contract.
setData                            Set data for contract.
call                               Call constant method of smart contract.
callInt                            Call constant method of smart contract with int returned.
callIntArray                       Call constant method of smart contract with int array returned.
callString                         Call constant method of smart contract with string returned.
callStringArray                    Call constant method of smart contract with string array returned.
sendTransaction                    Call non-constant method of smart contract.
sendTransactionInt                 Call non-constant method of smart contract with int returned.
sendTransactionIntArray            Call non-constant method of smart contract with int array returned.
sendTransactionString              Call non-constant method of smart contract with string returned.
sendTransactionStringArray         Call non-constant method of smart contract with string array returned.
WeCross.getResource                Init resource by path, and assign it to a custom variable.
[resource].[command]               Equal to command: command [path].

---------------------------------------------------------------------------------------------
```
**注：**                                       
- help显示每条命令的含义是：命令 命令功能描述                   
- 查看具体命令的使用介绍说明，输入命令 -h或\--help查看。例如：   

```bash
[server1]> currentServer -h
---------------------------------------------------------------------------------------------
Show currently connected WeCross server.
Usage: currentServer
---------------------------------------------------------------------------------------------
```
#### **currentServer**
显示当前连接的WeCross跨链代理。

```bash
[server1]> currentServer
[server1, 127.0.0.1:8250]
```

#### **listServers**
显示所有已配置的WeCross跨链代理。

```bash
[server1]> listServers
{server1=127.0.0.1:8250, server2=127.0.0.1:8251}
```

#### **switch**
根据`key`切换连接的WeCross跨链代理。

```bash
[server1]> switch server2
[server2]>
```
**注：** 需要切换的WeCross跨链代理，请确保已在`dist/conf`目录下的`console.xml`进行了配置，并且节点ip和端口正确，服务正常运行。


#### **listLocalResources**
查看WeCross跨链代理本地配置的跨链资源。

```bash
[server1]> listLocalResources
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
            checksum='0x320a7e701e655cb67a3d1a5283d6083cbe228b080503d4b791fa060bf7f7d926',
            type='BCOS_CONTRACT',
            distance=0,
            path='payment.bcos.HelloWeCross'
        },
    ]
}
```

#### **listResources**
查看WeCross跨链代理本地配置的跨链资源和所有的远程资源。

```bash
[server1]> listResources
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
            checksum='0xdcb8e609e025c8e091d18fe18b8d66d34836bd3051a08ce615118d27e4a29ebe',
            type='REMOTE_RESOURCE',
            distance=1,
            path='payment.bcos.HelloWorld'
        },
        WeCrossResource{
            checksum='0xdcb8e609e025c8e091d18fe18b8d66d34836bd3051a08ce615118d27e4a29ebe',
            type='REMOTE_RESOURCE',
            distance=1,
            path='payment.bcos1.HelloWorld'
        }
    ]
}
```

#### **status**
查看跨链资源的状态，即是否存在于连接的WeCross跨链代理中。

参数：     
- IPath：跨链资源标识。    

```bash
[server1]> status payment.bcos.HelloWeCross
Result ==> exists
```
#### **getData**
预留接口，根据`key`查询`value`，目前没有链支持。

参数：   
- IPath：跨链资源标识。   
- key：字符串。      

```bash
[server1]> getData payment.bcos.HelloWeCross "number"
StatusAndValue{
    errorCode=101,
    errorMessage='Not supported by BCOS_CONTRACT',
    value='null'
}
```

#### **setData**
预留接口，根据`key`更新`value`，目前没有链支持。

参数：   
- IPath：跨链资源标识。   
- key：字符串。 
- value：字符串。

```bash
[server1]> setData payment.bcos.HelloWeCross "message" "haha"
StatusAndValue{
    errorCode=101,
    errorMessage='Not supported by BCOS_CONTRACT',
    value='null'
}
```

#### **call**
调用智能合约的方法，不涉及状态的更改，不发交易。

参数：   
- IPath：跨链资源标识。   
- retTypes：返回值类型列表。
- method：合约方法名。
- args：参数列表。

```bash
[server1]> call payment.bcos.HelloWeCross Int,String getNumAndMsg
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        2019,
        Hello WeCross
    ]
}
```

#### **callInt**
`call`的衍生命令，返回值为整型。

参数：   
- IPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callInt payment.bcos.HelloWeCross getNumber
CallResult{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=2019
}
```

#### **callIntArray**
`call`的衍生命令，返回值为整型数组。

参数：   
- IPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callIntArray payment.bcos.HelloWeCross getNumbers
CallResult{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        1,
        2,
        3
    ]
}
```

#### **callString**
`call`的衍生命令，返回值为字符串。

参数：   
- IPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> call payment.bcos.HelloWeCross String getMessage
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello WeCross
    ]
}
```

#### **callStringArray**
`call`的衍生命令，返回值为字符串数组。

参数：   
- IPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callStringArray payment.bcos.HelloWeCross getMessages
CallResult{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Bei Bei,
        Jing Jing,
        Huan Huan,
        Ying Ying
    ]
}
```

#### **sendTransaction**
调用智能合约的方法，会更改链上状态，需要发交易。

参数：   
- IPath：跨链资源标识。 
- retTypes：返回值类型列表。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransaction payment.bcos.HelloWeCross Int,String setNumAndMsg 2020 "Hello World"
Receipt{
    errorCode=0,
    errorMessage='null',
    hash='0xa1c4ff31e21e97bbaf06ee228f7e84753f3da51ac6b33ffd326100d9a2a40307',
    result=[
        2020,
        Hello World
    ]
}
```

#### **sendTransactionInt**
`sendTransactionInt`的衍生命令，返回值为整型。

参数：   
- IPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionInt payment.bcos.HelloWeCross setNumber 2019
CallResult{
    errorCode=0,
    errorMessage='null',
    hash='0x9847777b33130b0c4f0cbbc8491890bad437e0e5f6e87366b1f8dcd2b0761535',
    result=2019
}
```

#### **sendTransactionIntArray**
`sendTransactionIntArray`的衍生命令，返回值为整型数组。

参数：   
- IPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionIntArray payment.bcos.HelloWeCross getNumbers
CallResult{
    errorCode=0,
    errorMessage='null',
    hash='0x7ee8b8b9c553c0be0b8c3d649eb0c0525604bb3ab6de4d50b002edc891faec2a',
    result=[
        1,
        2,
        3
    ]
}
```

#### **sendTransactionString**
`sendTransactionString`的衍生命令，返回值为字符串。

参数：   
- IPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionString payment.bcos.HelloWeCross setMessage "Xi Xi"
CallResult{
    errorCode=0,
    errorMessage='null',
    hash='0x7ff89e4c4ec4d5af600e4548a49452d2bb2a21ae881a346b1623375ece12cbb6',
    result=Xi Xi
}
```

#### **sendTransactionStringArray**
`sendTransactionStringArray`的衍生命令，返回值为字符串数组。

参数：   
- IPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionStringArray payment.bcos.HelloWeCross getMessages
CallResult{
    errorCode=0,
    errorMessage='null',
    hash='0x22416a793263bc52bde28f1eb8850678824d74bf09a3322a923ca0351b271304',
    result=[
        Bei Bei,
        Jing Jing,
        Huan Huan,
        Ying Ying
    ]
}
```

### 交互式命令

#### **WeCross.getResource**
WeCross控制台提供了一个资源类，通过方法`getResource`来初始化一个跨链资源实例，并且赋值给一个变量。
这样调用同一个跨链资源的不同UBI接口时，不再需要每次都输入跨链资源标识。

```bash
# myResource 是自定义的变量名
[server1]> myResource = WeCross.getResource payment.bcos.HelloWeCross
Result ==> {"path":"payment.bcos.HelloWeCross","weCrossRPC":{"weCrossService":{"server":"127.0.0.1:8250"}}}

# 还可以将跨链资源标识赋值给变量，通过变量名来初始化一个跨链资源实例
[server1]> path = payment.bcos.HelloWorldContract
Result ==> "payment.bcos.HelloWorldContract"

[server1]> myResource = WeCross.getResource path
Result ==> {"path":"payment.bcos.HelloWorldContract","weCrossRPC":{"weCrossService":{"server":"127.0.0.1:8250"}}}
```

#### **[resource].[command]**
当初始化一个跨链资源实例后，就可以通过`.command`的方式，调用跨链资源的UBI接口。

```bash
# 输入变量名，通过table键可以看到能够访问的所有命令
[server1]> myResource.
myResource.call                         myResource.callStringArray
myResource.status                       myResource.sendTransaction
myResource.callInt                      myResource.sendTransactionInt
myResource.getData                      myResource.sendTransactionString
myResource.setData                      myResource.sendTransactionIntArray
myResource.callString                   myResource.sendTransactionStringArray
myResource.callIntArray

# 查看状态
[server1]> myResource.status
payment.bcoschain.HelloWorldContract : exists

# getData
[server1]> myResource.getData "name"
StatusAndValue{
    errorCode=101,
    errorMessage='Not supported by BCOS_CONTRACT',
    value='null'
}

# setData
[server1]> myResource.setData "name" "dou dou"
Status{
    errorCode=101,
    errorMessage='Not supported by BCOS_CONTRACT'
}

# call
[server1]> myResource.call Int,IntArray,String,StringArray getAll
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        2019,
        [
            1,
            2,
            3
        ],
        Xi Xi,
        [
            Bei Bei,
            Jing Jing,
            Huan Huan,
            Ying Ying
        ]
    ]
}

# sendTransaction
[server1]> myResource.sendTransaction Int,String setNumAndMsg 100 "Ha Ha"
Receipt{
    errorCode=0,
    errorMessage='null',
    hash='0x8a9dac589c269c837262c30b5a81dcccbdd7d823cb20621a5ce7f1e9174e4dac',
    result=[
        100,
        Ha Ha
    ]
}

[server1]> myResource.call Int,String getNumAndMsg
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        100,
        Ha Ha
    ]
}
```