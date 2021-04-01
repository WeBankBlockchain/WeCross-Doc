## 下载程序

### 下载WeCross

提供三种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

GitHub下载方式：

```shell
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_wecross.sh)
```

Gitee下载方式：

```shell
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_wecross.sh)
```

**方式2：命令下载（源码编译模式）**

GitHub下载方式：

```shell
# 默认下载master分支
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_wecross.sh) -s

# 下载特定版本下的
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_wecross.sh) -s -t v1.1.1
```

Gitee下载方式：

```shell
# 默认下载master分支
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_wecross.sh) -s

# 下载特定版本下的
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_wecross.sh) -s -t v1.1.1
```

**方式3：手动下载**

* 国内资源快速下载方式(CDN)：[点击下载](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/WeCross/v1.1.1/WeCross.tar.gz)，[MD5](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/WeCross/v1.1.1/WeCross.tar.gz.md5)

* [github release](https://github.com/WeBankBlockchain/WeCross/releases)（下载最新版本的 `WeCross.tar.gz`）

  手动下载后解压

  ```shell
  tar -zxvf WeCross.tar.gz
  ```

解压后，目录下包含`WeCross/`文件夹。

<hr>

### 下载WeCross控制台

同样提供三种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

GitHub下载方式：

```shell
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_console.sh)
```

Gitee下载方式：

```shell
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_console.sh)
```

**方式2：命令下载（源码编译模式）**

GitHub下载方式：

```shell
# 默认下载master分支
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_console.sh) -s

# 下载特定版本下的控制台
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_console.sh) -s -t v1.1.1
```

Gitee下载方式：

```shell
# 默认下载master分支
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_console.sh) -s

# 下载特定版本下的控制台
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_console.sh) -s -t v1.1.1
```

**方式3：手动下载**

- 国内资源快速下载方式(CDN)：[点击下载](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/WeCross-Console/v1.1.1/WeCross-Console.tar.gz)，[MD5](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/WeCross-Console/v1.1.1/WeCross-Console.tar.gz.md5)

- [github release](https://github.com/WeBankBlockchain/WeCross-Console/releases)（下载最新版本的 `WeCross-Console.tar.gz`）

  手动下载解压

  ```shell
  tar -zxvf WeCross-Console.tar.gz
  ```

下载后，目录下包含`WeCross-Console/`文件夹。

<hr>

### 下载WeCross Account Manager

同样提供三种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

GitHub下载方式：

```shell
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_account_manager.sh)
```

Gitee下载方式：

```shell
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_account_manager.sh)
```

**方式2：命令下载（源码编译模式）**

GitHub下载方式：

```shell
# 默认下载master分支，
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_account_manager.sh) -s

# 下载特定版本下的控制台
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_account_manager.sh) -s -t v1.1.1
```

Gitee下载方式：

```shell
# 默认下载master分支，
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_account_manager.sh) -s

# 下载特定版本下的控制台
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_account_manager.sh) -s -t v1.1.1
```

**方式3：手动下载**

- 国内资源快速下载方式(CDN)：[点击下载](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/WeCross-Account-Manager/v1.1.1/WeCross-Account-Manager.tar.gz)，[MD5](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/WeCross-Account-Manager/v1.1.1/WeCross-Account-Manager.tar.gz.md5)

- [github release](https://github.com/WeBankBlockchain/WeCross-Account-Manager/releases)（下载最新版本的 `WeCross-Account-Manager.tar.gz`）

  下载后执行命令

  ```shell
  tar -zxvf WeCross-Account-Manager.tar.gz # 解压
  cd WeCross-Account-Manager/conf # 进入
  mysql -u your_database_username -p < db_setup.sql # 配置数据库
  ```

下载后，目录下包含`WeCross-Account-Manager/`文件夹。


<hr>

### 下载WeCross Demo

同样提供两种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

GitHub下载方式：

```shell
# 下载最新demo
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_demo.sh)

# 下载特定版本下的demo
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_demo.sh) -t v1.1.1
```

Gitee下载方式：

```shell
# 下载最新demo
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_demo.sh)

# 下载特定版本下的demo
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_demo.sh) -t v1.1.1
```

**方式2：手动下载**

- 国内资源快速下载方式(CDN)：[点击下载](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/Demo/v1.1.1/demo.tar.gz)，[MD5](https://osp-1257653870.cos.ap-guangzhou.myqcloud.com/WeCross/Demo/v1.1.1/demo.tar.gz.md5)

- [github release](https://github.com/WeBankBlockchain/WeCross/releases)（下载最新release下的`demo.tar.gz`）

  手动下载解压

  ```shell
  tar -zxvf demo.tar.gz
  mv demo wecross-demo # 命名为wecross-demo目录
  ```

下载后，`wecross-demo/`目录即为WeCross Demo。
