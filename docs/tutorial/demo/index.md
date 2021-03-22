# 快速体验

我们提供跨链Demo帮助用户快速体验并理解WeCross的原理，如果想搭建WeCross并**接入已有区块链**，请参考[手动组网](../deploy/index.md)。

**下载 Demo**

执行命令下载Demo，若下载较慢，可选择[更多下载方式](../../version/download.html#wecross-demo)。

``` bash
cd ~
# 下载WeCross demo合集，生成wecross-demo目录，目录下包含各种类型的demo
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_demo.sh)

# 若出现长时间下载Demo包失败，请尝试以下命令重新下载：
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_demo.sh)
```

```eval_rst
.. note::
    - macOS用户若出现“无法打开”，“无法验证开发者”的情况，可参考 `FAQ问题3 <../../faq/faq.html#id3>`_ 的方式解决
```

**Demo 场景**

1. Demo：[混合场景（Fabric、FISCO BCOS 国密非国密、多群组）](demo_cross_all.md)
2. Demo：[跨平台 FISCO BCOS & Fabric](demo.md) 

   * [跨链资源操作](./demo.html#id2)
   * [跨链转账（HTLC）](./demo.html#id3)

   * [跨链存证（2PC）](./demo.html#id4)
3. Demo：[跨多群组](demo_cross_groups.md)
4. Demo：[跨国密、非国密](demo_cross_gm.md)

实际情况下，WeCross的场景不仅限于两条链，用户可配置接入多条各种类型的区块链。

```eval_rst
.. toctree::
   :hidden:
   :maxdepth: 1
   
   demo_cross_all.md
   demo.md
   demo_cross_groups.md
   demo_cross_gm.md
```

