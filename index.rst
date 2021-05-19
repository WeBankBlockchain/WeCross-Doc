##############################################################
WeCross 技术文档
##############################################################

.. image:: _static/images/menu_logo_wecross.svg
   :height: 60px
   :width: 300px

WeCross是由微众银行自主研发并完全开源的区块链跨链协作平台，支持应用与多链互操作、同/异构链间互操作等多维跨链交互。

- `Github主页 <https://github.com/WeBankBlockchain/WeCross>`_
- `Gitee主页 <https://gitee.com/WeBank/WeCross>`_
- `深度解析系列文章 <https://mp.weixin.qq.com/mp/appmsgalbum?action=getalbum&album_id=1337945984353107969&__biz=MzU0MDY4MDMzOA==#wechat_redirect>`_
- `贡献代码 <https://github.com/WebankBlockchain/WeCross/wiki/%E8%B4%A1%E7%8C%AE%E4%BB%A3%E7%A0%81>`_
- `反馈问题 <https://github.com/WeBankBlockchain/WeCross/issues/new/choose>`_
- `微信群 <https://github.com/WeBankFinTech/WeCross/raw/master/docs/images/assistant.png>`_
- `公众号 <https://github.com/WeBankFinTech/WeCross/raw/master/docs/images/account.png>`_


.. admonition:: 概览

    - 系统推荐配置以及软件依赖，请参考 `环境要求 <./docs/tutorial/env.html>`_
    - 快速体验WeCross，请参考 `BCOS-Fabric Demo <./docs/tutorial/demo/demo.html>`_
    - `网页管理平台 <./docs/manual/webApp.html>`_：**可视化跨链管理台**，账户注册与登录，跨链资源管理，跨链交易管理等
    - `终端控制台 <./docs/manual/console.html>`_：**交互式命令行工具**，部署和调用跨链资源，发起跨链事务等
    - `Java-SDK <./docs/dev/sdk.html>`_：提供访问跨链跨链、调用跨链资源的接口
    - JSON-RPC接口，请参考 `JSON-RPC API <./docs/dev/rpc.html>`_

.. admonition:: 关键特性

    - 合约跨链: `使用手册 <./docs/dev/interchain.html>`_  
    - 跨链事务: `使用手册 <./docs/routine/xa.html>`_ 
    - 跨链转账: `使用手册 <./docs/routine/htlc.html>`_ 

.. toctree::
   :maxdepth: 1
   :caption: 平台介绍

   docs/introduction/introduction.md
   docs/version/index.rst

.. toctree::
   :maxdepth: 1
   :caption: 教程

   docs/tutorial/env.md
   docs/tutorial/demo/index.md
   docs/tutorial/deploy/index.md

.. toctree::
   :maxdepth: 1
   :caption: 跨链操作

   docs/stubs/index.rst
   docs/routine/index.rst

.. toctree::
   :maxdepth: 1
   :caption: 操作手册

   docs/manual/webApp.md
   docs/manual/console.md
   docs/manual/account.md
   docs/manual/scripts.md
   docs/manual/config.md

.. toctree::
   :maxdepth: 1
   :caption: 开发手册

   docs/dev/sdkindex.rst
   docs/dev/interchain.md
   docs/dev/stub.md
   docs/dev/rpc.md

.. toctree::
   :maxdepth: 1
   :caption: 参考

   docs/scenarios/index.rst
   docs/faq/faq.md
   docs/community/index.rst
   docs/community/family.md
