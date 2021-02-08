# 区块头验证配置


可在WeCross跨链路由端设定其他远端路由接入的区块链配置信息，遵循“谁配置，谁验证”的原则。

用户在连接BCOS和Fabric链的Router端可配置Fabric链各个Org Peer的CA证书和Orderer 的CA证书，以及BCOS链各个节点的公钥，用于验证对应链发来的区块。当在配置中未做该链的配置，则默认为不验证这个链的区块。

若要配置验证逻辑，需要在跨链路由的`conf`目录下新增配置文件`verifier.toml`（和`wecross.toml`在相同目录）。

这里以[混合场景](../demo/demo_cross_all.html)部署的网络作为举例，配置如下所示（请以实际情况配置）：

```toml
[verifiers]
    [verifiers.payment.bcos-group1]
        chainType = 'BCOS2.0'
        # 填写所有共识节点的公钥
        pubKey = [
            'b949f25fa39a6b3797ece30a2a9e025...',
            '...'
        ]
    [verifiers.payment.bcos-group2]
        chainType = 'BCOS2.0'
        # 填写所有共识节点的公钥
        pubKey = [
            'b949f25fa39a6b3797ece3132134fa3...',
            '...'
        ]
    [verifiers.payment.bcos-gm]
        chainType = 'GM_BCOS2.0'
        pubKey = [
            'ecc094f00b11a0a5cf616963e313218...'
        ]
    [verifiers.payment.fabric-mychannel]
        chainType = 'Fabric1.4'
        # 填写所有机构CA的证书路径
        [verifiers.payment.fabric-mychannel.endorserCA]
            Org1MSP = 'classpath:verifiers/org1CA/ca.org1.example.com-cert.pem'
            Org2MSP = 'classpath:verifiers/org2CA/ca.org2.example.com-cert.pem'
        [verifiers.payment.fabric-mychannel.ordererCA]
            OrdererMSP = 'classpath:verifiers/ordererCA/ca.example.com-cert.pem'
```

配置详情请查看 [区块头验证配置](../../manual/config.html)。
