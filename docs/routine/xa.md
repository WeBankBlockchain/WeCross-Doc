# 两阶段事务

两阶段事务是分布式数据库和分布式系统中常见的事务模型，两阶段事务的架构中包含事务管理器和资源管理器等多个角色。

![](../images/xa/2pcarch.png)

在WeCross事务模型中，代理合约负责管理事务状态以及对资源的读写控制，事务管理器则由跨链路由实现。

用户通过使用WeCross SDK，可以让多个跨链路由和多个链上的资源参与事务，以保障对各个资源操作的原子性。

![](../images/xa/systemarch.png)

## 准备工作

无论何种智能合约或链码，参与基本的两阶段事务流程时不需要提前做修改。但如果要支持两阶段事务的**回滚操作**，参与事务的资源接口必须实现对应的**逆向接口**。

**正向接口示例**

以Solidity智能合约为例，原合约包含一个交易接口，如转账：
```solidity

function transfer(string memory from, string memory to, int balance) public {
// balance check...
    balances[from] -= balance;
    balances[to] += balance;
}

```

**注：** 案例省略了余额和透支检查的逻辑，只列出了正向交易接口的关键逻辑。

**逆向接口示例**

为了支持回滚，需实现一个逆向接口。逆向接口的参数与原交易接口相同，函数名增加`_revert`的后缀，表明这是一个用于两阶段事务回滚的接口。当两阶段事务需要回滚时，WeCross会自动执行Solidity合约的逆向接口。

参考实现如下：

```solidity
function transfer_revert(string memory from, string memory to, int balance) public {
  // balance check...
  balance[from] += balance;
  balance[to] -= balance;
}

```

可以看到，在相同输入参数的情况下逆向接口的行为和执行结果与正向接口相反，以恢复资源执行事务之前的状态。

## 原理说明

当开始事务时，参与事务的资源会被代理合约记录并锁定。之后的调用请求必须提供相应的事务ID才能被正确执行。代理合约还会保存事务中每一个执行步骤的资源、调用方法和参数列表。

WeCross回滚事务时，会按照正向接口执行的顺序，以相反的顺序调用逆向接口。举例，事务过程中执行了一系列正向交易接口如下：

```bash

transfer1('from1', 'to1', 100)
transfer2('from2', 'to2', 200)
transfer3('from3', 'to3', 300)

```

回滚时，WeCross会按以下顺序执行逆向交易接口：

```bash

transfer3_revert('from3', 'to3', 300)
transfer2_revert('from2', 'to2', 200)
transfer1_revert('from1', 'to1', 100)

```

## 使用

Java项目可通过调用Java-SDK的[事务相关接口](../dev/api.html#startxatransaction)实现事务操作，其它语言的项目可通过[JSON-RPC](../dev/rpc.html#startxatransaction)接口完成事务调用。

WeCross控制台也提供了事务相关的命令，操作示例如下：

**开始两阶段事务**

使用startTransaction命令，开始两阶段事务

```bash

startTransaction [path_1] ... [path_n]

```

参数解析：

- path_1 ... path_n: 参与事务的资源路径列表，路径列表中的资源会被本次事务锁定，锁定后仅限本事务相关的交易才能对这些资源发起读写操作，非本次事务的所有读写操作都会被拒绝

例子：

开始一个事务，资源为zone.chainA.res1、zone.chainB.res2

```bash

startTransaction zone.chainA.res1 zone.chainB.res2

```

### 发起事务交易

使用execTransaction命令，发起事务交易，execTransaction命令与sendTransaction命令类似。

任何资源一旦参与了事务，就无法用sendTransaction来向该资源发送交易，必须使用execTransaction

```bash

execTransaction [path] [method] [args]

```

参数解析：

- path：资源路径
- method：接口名，同sendTransaction
- args：参数，同sendTransaction

举例，通过控制台，调用transfer接口：

```bash
#调用事务资源zone.chainA.res1的transfer接口
execTransaction zone.chainA.res1 transfer 'fromUserName' 'toUserName' 100 

#调用事务资源zone.chainB.res2的transfer接口
execTransaction zone.chainB.res2 transfer 'fromUserName' 'toUserName' 200 
```

**注：** 单个事务的步骤不宜过多，否则在获取事务详情或者回滚事务时容易出现gas不足导致执行失败。

### 提交事务

使用commitTransaction命令，提交事务，确认事务执行过程中所有的变动。

```bash
# 控制台记录了该事务的上下文，因此提交的时候不需要传入参数
commitTransaction

```

通过控制台，执行一个完整的事务步骤

```bash
#开始事务
startTransaction zone.chainA.res1 zone.chainB.res2 

#调用事务资源zone.chainA.res1的transfer接口
execTransaction zone.chainA.res1 transfer 'fromUserName' 'toUserName' 100

#调用事务资源zone.chainB.res2的transfer接口
execTransaction zone.chainB.res2 transfer 'fromUserName' 'toUserName' 200 

#提交事务
commitTransaction 
```

### 回滚事务

当事务的某个步骤执行失败，需要撤销本次事务的所有变更时，使用rollbackTransaction命令

```bash
# 控制台记录了该事务的上下文，因此回滚的时候不需要传入参数
rollbackTransaction

```

举例，通过控制台，执行一个完整的事务步骤：

```bash

startTransaction zone.chainA.res1 zone.chainB.res2 #开始事务

# 调用事务资源zone.chainA.res1的transfer接口
execTransaction zone.chainA.res1 transfer 'fromUserName' 'toUserName' 100 

# 调用事务资源zone.chainB.res2的transfer接口，假设失败，则事务需要回滚
execTransaction zone.chainB.res2 transfer 'fromUserName' 'toUserName' 200 

# 回滚事务
rollbackTransaction
```
