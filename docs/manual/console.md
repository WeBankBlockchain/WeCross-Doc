# 控制台

[控制台](https://github.com/WeBankFinTech/WeCross-Console)是WeCross重要的交互式客户端工具，它通过[WeCross-Java-SDK](./sdk.html)与WeCross 跨链代理建立连接，实现对跨链资源的读写访问请求。控制台拥有丰富的命令，包括获取跨链资源列表，查询资源状态，以及所有的JSON-RPC接口命令。


### 控制台命令
控制台命令由两部分组成，即指令和指令相关的参数：   
- **指令**: 指令是执行的操作命令，包括获取跨链资源列表，查询资源状态指令等，其中部分指令调用JSON-RPC接口，因此与JSON-RPC接口同名。
**使用提示： 指令可以使用tab键补全，并且支持按上下键显示历史输入指令。**
  
- **指令相关的参数**: 指令调用接口需要的参数，指令与参数以及参数与参数之间均用空格分隔。与JSON-RPC接口同名命令的输入参数和获取信息字段的详细解释参考[JSON-RPC API](./api.html)。

### 脚本命令
WeCross控制台为了方便用户使用，还提供了类脚本的使用方式，比如将跨链资源标识赋值给变量，初始化一个类，并用`.command`的方式访问方法。
详见：[脚本模式](#id14)

### 常用命令链接

#### 合约调用命令

- call(不发交易): [call](#call)
- sendTransaction(发交易)): [sendTransaction](#sendTransaction)

#### 脚本命令

- 初始化资源实例: [WeCross.getResource](#WeCross.getResource)
- 访问资源UBI接口: [[resource].[command]](#[resource].[command])

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
  - 控制台的命令调用JSON-RPC接口时，错误码[参考这里](./api.html#rpc)。


## 控制台配置与运行

```eval_rst
.. important::
    前置条件：部署WeCross请参考 `快速部署 <../tutorial/setup.html>`_。
```
### 获取控制台

```bash
cd ~ && mkdir -p WeCross && cd WeCross
# 获取控制台
git clone https://github.com/WeBankFinTech/WeCross-Console.git
cd WeCross-Console
./gradlew assemble
```

编译成功，会生成`dist`目录，结构如下：

```bash
├── apps
│   └── wecross-console.jar  # 控制台jar包
├── conf
│   ├── console-sample.xml   # 配置示例文件
│   └── log4j2.xml           # 日志配置文件
├── lib                      # 相关依赖的jar包目录
├── logs                     # 日志文件
└── start.sh                 # 启动脚本
```

### 配置控制台

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

### 启动控制台

在WeCross服务已经开启的情况下，启动控制台：

```bash
cd dist
bash start.sh
# 输出下述信息表明启动成功
=============================================================================================
Welcome to WeCross console(0.2)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.

=============================================================================================
```

## 控制台命令
### **help**
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
### **currentServer**
显示当前连接的WeCross跨链代理。

```bash
[server1]> currentServer
[server1, 127.0.0.1:8250]
```

### **listServers**
显示所有已配置的WeCross跨链代理。

```bash
[server1]> listServers
{server1=127.0.0.1:8250, server2=127.0.0.1:8251}
```

### **switch**
根据`key`切换连接的WeCross跨链代理。

```bash
[server1]> switch server2
[server2]>
```
**注：** 需要切换的WeCross跨链代理，请确保已在`dist/conf`目录下的`console.xml`进行了配置，并且节点ip和端口正确，服务正常运行。


### **listLocalResources**
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
            path='payment.bcoschain.HelloWorldContract'
        },
        WeCrossResource{
            checksum='0x7644243d71d1b1c154c717075da7bfe2d22bb2a94d7ed7693ab481f6cb11c756',
            type='TEST_RESOURCE',
            distance=0,
            path='test-network.test-stub.test-resource'
        }
    ]
}
```

### **listResources**
查看WeCross跨链代理本地配置的跨链资源和所有的远程资源。

```bash
[server1]> listResources
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
            checksum='0x320a7e701e655cb67a3d1a5283d6083cbe228b080503d4b791fa060bf7f7d926',
            type='BCOS_CONTRACT',
            distance=0,
            path='payment.bcoschain.HelloWorldContract'
        },
        WeCrossResource{
            checksum='0x7644243d71d1b1c154c717075da7bfe2d22bb2a94d7ed7693ab481f6cb11c756',
            type='TEST_RESOURCE',
            distance=0,
            path='test-network.test-stub.test-resource'
        }
    ]
}
```

### **status**
查看跨链资源的状态，即是否存在于连接的WeCross跨链代理中。

参数：     
- CPath：跨链资源标识。    

```bash
[server1]> status payment.bcoschain.HelloWorldContract
Result ==> exists
```
### **getData**
预留接口，根据`key`查询`value`，目前只支持JDChain支持。

参数：   
- CPath：跨链资源标识。   
- key：字符串。      

```bash
[server1]> getData test-network.test-stub.test-resource "test"
StatusAndValue{
    errorCode=0,
    errorMessage='getData test resource success',
    value='com.webank.wecross.restserver.request.GetDataRequest@f160bd7'
}
```

### **setData**
预留接口，根据`key`更新`value`，目前没有链支持。

参数：   
- CPath：跨链资源标识。   
- key：字符串。 
- value：字符串。

```bash
[server1]> setData test-network.test-stub.test-resource "key" "value"
Status{
    errorCode=0,
    errorMessage='setData test resource success'
}
```
### **call**
调用智能合约的方法，不涉及状态的更改，不发交易。

参数：   
- CPath：跨链资源标识。   
- retTypes：返回值类型列表。
- method：合约方法名。
- args：参数列表。

```eval_rst
.. important::
    - `call`和`sendTransaction`需要传入返回值类型，多个返回值类型使用`,`分隔，不能有空格。
    - 目前支持的类型包括：Int(整型)，IntArray(整型数组)，String(字符串)，StringArray(字符串数组)。
    - 如果返回值为空，控制台需要传入关键字：Void。
    - 参数列表传入字面量，因此字符串需要用引号`""`或者`''`括起来。
```

```bash
[server1]> call payment.bcoschain.HelloWorldContract String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello WeCross!
    ]
}
```

### **callInt**
`call`的衍生命令，返回值为整型。

参数：   
- CPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callInt test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='call test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            Int
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **callIntArray**
`call`的衍生命令，返回值为整型数组。

参数：   
- CPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callIntArray test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='call test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            IntArray
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **callString**
`call`的衍生命令，返回值为字符串。

参数：   
- CPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callString test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='call test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            String
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **callStringArray**
`call`的衍生命令，返回值为字符串数组。

参数：   
- CPath：跨链资源标识。   
- method：合约方法名。
- args：参数列表。

```bash
[server1]> callStringArray test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='call test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            StringArray
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **sendTransaction**
调用智能合约的方法，会更改链上状态，需要发交易。

参数：   
- CPath：跨链资源标识。 
- retTypes：返回值类型列表。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransaction payment.bcoschain.HelloWorldContract Void set "Hello"
Receipt{
    errorCode=0,
    errorMessage='null',
    hash='0x4d52132848a21ab8ca49ea543fb72d32bf28b2c924fb6f6c27fac0addba0243b',
    result=[

    ]
}
```

### **sendTransactionInt**
`sendTransactionInt`的衍生命令，返回值为整型。

参数：   
- CPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionInt test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='sendTransaction test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            Int
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **sendTransactionIntArray**
`sendTransactionIntArray`的衍生命令，返回值为整型数组。

参数：   
- CPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionIntArray test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='sendTransaction test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            IntArray
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **sendTransactionString**
`sendTransactionString`的衍生命令，返回值为字符串。

参数：   
- CPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionString test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='sendTransaction test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            String
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

### **sendTransactionStringArray**
`sendTransactionStringArray`的衍生命令，返回值为字符串数组。

参数：   
- CPath：跨链资源标识。  
- method：合约方法名。
- args：参数列表。

```bash
[server1]> sendTransactionStringArray test-network.test-stub.test-resource test "Hello" 123
CallResult{
    errorCode=0,
    errorMessage='sendTransaction test resource success',
    hash='010157f4',
    result={
        sig=,
        retTypes=[
            StringArray
        ],
        method=test,
        args=[
            Hello,
            123
        ]
    }
}
```

## 脚本模式

### **WeCross.getResource**
WeCross控制台提供了一个资源类，通过方法`getResource`来初始化一个跨链资源实例，并且赋值给一个变量。
这样调用同一个跨链资源的不同UBI接口时，不再需要每次都输入跨链资源标识。

```bash
# myResource 是自定义的变量名
[server1]> myResource = WeCross.getResource payment.bcoschain.HelloWorldContract
Result ==> {"path":"payment.bcoschain.HelloWorldContract","weCrossRPC":{"weCrossService":{"server":"127.0.0.1:8250"}}}

# 还可以将跨链资源标识赋值给变量，通过变量名来初始化一个跨链资源实例
[server1]> path = payment.bcoschain.HelloWorldContract
Result ==> "payment.bcoschain.HelloWorldContract"

[server1]> myResource = WeCross.getResource path
Result ==> {"path":"payment.bcoschain.HelloWorldContract","weCrossRPC":{"weCrossService":{"server":"127.0.0.1:8250"}}}
```

### **[resource].[command]**
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
[server1]> myResource.getData "key"
StatusAndValue{
    errorCode=101,
    errorMessage='Not supported by BCOS_CONTRACT',
    value='null'
}

# setData
[server1]> myResource.setData "key" "value"
Status{
    errorCode=101,
    errorMessage='Not supported by BCOS_CONTRACT'
}

# call
[server1]> myResource.call String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello
    ]
}

# sendTransaction
[server1]> myResource.sendTransaction Void set "World"
Receipt{
    errorCode=0,
    errorMessage='null',
    hash='0x9b066f179de92ed8cd6d659bf7c1abe075ee77d6a45d3e452e136b95da13946f',
    result=[

    ]
}

[server1]> myResource.call String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        World
    ]
}
```