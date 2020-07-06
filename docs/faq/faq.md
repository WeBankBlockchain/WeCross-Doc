# FAQ

## 问题1

下载速度太慢，下不下来。

**回答**

我们提供了多种下载方式，[点击此处查看](../version/download.md)。

## 问题2

在搭建Demo时报错

``` 
========== ERROR !!! FAILED to execute End-2-End Scenario ==========

ERROR !!!! Test failed
```

**回答**

Fabric 的demo和机器上的Fabric网络冲突了，尝试用demo目录下的`clear.sh`用脚本清理机器上已有的Fabric网络。

## 问题3

在部署demo时，**MacOS用户**若出现“**无法打开**”，“**无法验证开发者**”的情况。

**回答**

MacOS对下载的包权限要求较为严格，必须同一个进程下载的才可执行，可采用如下方法解决：

``` bash 
# 清理环境
cd ~/demo/ && bash clear.sh && cd ~ && rm -rf demo
# 将三个步骤的命令拼成一条命令执行
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh) && cd demo && bash build.sh
```

