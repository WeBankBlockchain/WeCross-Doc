# JSON-RPC API

WeCross提供了[Java-SDK](./sdk.html)，方便Java项目直接引入，其它语言的项目则可通过调用JSON-RPC API完成跨链开发。

## 状态码

当RPC调用遇到错误时，返回的响应对象必须包含错误结果字段，该字段有下列成员参数：

- errorCode: 使用数值表示该异常的错误类型，必须为整数。
- message: 对该错误的简单描述字符串。

状态码及其对应的含义如下：  

| code  | 含义               |
|:------|:-------------------|
| 0     | 执行成功           |
| 10000 | 内部错误           |
| 10001 | URI访问路径错误    |
| 10002 | URI查询字段错误    |
| 2xxxx | 网络包错误         |
| 3xxxx | 跨链账户错误       |
| 4xxxx | 资源调用错误       |
| 5xxxx | 交易查询错误       |
| 6xxxx | 两阶段事务错误     |
| 7xxxx | 哈希时间锁合约错误 |

## RPC接口列表

### pub
获取公钥，前端用于对敏感数据加密

#### 接口URL
> http://127.0.0.1:8250/auth/pub

#### 请求方式
> GET

#### Content-Type
> application/json

#### 请求Query参数
空
#### 请求Body参数
空

#### 成功响应示例
```json
{
  "version": "1.0",
  "errorCode": 0,
  "message": "success",
  "data": {
    "errorCode": 0,
    "message": "success",
    "pub": "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAiJ0u2c/Xze3Jv+beltOfoaavZtatVmldwctq3ItZZ5w60whzKiNdrsFcQZqj2PszLbwiYsC4fEFKQIcaTiHCXDSQ1Km25ay8/c+NKprl/ruevGB1pXDnQNZhQqoaghfzijTX2bl6DJqCnuSV46sCKgKfyKm3PNPcsMUxYWC1283an3cviUvdSnZyXHN++T2Otw77EVm55CNuDpX5MkOOIPTMSAxzweC9n9dJf5sGbmzqK2Yx8Jp/9vUA+jqR8ljqKJ7Q6bLVW3/xuqAN542U8a3dvPY3RVAkLVxgnl7UIfQl5PcBIxd4W3NZM6da/ZGmp76MAq/hxpceoU7DmQntkP9mX9ExtzcUTNFTm+LERwR530YRx4P7QB3EAAujEklZrlhXVwNa3phXnZRJWm4nuJ3qQB0I2VIw9q247aSLWEkoXQWu9CyRWzt7hmxgspwCYwsMdkvs0t8zv5L1LK0i8qXLHQCrasHkoJQ16+aztSDFmrAhJKtC4JN+ACnR1kMXAz/r2o3Y+pCO/2eBSDllsYSwCMRcgFwGvmutSD5dLes+zFZusxTRZ6vVnnnob+fOZ0NAdEDG9QY4UZoUxMjqSqM2db9jQ67QlcuMuEsc7uQ7T5mWlNORBnEVCz/UIjvFKnw7XnvGWcT/hKTPKYbgkqOJ/KQ05DoF/W3VHU+inPMCAwEAAQ=="
  }
}
```

### authCode
获取验证码，登录、注册时使用

#### 接口URL
> http://127.0.0.1:8250/auth/authCode

#### 请求方式
> GET

#### Content-Type
> application/json

#### 请求Query参数
空
#### 请求Body参数
空

#### 成功响应示例
```json
{
  "version": "1.0",
  "errorCode": 0,
  "message": "success",
  "data": {
    "errorCode": 0,
    "message": "success",
    "authCode": {
      "randomToken": "ad4b480b9585eaee7368a8260e28a198119bb88073f6f3b1aa03ede49ef1214e",
      "imageBase64": "iVBORw0KGgoAAAANSUhEUgAAAJsAAAA8CAIAAAD+Gl+NAAADQUlEQVR42u3cMW7kMAwFUB1im9S5xQLpUi9yhhxiq82Vttw+N0q53WSAAQzDGtGfFClSGgpqknFsj58lk7Sd8vX/kn2lXi6N9u/zL/FjNqN2Pc6yvq2hIJyJOkyxf20M0XQNPkxvPUVXa0Ugl6gpmi2AaIZIa4pmGrOgqEWEnc1fNFuKZkvRbCmaLUVTdJ4mvllRt/ffP/c9Rc/b25/XQwf/8OXXE9gF+dgB8m5P0dCoxLic1zVF2ZzBUT2vo1zUbZIMghrTdRrR7WqHc+KiMs4UlYvuQ9Mxorj6o4se2EDUQ7LRGQSJUVuurA19PP+49YlFa7YNDxGtc0dHUdaStWKrLyJKSNOiNerhN1qoBBjrruKpqKJricaJiFrko0h8JBMFObVQI4oqopqWGkBUlmi/q5so8ik+6yoWBdUTGBpsMlFk/LmI0oV7Lip9A+AUTHfi9Rmj3NwUR6W995Z2xd56E2OiXDdR2WKnl1LEW/bYm3gG3lwXj3W1RAU1ffWcFcxzrn1YuOuTj4oX47pa1CJ66oIWES/0JlNYURy1dZdGsXjUCoy1khlQ0aeuq4tKXFbrBexQb5sQV3rFrnRk5yYqiHjrL9bSou/VyKbT1iklTlL36wFFkSg9kCiozgpoZdUG4gIJPpoEjsj6/COW6Xoj2MUVrAhqJaa6ySg4RokhSAxWVg7tL8qt8Q6oCI4UPe3c8N7hjre6qEXhXlbj1c1e6MgoxKwrdtVF5T6iPaB2j4iCj48HerqTeLahp6SgVV5QfJYMryIJXtt1fktCxnZ6vOxKRZ3Pj9U2BGTcKuD4FvBFdALp7kBMUSpkCMtJQ8r2vKxk2Rqpjq6tHaN3uAe1LGnZOuUHu7YsWVeK6PnoSM7WQRlGy9ouvUv4Ny1BVASHmPUn9SasUfHN4V8fuR4Xd06xUP+YtkMFOcWnMhEilCCcrEPcKbE/oy1QTy/eKkF4aw0lDieopWhgkd7Qc4DW5qYZo50fRaAlkkvFs4cY9yUg58Xjf8Fuk3BndUJrPeJDN5moaYBKh5GK/13H7rh1ifbstCCJvAyp1vZHKwMmkhQdLeo4QOWi1pyd2aoX6oOKLow68aw7XtS9yD7LGP0G/T53V67Tc1kAAAAASUVORK5CYII="
    }
  }
}
```

### register
用户注册

#### 接口URL
> http://127.0.0.1:8250/auth/register

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Body参数
```json
{
  "version": "1",
  "data": "eEG9fFyTDU2RHjp/kVMTCANqrbQACm0tjGdE+UQgvniGT/+xzrDDKOPpIPMPhFTs4rqOAaCHAmzzTP26i72e4l1a+YvRo1lqARxtofDMPD9ku7yaM8xz47bCz5d+9P9E/i9lZiKZ1fsv1qgdTw74/Sbixh7KhPeqUUajh4v3cu4/4b57/4NKoHUAr1AlMDE1/N7wcuRlWQposZLpMQrPd9uLuviWFw+l7b7ugT/VsVPIuM8K6qo7ubeMoH269jp+1/tYNzqbG2bAi2uoFXSYelcETM3ew8zVxJZEGAeqgklNWSFOjKAeZSvkIceQzVH4wxVT/b6+hiH7Q+hQiowK6Yd7AcHNm/mCkXKdZIH87NaACWVimWowQZvrIrmINgESuMMQo60iZJc+pU46O0118WXNSeBnlgUf7LeVUz37sOn00O6rNH1/ov2z7LmUo1XdCTOB24qj6Pl9040NMWWV/mh8Ck+0cThhf+IKmpdS+Hx4cvPChM6mSZDI5reQdoe+Ay1ABLIAEERLwDM3Oa3IAnWaG1hzihsWh5daTi3Xo3jICX08aTy6ossoC1f8oRPdPUTvNk8UtqUu5IO1OsPT9s2ZpSh0cyCHgjpuaqg1FOJEVCkYGOj9SZ1AHbe3qrYyCvrp8t81BaONmi52iWW7ldXbh6ylm47ix7B3EbmkA50="
}
```

| 参数    | 示例值 | 是否必填 | 参数描述                                     |
|:--------|:-------|:---------|:---------------------------------------------|
| version | 1      | 必填     | 接口版本                                     |
| data    |        | 必填     | 账户名+密码+认证码 RSA加密，再进行base64编码 |

#### 成功响应示例
```json
{
  "version": "1",
  "errorCode": 0,
  "message": "success",
  "data": {
    "errorCode": 0,
    "message": "success",
    "universalAccount": {
      "username": "shareong",
      "pubKey": "3059301306072a8648ce3d020106082a811ccf5501822d034200044f7f2e394493742fa58bf17b22ed73fd92125be9ca7c093c516531572bac91a7608578ef6724a3115a1126047cb50762fc6f4e1eb0b4fb8a4c3efe6d1982c356",
      "uaID": "3059301306072a8648ce3d020106082a811ccf5501822d034200044f7f2e394493742fa58bf17b22ed73fd92125be9ca7c093c516531572bac91a7608578ef6724a3115a1126047cb50762fc6f4e1eb0b4fb8a4c3efe6d1982c356"
    }
  }
}
```

### login
登录接口

#### 接口URL
> http://127.0.0.1:8250/auth/login

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Body参数

```json
{
  "version": "1",
  "data": "LvZLmoOgui6NAoTNuDz4T9rv5rmvFAzji+87EOm39MhfK/sXeUZ0WqLPoLYHL8kabVKOAvSdzskGHUYc84O88hO1bN7aUc6RYjw2e2dJdf1Bqe0MnGRccxTEZU37mwA1JcWbpzL9yv0w64xisLsfO87K7WC7frSU6kUy9MXJyEkIsBKSY9eSyhynwA/3FaHhZ0YMRx9LsdD4/lsrBg3Qk0D2/V1PTlt+KG32PJvwB6EsCDjQYFUhHkOfBQQZ6uZVWWcJkJQtSQ0NwFKaaQ4nUUP+dueUGD+1dfYuer1mOhjiuwuQNoMBcr8mq7ZpZQPG7FIXrMHMX/nw57+L3M01tf6YthuQV7QVDUdFZjP5q2bcX70217BYivAGJar4w6WlEhPAJTnu8ovl+DEGBNWPnhOBdtKffUW51iqtiooQfPw61GRR5uRFlxV3zVn7blaBmFH7H2naa1+4Dk1xgnC06lgJyQiLxfZ8/+4issYzjniqu6Lf7Lx2iiejzTk10csQ/DjDN1Hs1gHv4NZ7s1n8ESM7uL1Hqu2fOKIzMbctoNzVMeBidxBtdrz0g/keUMBzzN/j4meq6kDvxc/FaVI0TWCuOZ5diRD/+dGcOELh2eEhTdNknE67ekx1oY7RleyObulRexV3gu1C6X4PtcxfnsnfD04sGkO73zyTepUu7cE="
}
```

| 参数    | 示例值 | 是否必填 | 参数描述                                     |
|:--------|:-------|:---------|:---------------------------------------------|
| version | 1      | 必填     | 接口版本                                     |
| data    |        | 必填     | 账户名+密码+验证码 RSA加密，再进行base64编码 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "success",
	"data": {
		"errorCode": 0,
		"message": "success",
		"credential": "Bearer eyJpYXRtaWxsIjoxNjA2OTkyMDc5NzU0LCJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJzaGFyZW9uZyIsIm5iZiI6MTYwNjk5MjA3OSwiaXNzIjoib3JnMSIsImV4cCI6MTYwNzAxMDA3OSwiaWF0IjoxNjA2OTkyMDc5fQ.9_IhhFwBajPrucruAx05noBUzFrHc7Xfl2fUObhdkX8",
		"universalAccount": {
			"username": "shareong",
			"uaID": "3059301306072a8648ce3d020106082a811ccf5501822d034200044f7f2e394493742fa58bf17b22ed73fd92125be9ca7c093c516531572bac91a7608578ef6724a3115a1126047cb50762fc6f4e1eb0b4fb8a4c3efe6d1982c356",
			"pubKey": "3059301306072a8648ce3d020106082a811ccf5501822d034200044f7f2e394493742fa58bf17b22ed73fd92125be9ca7c093c516531572bac91a7608578ef6724a3115a1126047cb50762fc6f4e1eb0b4fb8a4c3efe6d1982c356",
			"isAdmin": false
		}
	}
}
```

### logout
登出接口

#### 接口URL
> http://127.0.0.1:8250/auth/logout

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{}
```

#### 成功响应示例
```json
{
	"version": "1.0",
	"errorCode": 0,
	"message": "success",
	"data": {
		"errorCode": 0,
		"message": "success"
	}
}
```

### listResources
获取指定区块链的资源列表

#### 接口URL
> http://127.0.0.1:8250/sys/listResources?path=payment.bcos&offset=0&size=1

#### 请求方式
> GET

#### Content-Type
> application/json

#### 请求Query参数

| 参数   | 示例值       | 是否必填 | 参数描述                 |
|:-------|:-------------|:---------|:-------------------------|
| path   | payment.bcos | 必填     | 区块链路径               |
| offset | 0            | 必填     | 偏移量                   |
| size   | 1            | 必填     | 获取资源的数量，最大1024 |


#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |


#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"total": 13,
		"resourceDetails": [
			{
				"path": "payment.bcos.HelloWorld",
				"distance": 0,
				"stubType": "BCOS2.0",
				"properties": {
					"BCOS_PROPERTY_CHAIN_ID": "1",
					"BCOS_PROPERTY_GROUP_ID": "1"
				},
				"checksum": null
			}
		]
	}
}
```

### call
基于只读方式调用资源，若资源路径path=zone.chain.name，则访问路径为：```resource/zone/chain/name/call```

#### 接口URL
> http://127.0.0.1:8250/resource/payment/bcos/HelloWorld/call

#### 请求方式
> POST

#### Content-Type
> application/json 

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
	"version": "1",
	"path": "payment.bcos.HelloWorld",
	"data": {
		"method": "get",
		"args": [],
		"options": {
			"XA_TRANSACTION_ID": "c7ba79423f9b4cacb5e2ee52d07f5831"
		}
	}
}
```

| 参数                           | 示例值                           | 是否必填 | 参数描述                               |
|:-------------------------------|:---------------------------------|:---------|:---------------------------------------|
| version                        | 1                                | 必填     | 接口版本                               |
| data.method                    | get                              | 必填     | 调用方法                               |
| data.args                      | {}                               | 必填     | 参数列表                               |
| data.options                   | -                                | 选填     | 调用选项，访问参与事务的资源需要该字段 |
| data.options.XA_TRANSACTION_ID | c7ba79423f9b4cacb5e2ee52d07f5831 | 必填     | 事务ID                                 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"errorCode": 0,
		"message": "success",
		"hash": "",
		"blockNumber": 0,
		"result": [
			"Hello World"
		]
	}
}
```


### sendTransaction
基于发交易的方式调用资源，若资源路径path=zone.chain.name，则访问路径为：```resource/zone/chain/name/sendTransaction```

#### 接口URL
> http://127.0.0.1:8250/resource/payment/bcos/HelloWorld/sendTransaction

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
	"version": "1",
	"data": {
		"method": "set",
		"args": [
			"Hello WeCross"
		],
		"options": {
			"XA_TRANSACTION_ID": "c7ba79423f9b4cacb5e2ee52d07f5831",
			"XA_TRANSACTION_SEQ": 1607330421667
		}
	}
}
```

| 参数                            | 示例值                           | 是否必填 | 参数描述                               |
|:--------------------------------|:---------------------------------|:---------|:---------------------------------------|
| version                         | 1                                | 必填     | 接口版本                               |
| data.method                     | set                              | 必填     | 调用方法                               |
| data.args                       | Hello WeCross                    | 必填     | 参数列表                               |
| data.options                    | -                                | 选填     | 调用选项，访问参与事务的资源需要该字段 |
| data.options.XA_TRANSACTION_ID  | c7ba79423f9b4cacb5e2ee52d07f5831 | 必填     | 事务ID                                 |
| data.options.XA_TRANSACTION_SEQ | 1607330421647                    | 必填     | 事务Seq，需保证递增                    |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"errorCode": 0,
		"message": "success",
		"hash": "",
		"blockNumber": 0,
		"result": [
			"Hello World"
		]
	}
}
```

### listTransactions
获取指定区块链的交易列表

#### 接口URL
> http://127.0.0.1:8250/trans/listTransactions?path=payment.bcos&blockNumber=10&offset=0&size=2

#### 请求方式
> GET

#### Content-Type
> application/json

#### 请求Query参数

| 参数        | 示例值       | 是否必填 | 参数描述                 |
|:------------|:-------------|:---------|:-------------------------|
| path        | payment.bcos | 必填     | 区块链路径               |
| blockNumber | 10           | 必填     | 块高                     |
| offset      | 0            | 必填     | 偏移量                   |
| size        | 2            | 必填     | 获取交易的数量，最大1024 |

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 成功响应示例
```javascript
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"nextBlockNumber": 8,
		"nextOffset": 0,
		"transactions": [
			{
				"txHash": "0xd9a1f1415826c0a8b891ddb6998b21b581d81c3cbbf624cbaa6664cfffff747e",
				"blockNumber": 10
			},
			{
				"txHash": "0x11420a62d2f81dae948148a47d5ee04983cf319122b192f8acc751084be2e015",
				"blockNumber": 9
			}
		]
	}
}
```

### getTransaction
根据块高和哈希获取交易详情

#### 接口URL
> http://127.0.0.1:8250/trans/getTransaction?path=payment.bcos&txHash=0xba938113bdbae8e57dcf68f96b1edd37f288959ecc0e51c0b409901c27dabafc&blockNumber=1673

#### 请求方式
> GET

#### Content-Type
> application/json

#### 请求Query参数

| 参数        | 示例值                                                             | 是否必填 | 参数描述   |
|:------------|:-------------------------------------------------------------------|:---------|:-----------|
| path        | payment.bcos                                                       | 必填     | 区块链路径 |
| txHash      | 0xba938113bdbae8e57dcf68f96b1edd37f288959ecc0e51c0b409901c27dabafc | 必填     | 交易哈希   |
| blockNumber | 1673                                                               | 必填     | 区块高度   |


#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |


#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"path": "payment.bcos.HelloWorld",
		"username": "shareong",
		"blockNumber": 1673,
		"txHash": "0xba938113bdbae8e57dcf68f96b1edd37f288959ecc0e51c0b409901c27dabafc",
		"xaTransactionID": "c7ba79423f9b4cacb5e2ee52d07f5831",
		"xaTransactionSeq": 1607330421667,
		"method": "set",
		"args": [
			"Hello WeCross"
		],
		"result": [],
		"byProxy": true,
		"txBytes": "eyJoYXNoIjoiMHhiYTkzODExM2JkYmFlOGU1N2RjZjY4Zjk2YjFlZGQzN2YyODg5NTllY2MwZTUxYzBiNDA5OTAxYzI3ZGFiYWZjIiwibm9uY2UiOjEzMDUwMDA2MzYxOTI1MzA0NDU0MTE0MjE5MDk0MDMyMTM0NzU3MjU1NDgyNjEzOTQ5MjgxODAxOTI1MjE5MTQxMjMyODI3MjA1NjgsImJsb2NrSGFzaCI6IjB4ZmNlNmQzMDQxMDc3MWNkMDI0OWMzNDk3NjBkNjJiMzhlOTdiZmFiNTQ2ZGE2MDMxNjQzNzY1ZTk2ZGE5NmQ4ZCIsImJsb2NrTnVtYmVyIjoxNjczLCJ0cmFuc2FjdGlvbkluZGV4IjowLCJmcm9tIjoiMHgzOTlhOGNlODUzZjk2YmRmNzIzZTNjOWY5OGY1NDM4ZjA4ZGEyZWEwIiwidG8iOiIweDc5ODhiN2Y1YjE4NDVjODFkMjE3YWJhZjZlOWNlZmExODlkM2E3YmIiLCJ2YWx1ZSI6MCwiZ2FzUHJpY2UiOjMwMDAwMDAwMDAwMCwiZ2FzIjozMDAwMDAwMDAwMDAsImlucHV0IjoiMHhkMWIwNGI4MzAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwYzAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAxNzYzYzViZGJhMzAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAxNDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMTgwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDFjMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMjA2MTM4MzM2MjMyMzM2NTY0MzAzNjYzNjEzNDM4NjEzMzYyNjQzODY0NjI2NDM3NjU2NjMxMzUzNTYyNjE2MzYzMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAyMDYzMzc2MjYxMzczOTM0MzIzMzY2Mzk2MjM0NjM2MTYzNjIzNTY1MzI2NTY1MzUzMjY0MzAzNzY2MzUzODMzMzEwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDE3NzA2MTc5NmQ2NTZlNzQyZTYyNjM2ZjczMmU0ODY1NmM2YzZmNTc2ZjcyNmM2NDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMGI3MzY1NzQyODczNzQ3MjY5NmU2NzI5MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA2MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMjAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDBkNDg2NTZjNmM2ZjIwNTc2NTQzNzI2ZjczNzMwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMCIsImNyZWF0ZXMiOm51bGwsInB1YmxpY0tleSI6bnVsbCwicmF3IjpudWxsLCJyIjpudWxsLCJzIjpudWxsLCJ2IjowLCJub25jZVJhdyI6IjEzMDUwMDA2MzYxOTI1MzA0NDU0MTE0MjE5MDk0MDMyMTM0NzU3MjU1NDgyNjEzOTQ5MjgxODAxOTI1MjE5MTQxMjMyODI3MjA1NjgiLCJibG9ja051bWJlclJhdyI6IjE2NzMiLCJ0cmFuc2FjdGlvbkluZGV4UmF3IjoiMCIsInZhbHVlUmF3IjoiMCIsImdhc1ByaWNlUmF3IjoiMzAwMDAwMDAwMDAwIiwiZ2FzUmF3IjoiMzAwMDAwMDAwMDAwIn0=",
		"receiptBytes": "eyJ0cmFuc2FjdGlvbkhhc2giOiIweGJhOTM4MTEzYmRiYWU4ZTU3ZGNmNjhmOTZiMWVkZDM3ZjI4ODk1OWVjYzBlNTFjMGI0MDk5MDFjMjdkYWJhZmMiLCJ0cmFuc2FjdGlvbkluZGV4IjowLCJibG9ja0hhc2giOiIweGZjZTZkMzA0MTA3NzFjZDAyNDljMzQ5NzYwZDYyYjM4ZTk3YmZhYjU0NmRhNjAzMTY0Mzc2NWU5NmRhOTZkOGQiLCJibG9ja051bWJlciI6MTY3MywiZ2FzVXNlZCI6MTM4MzA1OCwiY29udHJhY3RBZGRyZXNzIjoiMHgwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwIiwicm9vdCI6IjB4ZTU5ZmU4Y2MzOGM1MTYwMjNlMjc2NTdkYmIwMWE3NzZiOTJhYWRlN2EyNzc1ZDQzN2E1OTRkZmYwMjM2MWE2NyIsInN0YXR1cyI6IjB4MCIsIm1lc3NhZ2UiOm51bGwsImZyb20iOiIweDM5OWE4Y2U4NTNmOTZiZGY3MjNlM2M5Zjk4ZjU0MzhmMDhkYTJlYTAiLCJ0byI6IjB4Nzk4OGI3ZjViMTg0NWM4MWQyMTdhYmFmNmU5Y2VmYTE4OWQzYTdiYiIsImlucHV0IjoiMHhkMWIwNGI4MzAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwYzAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAxNzYzYzViZGJhMzAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAxNDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMTgwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDFjMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMjA2MTM4MzM2MjMyMzM2NTY0MzAzNjYzNjEzNDM4NjEzMzYyNjQzODY0NjI2NDM3NjU2NjMxMzUzNTYyNjE2MzYzMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAyMDYzMzc2MjYxMzczOTM0MzIzMzY2Mzk2MjM0NjM2MTYzNjIzNTY1MzI2NTY1MzUzMjY0MzAzNzY2MzUzODMzMzEwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDE3NzA2MTc5NmQ2NTZlNzQyZTYyNjM2ZjczMmU0ODY1NmM2YzZmNTc2ZjcyNmM2NDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMGI3MzY1NzQyODczNzQ3MjY5NmU2NzI5MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA2MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMjAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDBkNDg2NTZjNmM2ZjIwNTc2NTQzNzI2ZjczNzMwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMCIsIm91dHB1dCI6IjB4MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAyMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAiLCJsb2dzIjpbXSwibG9nc0Jsb29tIjoiMHgwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMCIsInR4UHJvb2YiOm51bGwsInJlY2VpcHRQcm9vZiI6bnVsbH0="
	}
}
```

### startXATransaction
开始事务

#### 接口URL
> http://127.0.0.1:8250/xa/startXATransaction

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
    "version":"1",
    "data":{
        "xaTransactionID":"1c199e6d72744133992c139c3f12ba07",
        "paths":[
            "payment.fabric.mycc",
            "payment.bcos.HelloWorld"
        ]
    }
}
```

| 参数                 | 示例值                                             | 是否必填 | 参数描述           |
|:---------------------|:---------------------------------------------------|:---------|:-------------------|
| version              | 1                                                  | 必填     | 接口版本           |
| data.xaTransactionID | 1c199e6d72744133992c139c3f12ba07                   | 必填     | 事务ID             |
| data.paths           | ["payment.fabric.mycc", "payment.bcos.HelloWorld"] | 必填     | 参与事务的资源列表 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"status": 0,
		"chainErrorMessages": []
	}
}
```

### commitXATransaction
提交事务，注意：提交和回滚事务只需要传入参与该事务的区块链的路径就可以了，无需传入所有参与事务的资源

#### 接口URL
> http://127.0.0.1:8250/xa/commitXATransaction

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
	"version": "1",
	"data": {
		"xaTransactionID": "1c199e6d72744133992c139c3f12ba17",
		"paths": [
			"payment.fabric",
			"payment.bcos"
		]
	}
}
```

| 参数                 | 示例值                             | 是否必填 | 参数描述               |
|:---------------------|:-----------------------------------|:---------|:-----------------------|
| version              | 1                                  | 必填     | 接口版本               |
| data.xaTransactionID | 1c199e6d72744133992c139c3f12ba17   | 必填     | 事务ID                 |
| data.paths           | ["payment.fabric", "payment.bcos"] | 必填     | 参与该事务的区块链列表 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"status": 0,
		"chainErrorMessages": []
	}
}
```

### rollbackXATransaction
回滚事务，注意：提交和回滚事务只需要传入参与该事务的区块链的路径就可以了，无需传入所有参与事务的资源

#### 接口URL
> http://127.0.0.1:8250/xa/rollbackXATransaction

#### 请求方式
> POST

#### Content-Type
> application/json


#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
	"version": "1",
	"data": {
		"xaTransactionID": "1c199e6d72744133992c139c3f12ba08",
		"paths": [
			"payment.fabric",
			"payment.bcos"
		]
	}
}
```

| 参数                 | 示例值                             | 是否必填 | 参数描述               |
|:---------------------|:-----------------------------------|:---------|:-----------------------|
| version              | 1                                  | 必填     | 接口版本               |
| data.xaTransactionID | 1c199e6d72744133992c139c3f12ba08   | 必填     | 事务ID                 |
| data.paths           | ["payment.fabric", "payment.bcos"] | 必填     | 参与该事务的区块链列表 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"status": 0,
		"chainErrorMessages": []
	}
}
```

### listXATransactions
获取事务列表，结果根据事务的开启时间排序，同时返回是否已经获取完毕，以及下一次请求的偏移

#### 接口URL
> http://127.0.0.1:8250/xa/listXATransactions

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
	"version": "1",
	"data": {
		"size": 2,
		"offsets": {}
	}
}
```

| 参数         | 示例值 | 是否必填 | 参数描述                               |
|:-------------|:-------|:---------|:---------------------------------------|
| version      | 1      | 必填     | 接口版本                               |
| data.size    | 2      | 必填     | 获取的事务数量，最大为1024             |
| data.offsets | {}     | 必填     | 偏移量，如果是空则代表查询所有的区块链 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"xaList": [
			{
				"xaTransactionID": "1c199e6d72744133992c139c3f12ba08",
				"username": "shareong",
				"status": "rolledback",
				"timestamp": 1607333274,
				"paths": [
					"payment.bcos.HelloWorld",
					"payment.fabric.mycc"
				]
			},
			{
				"xaTransactionID": "1c199e6d72744133992c139c3f12ba17",
				"username": "shareong",
				"status": "committed",
				"timestamp": 1607332955,
				"paths": [
					"payment.bcos.HelloWorld",
					"payment.fabric.mycc"
				]
			}
		],
		"nextOffsets": {
			"payment.bcos": 15,
			"payment.fabric": 9
		},
		"finished": false
	}
}
```

### getXATransaction
根据事务ID获取事务详情

#### 接口URL
> http://127.0.0.1:8250/xa/getXATransaction

#### 请求方式
> POST

#### Content-Type
> application/json

#### 请求Header参数

| 参数          | 示例值           | 是否必填 | 参数描述              |
|:--------------|:-----------------|:---------|:----------------------|
| Content-Type  | application/json | 必填     | -                     |
| Authorization |                  | 必填     | login返回的credential |

#### 请求Body参数

```json
{
	"version": 1,
	"data": {
		"xaTransactionID": "1c199e6d72744133992c139c3f12ba10",
		"paths": [
			"payment.bcos",
			"payment.fabric"
		]
	}
}
```

| 参数                 | 示例值                             | 是否必填 | 参数描述               |
|:---------------------|:-----------------------------------|:---------|:-----------------------|
| version              | 1                                  | 必填     | 接口版本               |
| data.xaTransactionID | 1c199e6d72744133992c139c3f12ba10   | 必填     | 事务ID                 |
| data.paths           | ["payment.fabric", "payment.bcos"] | 必填     | 参与该事务的区块链列表 |

#### 成功响应示例
```json
{
	"version": "1",
	"errorCode": 0,
	"message": "Success",
	"data": {
		"xaList": [
			{
				"xaTransactionID": "1c199e6d72744133992c139c3f12ba08",
				"username": "shareong",
				"status": "rolledback",
				"timestamp": 1607333274,
				"paths": [
					"payment.bcos.HelloWorld",
					"payment.fabric.mycc"
				]
			},
			{
				"xaTransactionID": "1c199e6d72744133992c139c3f12ba17",
				"username": "shareong",
				"status": "committed",
				"timestamp": 1607332955,
				"paths": [
					"payment.bcos.HelloWorld",
					"payment.fabric.mycc"
				]
			}
		],
		"nextOffsets": {
			"payment.bcos": 15,
			"payment.fabric": 9
		},
		"finished": false
	}
}
```


