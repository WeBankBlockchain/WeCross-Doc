# WeCross Go SDK开发应用

WeCross 跨链路由向外部暴露了所有的UBI接口，开发者可以在Go程序项目中引入Go-SDK实现这些接口的快速调用。

## 环境要求
```eval_rst
.. important::
    - go版本
     要求 `go1.18或以上 <https://go.dev/dl/>`_
     - WeCross服务部署
     参考 `部署指南 <../tutorial/deploy/basic_env.html>`_
```

## Go项目中引入SDK

在终端中输入命令`go get github.com/WeBankBlockchain/WeCross-Go-SDK`下载WeCross-Go-SDK。

然后在Go项目中引用即可。

    import "github.com/WeBankBlockchain/WeCross-Go-SDK"

## SDK配置说明

如果使用Go-SDK调用RPC接口，需要首先实现SDK的网络配置与SSL连接配置。

配置步骤如下：

1. 将跨链路由`router-${zone}/cert/sdk/`目录下的证书和密钥拷贝到项目的`classpath`目录；
3. 在项目的`classpath`目录下新建文件 `application.toml`，默认配置如下：

```toml
[connection]
    server =  '127.0.0.1:8250'
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
    sslSwitch = 2 # disable ssl:2, SSL without client auth:1 , SSL with client and server auth: 0
```

4. 修改`application.toml`中`server`，使用跨链路由实际监听的IP和端口。

**配置解读：** 在`application.toml`配置文件中，`[connection]`配置跨链路由的连接信息，具体包括以下配置项：

- `server`: 跨链路由监听的IP和端口；
- `sslKey`: 客户端私钥路径，可以使用相对路径与绝对路径；
- `sslCert`: 客户端证书路径，可以使用相对路径与绝对路径；
- `caCert`: CA证书路径，可以使用相对路径与绝对路径；
- `sslSwitch`: SSL的模式开关，0: 双向验证；1: 只验证服务端；2: 关闭SSL。

**注意：** 当sslSwitch的值为2时，sslKey，sslCert以及caCert属性所指的文件路径可以不存在（即文件可以找不到），但不能略去这几个属性。

## 使用方法

详细的API接口说明请查阅[WeCross Go SDK API](./go_sdk_api.md)。

### 简易Go程序日志系统
本SDK提供了一种简易的日志记录系统，方便用户进行快速程序开发，用户可以选择是否开启，并且自定义设置日志系统的输出格式与输出文件，示例代码如下：

```go
func main() {
	// 将标准输出添加进日志系统的输出
	logger.AddStdOutLogSystem(logger.Info)
	// 自定义一个日志输出系统
	logger.AddNewLogSystem("./", "test.log", log.LstdFlags, logger.Debug)

	// 在你的go程序中定义不同的日志标签
	testLogTag := logger.NewLogger("quickStart")
	// 使用这些标签进行日志填写
	testLogTag.Infoln("Log here as you wish.")
	testLogTag.Warnf("Use the log level you like, warn level is: %d", logger.Warn)

	// 日志消息可能需要等待一定时间才能刷入标准输出， 使用flush可以强制刷新
	// 此处为了在标准输出中显示测试结果使用Flush，实际使用时无需用户自己去Flush
	logger.Flush()
}
```

日志文件`./test.log`输出如下：

```
2022/11/20 16:39:42 [quickStart] Log here as you wish.
2022/11/20 16:39:42 [quickStart] Use the log level you like, warn level is: 2
```

**注意：** WeCross-Go-SDK中RPC服务与资源调用产生的日志信息是默认添加且无法关闭的，如不能满足场景需求，建议用户在自己的go程序中使用其它日志系统。 

### 调用RPC服务与资源封装接口
示例代码如下：
```go
func main() {
	// 首先创建RPC服务并设置存放配置文件的文件目录classpath
	// classpath下应该放置application.toml
	rpcService := service.NewWeCrossRPCService()
	rpcService.SetClassPath("./tomldir") // 如不设置classpath,默认为当前程序运行目录

	err := rpcService.Init()
	if err != nil {
		panic(err)
	}

	// 初始化WeCrossRPC模块绑定RPC服务
	weCrossRPC := rpc.NewWeCrossRPCModel(rpcService)

	// 使用WeCrossRPC模块构造不同的RPC命令
	// 此处为用户登录
	call, err := weCrossRPC.Login("username", "password")
	if err != nil {
		panic(err)
	}

	// RPC执行并返回结果
	res, err := call.Send()
	if err != nil {
		panic(err)
	}
	fmt.Printf("The response is: %s\n", res.ToString())

	// 对RPC结果response更加复杂的处理,需要知道不同RPC返回的response data的数据类型
	// 更多RPC指令以及所对应的response data类型可查阅官方文档中的WeCross-Go-SDK技术文档
	data, ok := res.Data.(*response.UAReceipt)
	if !ok {
		panic("type is not right")
	}
	fmt.Printf("Universal Account info: %s\n", data.UniversalAccount.ToString())

	// 使用资源封装接口前请一定先保证用户为登录态
	// 使用NewResource绑定资源的path
	testResource := resource.NewResource(weCrossRPC, "payment.bcos.HelloWecross")

	// 更多资源相关API请查阅官方文档
	// 检查资源是否可达
	if !testResource.IsActive() {
		panic("the path is not active")
	}

	var callRes, sendRes []string

	// 使用绑定的资源进行调用
	callRes, err = testResource.Call("get")
	if err != nil {
		panic(err)
	}
	fmt.Println("Call Result:")
	fmt.Println(callRes)

	// 使用绑定的资源进行调用
	sendRes, err = testResource.SendTransaction("set", "Leo")
	if err != nil {
		panic(err)
	}
	fmt.Println("SendTransaction Result:")
	fmt.Println(sendRes)
}
```

**注意：** 更多RPC命令，资源操作命令与Response的Data类型可查阅[WeCross Go SDK API](./go_sdk_api.md)。

