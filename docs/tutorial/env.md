# 环境要求

## 硬件

WeCross负责管理多个Stub并与多条链通讯，同时作为Web Server提供RPC调用服务，为了能保证服务的稳定性，尽量使用推荐配置。

```eval_rst
+----------+---------+---------------------------------------------+
| 配置     | 最低配置| 推荐配置                                    |
+==========+=========+=============================================+
| CPU      | 1.5GHz  | 2.4GHz                                      |
+----------+---------+---------------------------------------------+
| 内存     | 4GB     | 8GB                                         |
+----------+---------+---------------------------------------------+
| 核心     | 4核     | 8核                                         |
+----------+---------+---------------------------------------------+
| 带宽     | 2Mb     | 10Mb                                        |
+----------+---------+---------------------------------------------+
```

## 支持的平台

- Ubuntu 16.04及以上
- CentOS 7.2及以上
- macOS 10.14及以上

## 软件依赖

WeCross作为Java项目，需要安装Java环境包括：

- JDK1.8.0_251以上，可参考[链接](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/sdk/java_sdk.html#id1)

目前已经覆盖测试的JDK版本：OracleJDK 1.8.0_251，OracleJDK 1.8.0_271，OracleJDK 14，OracleJDK 15，OpenJDK 1.8.0_282，OpenJDK 14，OpenJDK 15

- Gradle 5.0及以上
- MySQL 5.6及以上
  - [MySQL官方安装文档](https://dev.mysql.com/doc/mysql-installation-excerpt/5.7/en/)
  - [安装教程](https://www.runoob.com/mysql/mysql-install.html)

WeCross提供了多种脚本帮助用户快速体验，这些脚本依赖`openssl, curl, expect`，使用下面的指令安装。

```bash
# Ubuntu
sudo apt-get install -y openssl curl expect tree fontconfig

# CentOS
sudo yum install -y openssl curl expect tree

# macOS
brew install openssl curl expect tree md5sha1sum
```

运行WeCross Demo时，需安装

- Docker 17.06.2-ce 及以上
  - [Docker官方安装文档](https://docs.docker.com/engine/install/)
  - [Docker安装教程](https://www.runoob.com/docker/ubuntu-docker-install.html)
