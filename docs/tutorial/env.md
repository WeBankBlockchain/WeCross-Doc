# 环境要求

## 硬件

WeCross负责管理多个Stub并与多条链通讯，同时作为Web Server提供RPC调用服务，为了能保证服务的稳定性，尽量使用推荐配置。

```eval_rst
+----------+---------+---------------------------------------------+
| 配置     | 最低配置| 推荐配置                                    |
+==========+=========+=============================================+
| CPU      | 1.5GHz  | 2.4GHz                                      |
+----------+---------+---------------------------------------------+
| 内存     | 1GB     | 8GB                                         |
+----------+---------+---------------------------------------------+
| 核心     | 1核     | 4核                                         |
+----------+---------+---------------------------------------------+
| 带宽     | 1Mb     | 10Mb                                        |
+----------+---------+---------------------------------------------+
```

## 支持的平台

- Ubuntu 16.04
- CentOS 7.2+
- MacOS 10.14+

## 软件依赖

WeCross作为Java项目，需要安装Java环境包括：
- [JDK8及以上](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/sdk/sdk.html#id1)
- Gradle 5.0及以上

WeCross提供了多种脚本帮助用户快速体验，这些脚本依赖`openssl, curl, expect`，使用下面的指令安装。

```bash
# Ubuntu
sudo apt-get install openssl curl expect

# CentOS
sudo yum install openssl curl expect

# MacOS
brew install openssl curl expect
```
