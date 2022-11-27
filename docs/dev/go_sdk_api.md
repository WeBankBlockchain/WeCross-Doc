# WeCross Go SDK API

GO SDK API分为两大类型，一种是对跨链路由RPC接口调用的封装，一种是资源接口。

## API列表

* RPC封装接口

```go
type WeCrossRPC interface {
	Test() *RemoteCall
	SupportedStubs() *RemoteCall
	QueryPub() *RemoteCall
	QueryAuthCode() *RemoteCall
	ListAccount() *RemoteCall
	ListResources(ignoreRemote bool) *RemoteCall
	Detail(path string) *RemoteCall
	Call(path, method string, args ...string) *RemoteCall
	SendTransaction(path, method string, args ...string) *RemoteCall
	Invoke(path, method string, args ...string) *RemoteCall
	CallXA(transactionID, path, method string, args ...string) *RemoteCall
	SendXATransaction(transactionID, path, method string, args ...string) *RemoteCall
	StartXATransaction(transactionID string, paths []string) *RemoteCall
	CommitXATransaction(transactionID string, paths []string) *RemoteCall
	RollbackXATransaction(transactionID string, paths []string) *RemoteCall
	GetXATransaction(transactionID string, paths []string) *RemoteCall
	CustomCommand(command string, path string, args ...any) *RemoteCall
	ListXATransactions(size int) *RemoteCall
	Register(name, password string) (*RemoteCall, *common.WeCrossSDKError)
	Login(name, password string) (*RemoteCall, *common.WeCrossSDKError)
	Logout() *RemoteCall
	AddChainAccount(chainType string, chainAccount account.ChainAccount) *RemoteCall
	SetDefaultAccount(chainType string, chainAccount account.ChainAccount, keyID int) *RemoteCall
	GetCurrentTransactionID() string
}
```

* 资源接口

```go
func NewResource(weCrossRPC rpc.WeCrossRPC, path string) *Resource {}
func (rsc *Resource) Check() *common.WeCrossSDKError {}
func (rsc *Resource) IsActive() bool {}
func (rsc *Resource) Detail() (*resources.ResourceDetail, *common.WeCrossSDKError) {}
func (rsc *Resource) Call(method string, args ...string) ([]string, *common.WeCrossSDKError) {}
func (rsc *Resource) SendTransaction(method string, args ...string) ([]string, *common.WeCrossSDKError) {}
```

## 数据类型解析
### common.WeCrossSDKError
#### 数据结构
```go
type WeCrossSDKError struct {
	Code    ErrorCode
	Content string
}
```
#### 类型说明
Go-SDK中的错误类型，实现了error接口类型。

### rpc.RemoteCall
#### 数据结构
```go
type RemoteCall struct {
	weCrossService service.WeCrossService
	httpMethod     string
	uri            string
	responseType   response.ResponseType
	request        *types.Request
}
```
#### 类型说明
RPC远程调用类型，通过`Send`函数实现远程调用并返回结果。

### types.Response
#### 数据结构
```go
type Response struct {
	Version   string             // 版本号  
	ErrorCode common.ErrorCode   // 状态码
	Message   string             // 错误消息
	Data      Data               // 调用结果
}
```
#### 类型说明
RPC服务调用返回结果，其中`Data`为实现`ToString`函数的接口类型，针对不同的RPC命令返回的类型不同。

### response.NullResponse
#### 数据结构
```go
type NullResponse struct {
}
```
#### 类型说明
用于测试RPC时的返回类型，为一空结构体。

### response.Stubs
#### 数据结构
```go
type Stubs struct {
	StubTypes []string `json:"stubTypes"`
}
```
#### 类型说明
RPC命令`SupportedStubs`的返回类型，包含支持的stub种类。

### response.Pub
#### 数据结构
```go
type Pub struct {
	Pub string `json:"pub"`
}
```
#### 类型说明
RPC命令`QueryPub`的返回类型，获取公钥，前端用于对敏感数据加密。

### response.AuthCodeReceipt
#### 数据结构
```go
type AuthCodeReceipt struct {
	ErrorCode common.ErrorCode `json:"errorCode"`
	Message   string           `json:"message"`
	AuthCode  *AuthCodeInfo    `json:"authCode"`
}

type AuthCodeInfo struct {
	RandomToken string `json:"randomToken"`
	ImageBase64 string `json:"imageBase64"`
}
```
#### 类型说明
RPC命令`QueryAuthCode`的返回类型，获取验证码，用于用户注册与登录。

### response.UAReceipt
#### 数据结构
```go
type UAReceipt struct {
	ErrorCode        common.ErrorCode          `json:"errorCode"`
	Message          string                    `json:"message"`
	Credential       string                    `json:"credential"`
	UniversalAccount *account.UniversalAccount `json:"universalAccount"`
}
```
#### 类型说明
涉及Universal Account改变的RPC命令的返回类型，包含了当前状态下的Universal Account信息。

### account.UniversalAccount
#### 数据结构
```go
type UniversalAccount struct {
	username      string
	password      string
	pubKey        string
	secKey        string
	uaID          string
	chainAccounts []ChainAccount
}
```
#### 类型说明
RPC命令`ListAccount`的返回类型，包含了当前状态Universal Account信息以及其所拥有的各类型链账户信息。

### resources.Resources
#### 数据结构
```go
type Resources struct {
	ResourceDetails []*ResourceDetail `json:"resourceDetails"`
}
```
#### 类型说明
RPC命令`ListResources`的返回类型，包含了当前所有可用的资源信息。

### resources.ResourceDetail
#### 数据结构
```go
type ResourceDetail struct {
	Path       string                 `json:"path"`
	Distance   int                    `json:"distance"`
	StubType   string                 `json:"stubType"`
	Properties map[string]interface{} `json:"properties"`
	CheckSum   string                 `json:"checkSum"`
}
```
#### 类型说明
RPC命令`Detail`的返回类型，包含查询到的指定资源的所有细节信息。

### response.TXReceipt
#### 数据结构
```go
type TXReceipt struct {
	ErrorCode   common.ErrorCode `json:"errorCode"`
	Message     string           `json:"message"`
	Hash        string           `json:"hash"`
	ExtraHashes []string         `json:"extraHashes"`
	BlockNumber int              `json:"blockNumber"`
	Result      []string         `json:"result"`
}
```
#### 类型说明
在发起交易信息后返回的交易回执信息。

### RawXAResponse
#### 数据结构
```go
type RawXAResponse struct {
	Status             common.StatusCode         `json:"status"`
	ChainErrorMessages []*eles.ChainErrorMessage `json:"chainErrorMessages"`
}

type ChainErrorMessage struct {
	Path    string `json:"path"`
	Message string `json:"message"`
}
```
#### 类型说明
与事务状态有关的RPC命令返回类型。

### response.RawXATransactionListResponse
#### 数据结构
```go
type RawXATransactionListResponse struct {
	XaList      []*xa.XA       `json:"xaList"`
	NextOffsets map[string]int `json:"nextOffsets"`
	Finished    bool           `json:"finished"`
}

type XA struct {
	XaTransactionID string   `json:"xaTransactionID"`
	UserName        string   `json:"username"`
	Status          string   `json:"status"`
	TimeStamp       int      `json:"timestamp"`
	Paths           []string `json:"paths"`
}
```
#### 类型说明
RPC命令`ListXATransactions`的返回类型，包含了历史发起的事务的相关状态与信息。

### response.RawXATransactionResponse
#### 数据结构
```go
type RawXATransactionResponse struct {
	XaResponse    *RawXAResponse    `json:"xaResponse"`
	XaTransaction *xa.XATransaction `json:"xaTransaction"`
}

type XATransaction struct {
	XaTransactionID    string               `json:"xaTransactionID"`
	Username           string               `json:"username"`
	Status             string               `json:"status"`
	StartTimestamp     int64                `json:"startTimestamp"`
	CommitTimestamp    int64                `json:"commitTimestamp"`
	RollbackTimestamp  int64                `json:"rollbackTimestamp"`
	Paths              []string             `json:"paths"`
	XaTransactionSteps []*XATransactionStep `json:"xaTransactionSteps"`
}

type XATransactionStep struct {
	XaTransactionSeq int64  `json:"xaTransactionSeq"`
	Username         string `json:"username"`
	Path             string `json:"path"`
	Timestamp        int64  `json:"timestamp"`
	Method           string `json:"method"`
	Args             string `json:"args"`
}
```
#### 类型说明
RPC命令`GetXATransaction`的返回类型,包含了事物的当前状态与历史步骤。



### response.StringResponse
#### 数据结构
```go
type StringResponse string
```
#### 类型说明
RPC命令`CustomCommand`的返回类型，为一长字符串，供用户自行解析处理。

## RPC封装接口解析
### Test
RPC服务测试函数，测试成功返回一空类型。
#### 参数

- 无

#### 返回值Data类型

- response.NullResponse

#### 用例
```go
	// 初始化 RPC 实例
	rpcService := service.NewWeCrossRPCService()
	rpcService.Init()
	weCrossRPC := rpc.NewWeCrossRPCModel(rpcService)

	// 调用RPC接口，目前只支持同步调用
	call := weCrossRPC.Test()
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.NullResponse) // 类型断言
```

**注**
    - 之后的go示例，会省去初始化WeCrossRPC的步骤。所有RPC命令的返回结果的Data类型详细信息可在前文数据类型解析中查看。


### SupportedStubs
显示router当前支持的插件列表。
#### 参数

- 无

#### 返回值Data类型

- response.Stubs

#### 用例
```go
	call := weCrossRPC.SupportedStubs()
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.Stubs)
```

### QueryPub
获取公钥，前端用于对敏感数据加密

#### 参数

- 无

#### 返回值Data类型

- response.Pub

#### 用例
```go
	call := weCrossRPC.QueryPub()
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.Pub)
```
### QueryAuthCode
获取验证码，登录、注册时使用

#### 参数

- 无

#### 返回值Data类型

- response.AuthCodeReceipt

#### 用例
```go
	call := weCrossRPC.QueryAuthCode()
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.AuthCodeReceipt)
```

### ListAccount
查看当前全局账号的详细信息。

#### 参数

- 无

#### 返回值Data类型

- account.UniversalAccount

#### 用例
```go
	call := weCrossRPC.ListAccount()
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*account.UniversalAccount)
```

### ListResources
显示router配置的跨链资源。

#### 参数

- `ignoreRemote`: `bool` - 是否忽略远程资源

#### 返回值Data类型

- resources.Resources

#### 用例
```go
	call := weCrossRPC.ListResources(true)
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*resources.Resources)
```

### Detail
获取资源详情。

#### 参数

- `path`: `string` - 跨链资源标识

#### 返回值Data类型

- resources.ResourceDetail

#### 用例
```go
	call := weCrossRPC.Detail("payment.bcos.HelloWeCross")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*resources.ResourceDetail)
```

### Call
调用智能合约，不更改链状态，不发交易；在事务状态下，与CallXA接口一致。
#### 参数

- `path`: `string` - 跨链资源标识
- `method`: `string` - 调用的方法
- `args` : `...string` - 可变参数列表

#### 返回值Data类型

- response.TXReceipt

#### 用例
```go
	call := weCrossRPC.Call("payment.bcos.HelloWeCross","get","key")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.TXReceipt)
```

### SendTransaction
调用智能合约，会改变链状态，发交易。

#### 参数

- `path`: `string` - 跨链资源标识
- `method`: `string` - 调用的方法
- `args` : `...string` - 可变参数列表

#### 返回值Data类型

- response.TXReceipt

#### 用例
```go
	call := weCrossRPC.SendTransaction("payment.bcos.HelloWeCross","set","Leo","awesome")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.TXReceipt)
```

### Invoke
调用智能合约，会改变链状态，发交易；在非事务状态下，与SendTransaction接口一致；在事务状态下，与SendXATransaction接口一致。

#### 参数

- `path`: `string` - 跨链资源标识
- `method`: `string` - 调用的方法
- `args` : `...string` - 可变参数列表

#### 返回值Data类型

- response.TXReceipt

#### 用例
```go
	call := weCrossRPC.Invoke("payment.bcos.HelloWeCross","set","Leo","awesome")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.TXReceipt)
```

### CallXA

获取事务中的状态数据，不发交易

#### 参数

- `transactionID`:`string` - 事务ID
- `path`: `string` - 跨链资源标识  
- `method`: `string` - 调用的方法
- `args` : `...string` - 可变参数列表


#### 返回值Data类型

- response.TXReceipt

#### 用例
```go
	call := weCrossRPC.CallXA("0001","payment.bcos.evidence","queryEvidence","key1")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.TXReceipt)
```

### SendXATransaction
执行事务，发交易

#### 参数

- `transactionID`:`string` - 事务ID
- `path`: `string` - 跨链资源标识  
- `method`: `string` - 调用的方法
- `args` : `...string` - 可变参数列表

#### 返回值Data类型

- response.TXReceipt

#### 用例
```go
	call := weCrossRPC.SendXATransaction("0001","payment.bcos.evidence","queryEvidence","key1","evidence1")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.TXReceipt)
```

### StartXATransaction
开始事务，锁定事务相关资源，发交易

#### 参数

- `transactionID`:`string` - 事务ID
- `paths`: `[]string` - 参与该事务的链路径列表

#### 返回值Data类型

- response.RawXAResponse

#### 用例
```go
	call := weCrossRPC.StartXATransaction("0001",[]string{"payment.bcos", "payment.fabric"})
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.RawXAResponse)
```

### CommitXATransaction
提交事务，释放事务相关资源，发交易

#### 参数

- `transactionID`:`string` - 事务ID
- `paths`: `[]string` - 参与该事务的链路径列表

#### 返回值Data类型

- response.RawXAResponse

#### 用例
```go
	call := weCrossRPC.CommitXATransaction("0001",[]string{"payment.bcos", "payment.fabric"})
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.RawXAResponse)
```

### RollbackXATransaction
回滚事务，释放事务相关资源，发交易

#### 参数

- `transactionID`:`string` - 事务ID
- `paths`: `[]string` - 参与该事务的链路径列表

#### 返回值Data类型

- response.RawXAResponse

#### 用例
```go
	call := weCrossRPC.RollbackXATransaction("0001",[]string{"payment.bcos", "payment.fabric"})
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.RawXAResponse)
```

### GetXATransaction
获取事务详情，不发交易

#### 参数

- `transactionID`:`string` - 事务ID
- `paths`: `[]string` - 参与该事务的链路径列表

#### 返回值Data类型

- response.RawXATransactionResponse

#### 用例
```go
	call := weCrossRPC.GetXATransaction("0001",[]string{"payment.bcos", "payment.fabric"})
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.RawXATransactionResponse)
```

### ListXATransactions
获取事务列表，不发交易

#### 参数

- `size`: `int` - 获取事务个数

#### 返回值Data类型

- response.RawXATransactionListResponse

#### 用例
```go
	call := weCrossRPC.ListXATransactions(5)
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.RawXATransactionListResponse)
```

### CustomCommand
自定义命令，返回一长字符串，需用户自行解析。
#### 参数

- `command`: `string` - 命令名称
- `path`: `string` - 跨链资源标识
- `args`: `...any` - 可变参数

#### 返回值Data类型

- response.StringResponse

#### 用例
```go
	call := weCrossRPC.CustomCommand("deploy", "payment.bcos.evidence", "Evidence")
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.StringResponse)
```

### Register
注册一个UniversalAccount账号，如果账户密码不符合规范会直接报错。

#### 参数

- `name`: `string` - 账号名
- `password`: `string` - 账号密码

#### 返回值Data类型

- response.UAReceipt

#### 用例
```go
	call,err := weCrossRPC.Register("org1-admin", "123456")
	if err != nil {
		panic(err)
	}
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.UAReceipt)
```

### Login
登录一个UniversalAccount账号，如果账户密码不符合规范会直接报错。

#### 参数

- `name`: `string` - 账号名
- `password`: `string` - 账号密码

#### 返回值Data类型

- response.UAReceipt

#### 用例
```go
	call,err := weCrossRPC.Login("org1-admin", "123456")
	if err != nil {
		panic(err)
	}
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.UAReceipt)
```

### Logout
退出当前UniversalAccount账号。
#### 参数

- 无

#### 返回值Data类型

- response.UAReceipt

#### 用例
```go
	call := weCrossRPC.Logout()
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.UAReceipt)
```

### AddChainAccount
添加一个链账号。

#### 参数

- `type`: `string` - 链类型
- `chainAccount`: `account.ChainAccount` - 链账号

#### 返回值Data类型

- response.UAReceipt

#### 用例
```go
	call := weCrossRPC.AddChainAccount("BCOS2.0", chainAccount)
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.UAReceipt)
```

### SetDefaultAccount
设置一个链账号为某一链类型的默认账号。优先使用chainAccount进行设置，若为nil，则使用KeyID。
#### 参数

- `type`: `string` - 链类型
- `chainAccount`: `account.ChainAccount` - 链账号
- `keyID`: `int` - 链的KeyID

#### 返回值Data类型

- response.UAReceipt

#### 用例
```go
	call := weCrossRPC.SetDefaultAccount( "BCOS2.0", nil ,1)
	rsp, _ := call.Send()
	data,_ := rsp.Data.(*response.UAReceipt)
```


### GetCurrentTransactionID
返回Go-SDK当前维护的事务ID。
#### 参数

- 无

#### 返回值

- `transactionID`: `string` - 当前事物的ID号

#### 用例
```go
	txID := weCrossRPC.GetCurrentTransactionID()
```

## 资源接口解析
### NewResource
初始化一个跨链资源。

#### 参数

- `weCrossRPC` : `rpc.WeCrossRPC` - RPC实例
- `path`: `string` - 跨链资源标识

#### 返回值

- `Resource` - 跨链资源实例

#### 用例
```go
	// 初始化 RPC 实例
	rpcService := service.NewWeCrossRPCService()
	rpcService.Init()
	weCrossRPCModel := rpc.NewWeCrossRPCModel(rpcService)

	// 初始化资源实例
	testResource := resource.NewResource(weCrossRPCModel, "payment.bcos-group1.HelloWorldGroup1")
```

**注**
    - 之后的Go示例，会省去初始化Resource的步骤。

### Check
检查当前资源是否初始化成功。

#### 参数

- 无

#### 返回值

- `common.WeCrossSDKError` - 错误信息

#### 用例
```go
	err := testResource.Check()
	if err != nil {
		panic(err)
	}
```

### IsActive
获取资源状态，`true`:可达，`false`:不可达。

#### 参数

- 无

#### 返回值

- `bool` - 资源状态

#### 用例
```go
	status := testResource.IsActive()
```

### Detail
获取资源详情。

#### 参数

- 无

#### 返回值

- `resources.ResourceDetail` - 资源详情
- `common.WeCrossSDKError` - 错误信息

#### 用例
```go
	resourceDetail, err := testResource.Detail()
```

### Call
调用智能合约，不更改链状态，不发交易。

#### 参数

- `method`: `string` - 调用的方法
- `args`: `...string` - 可变参数列表

#### 返回值

- `[]string` - 调用结果

#### 用例
```go
	result := resource.Call("get", "key")
```

### SendTransaction
调用智能合约，会改变链状态，发交易。

#### 参数

- `method`: `string` - 调用的方法
- `args`: `...string` - 可变参数列表

#### 返回值

- `[]string` - 调用结果

#### 用例
```go
	result := resource.SendTransaction("set", "Leo", "awesome")
```

