## 下载程序

### 下载WeCross

提供三种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

``` shell
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_wecross.sh)
```

**方式2：命令下载（源码编译模式）**

``` shell
# 默认下载master分支
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_wecross.sh) -s

# 下载特定版本下的
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_wecross.sh) -s -t v1.0.0-rc3
```

**方式3：手动下载**

* 国内资源：[点击下载](https://www.fisco.com.cn/cdn/wecross/releases/download//v1.0.0-rc3/WeCross.tar.gz)，[MD5](https://www.fisco.com.cn/cdn/wecross/releases/download//v1.0.0-rc3/WeCross.tar.gz.md5)

* [github release](https://github.com/WeBankFinTech/WeCross/releases)（下载最新版本的 `WeCross.tar.gz`）

  手动下载后解压

  ``` shell
  tar -zxvf WeCross.tar.gz
  ```

解压后，目录下包含`WeCross/`文件夹。

<hr>

### 下载WeCross控制台

同样提供三种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

```shell
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_console.sh)
```

**方式2：命令下载（源码编译模式）**

```shell
# 默认下载master分支
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_console.sh) -s

# 下载特定版本下的控制台
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_console.sh) -s -t v1.0.0-rc3
```

**方式3：手动下载**

- 国内资源：[点击下载](https://www.fisco.com.cn/cdn/wecross-console/releases/download//v1.0.0-rc3/WeCross-Console.tar.gz)，[MD5](https://www.fisco.com.cn/cdn/wecross-console/releases/download//v1.0.0-rc3/WeCross-Console.tar.gz.md5)

- [github release](https://github.com/WeBankFinTech/WeCross-Console/releases)（下载最新版本的 `WeCross-Console.tar.gz`）

  手动下载解压

  ```shell
  tar -zxvf WeCross-Console.tar.gz
  ```

下载后，目录下包含`WeCross-Console/`文件夹。

<hr>

### 下载WeCross Demo

同样提供两种方式，根据网络环境选择合适的方式进行下载。

**方式1：命令下载**

```shell
# 下载最新demo
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh)

# 下载特定版本下的demo
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh) -t v1.0.0-rc3
```

**方式2：手动下载**

- 国内资源：[点击下载](https://www.fisco.com.cn/cdn/wecross/releases/download/v1.0.0-rc3/demo.tar.gz)，[MD5](https://www.fisco.com.cn/cdn/wecross/releases/download/v1.0.0-rc3/demo.tar.gz.md5)

- [github release](https://github.com/WeBankFinTech/WeCross/releases)（下载最新release下的`demo.tar.gz`）

  手动下载解压

  ```shell
  tar -zxvf demo.tar.gz
  ```

下载后，目录下包含`demo/`文件夹。

