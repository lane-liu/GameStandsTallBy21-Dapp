# 基本原理

### 区块链的基本原理的三个基本概念

​         交易(Transaction):一次对账本的操作，导致账本状态的一次改变，如添加一条转账记录

​          区块(Bolck)：记录一段时间内发生的所有交易和状态结果，是对当前账本状态的一次共识

​          链(Chain)：由区块安装发生顺序串联而成，是整个状态变化的日志

​          如果把区块链系统作为一个状态机制，则每次交易亦为之一次状态改变；生成的区块就是参与者对其中交易导致状态改变结果的共识

### 以比特币的工作流程理解区块链的工作过程

​         首先，用户通过比特币客户端发起一笔交易，消息广播道比特币网络中。网络中的节点会收到等待确认的消息打包在一起，添加上前一个区块的头部哈希值等信息。组成一个区块结构。然后试图找到一个nonce(特定随机的)串放到区块里，寻找nonce串的过程就是挖矿，nonce串的计算查找需要消耗一定的算力

​          一旦节点找到了满足条件的nonce串，这个区块在格式上就合法了，成为候选区块，节点将这个快在比特币网络中广播出去，其它节点收到候选区块后进行验证，发现确实合法，就承认这个区块是一个合法区块，直到大多数节点承认，也就意味着区块被网络接受，交易也就得到确认。

这里要考虑一个问题，也就是51%算力的问题

### 区块链的演化

数字货币           点对点现金系统            pow              公链       比特币网络

分布式应用平台   智能合约                pow、pos         公链      以太坊网络

带有权限的分布式账本   商业处理      多种共识          联盟链    超级账本

### 区块链技术分类

##### 公链 :任何人都可以参与是用和维护，典型的就是比特币和以太坊网络

##### 私链：由集中管理者管理，只有内部使用

##### 联盟链：联盟链介于两者之间，由若干组织一起合作维护一条区块链

### 研究与技术方向

##### 共识机制：

​       目前主流的共识算法：Pow Pos Dpos PBFT等不外乎解决分布式网络中每一改变在网络中得到一致的执行结果，是被多方都承认的，同时也是不可推翻的

因为在不同场合的不同需求诞生了基于概率的算法和确定性算两类思想

##### 性能提升：

​         主要提升TPS 也就是交易处理速度，就是因为区块链独特的共识机制决定了，每笔交易的速度不单单依靠网络整体的算力，更多的是依靠单个节点的性能，这从根本上限制了交易处理的速度，这个时候联盟链和eos通过设置超级节点的概念改善单个节点的性能，这样的做法确实提高了性能，却又从根本上违背了区块链的本质：去中心化，这导致用户不再信任网络中的其他节点

##### 安全问题：

​	区块链目前最热门的应用场景是金融相关的服务，安全自然是最敏感也是最具有挑战性的问题

##### 数据库和储存系统：

​	区块链网络中由大量的信息需要写到数据库中进行存储

​	而区块链的存储的环境与存储能力的恶劣，让我想到一个idea

​	我们是否可以通过构建一个智能合约式的数据库，通过区块链网络中的虚拟机在每个节点上运行，储存整个区块链上的数据

​	是否可以根据节点的个数，划分存储备份与储存条件，通过节点的合作构建一个完整的数据库

​	是否构建一个BolckSql，用来储存区块信息，就行NoSql一样

# 分布式系统的核心技术

### 一致性：

​           在分布式的服务网路中也是对各个节点的协调，让各个节点对服务的处理保持一致，而节点不同的性能，不同的处理环境都有可能导致时间的不一致，一致性的处理难度由此可见

### 共识算法    

​	   一致性是却多多个节点或副本对外一致的状态，而通常我们都通过共识算法来达成

​	  共识算法解决的是分布式系统对某个提案，大部分节点达成一直意见的过程。

​	  根据是否允许拜占庭错误的情况，共识算法可以分为CFT和BFT两类

通常伪造信息恶意响应被称为拜占庭错误，对应节点被称为拜占庭节点

##### 	CFT ：Paxos Raft等

##### 	 BFT：PBFT POW等

### FLP不可能原理

在区块链中的同步和异步问题

​	同步指相同时间片内完成某项操作

​	异步指不归顶时间，完成操作

### CAP原理

分布式系统无法同时确保一致性，可用性和分区容忍性

一致性：所有操作都是原子性，都是需要保持一致的

可用性: 系统能在相对较短时间被完成对操作请求的应答

分区容忍性：系统中网络可能发生的分区故障，既节点之间无法保证正常通信

CAP原理认为分布式系统最多智能保证三项特性中的两项

### ACID原则

### paxos与Raft算法

### 拜占庭问题与算法

# 密码学与安全技术

### 常见Hash算法（要注意，hash算法是不可逆的）

##### MD4与MD5

​	MD4的输出位为128位，已经被证明不安全

​	MD5比MD4更加安全与复杂   可MD5已经在2004被成功碰撞，也不安全

##### SHA

​	NITS制定了更加安全的SHA-224、SHA-256、SHA-512算法，统称SHA-2

​	SHA-3正在研发中

##### SM3

中国密码管理局与2010年发布了SM3国密Hash算法

##### 数字摘要是Hash函数重要的用途之一

利用Hash函数的抗碰撞特点，数字摘要可以检测内容是否被篡改

Hash算法用于加密容易被攻击

针对这些攻击可以采用加盐的方法，确保保持的不是直接原文的hash值

##### 对称加密 DES、3DES、ASE、IDEA

##### 非对称加密RSA、EIGamal、椭圆曲线算法



### 消息验证码与数字签名

##### 消息验证码（HMAC），利用对称加密，对消息完整性进行保护

基本过程为对某个消息，利用共享的对称密钥和Hash算法进行处理，得到Hash值，该HMAC值持有发可以向对方证明自己拥有某个对称密钥，并且确保所传输消息内容为被篡改

典型的HMAC生成算法包括K、H、M三个参数

K：为前提共享的对称密钥

H：为提前商定的Hash算法

M：为要传输的消息内容

##### 数字签名

发送信息时将内容摘要进行私钥加密，之后将内荣与摘要同时分析，接收者使用发送者的公钥对摘要进行揭秘，得到数字摘要，再对文件进行摘要，对比两个摘要判断文件是否被篡改

理论上所有非对称算法都可以实现数字签名

##### 多重签名

既n个签名中收集到m个的签名，即为合法

### 数字证书

### PKI体系