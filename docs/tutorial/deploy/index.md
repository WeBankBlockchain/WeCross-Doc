# 手动组网

你可以基于已有（或新部署）的区块链环境，搭建一个与[Demo](../demo/demo.md)相似的跨链网络。

![](../../images/tutorial/demo.png)

操作步骤分为以下4项：

- **[基础组件部署](./basic_env.md)**：部署WeCross基础组件，包括跨链路由、账户服务、控制台、网页管理台
- **[区块链接入与账户配置](./chains_config.md)**：将区块链接入WeCross跨链网络，并配置跨链账户
- **[资源部署与操作](./resources.md)**：基于搭建好的WeCross环境部署和操作跨链资源
- **[区块头验证配置](./security_config.md)**：配置区块头验证参数，完善跨链交易的验证逻辑

手动组网教程以`~/wecross-networks/`目录下为例进行:

``` bash
# 若已搭建WeCross Demo，请先关闭所有服务
cd ~/wecross-demo && bash stop_all.sh

# 创建手动组网的操作目录
mkdir -p ~/wecross-networks && cd ~/wecross-networks
```

```eval_rst
.. toctree::
   :hidden:
   :maxdepth: 1
   
   basic_env.md
   chains_config.md
   resources.md
   security_config.md
```
