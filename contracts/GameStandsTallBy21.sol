pragma solidity ^0.4.17;
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract GameStandsTallBy21{
    	using SafeMath for *;

    // 基于21点的玩法设置游戏逻辑：即用户可以无限的要筛子，一直到他的点数大于21点，
    // 每一个筛子都需要一定的价值去购买，并将购买的值设置进去这个单注的奖池中

    // 首先我们设置了期数，每期12个小时，每期开奖后进入下一期，并重置所有奖池
	// 我们设置两种模式一个是抽奖一个是两两匹配，用户只有通过两两匹配才能参与抽奖
    // 为两两匹配设置了十注的带匹配奖池，当带匹配奖池十注满了以后，其他用户只能去
    // 奖池注中选择一注去匹配对战，当匹配成功，这个奖池注从奖池中剔除，并且此时用户就可以重新去抢占奖池注。
    // 总奖池就是对所有单个奖池注的值进行抽去一个值，12小时开奖
    // 开奖值的一样者平分总奖池的80%，20%给与合约开发者，在总奖池开奖前，如果十注奖池中还有注，就将他们匹配，获胜者获取这个奖池的60%（如果有多个，就平分），30%冲入总奖池，10%给与开发者；
    
    // 单个奖池注的生成规则：每次生成奖池注都需要用户去掷色子，每个筛子都需要购买，并且购买筛子的钱填充到当前奖池注中，
    // 每次购买筛子的花费是前一个筛子的1.15倍，第一个筛子的价格是0.001个ether，用户可以一直购买筛子并掷出，直到不想要了，
    // 确定发售，或者大于21点爆炸
	// 用户和单个奖池注进行匹配也需要去购买筛子掷在，匹配过程中，自身相当于生成一个奖池注，最终到不想要提交或者爆炸。
    // 在对两注奖池注进行比较判断输赢。
	// 输赢转账规则：当主动匹配用户获胜以后，如果自身奖池低于被匹配奖池，那么他只能获取和自己相等的部分，多余的将会返回
    // 给被匹配者，赢得的部分用户可以获取总额的80%,15%g给与合约维护者，5%可以进入每期的总奖池，如果点数相同，比较筛子的个数，
    // 个数多个获胜，获胜的用户可以获取总额的80%,15%g给与合约维护者，5%可以进入每期的总奖池，如果点数相同，个数也相同，那么占位者获胜
    // 占位者特权，不管匹配者的奖池大小，只要匹配者输了，输掉全部奖池，占位者输了，只有当匹配者奖池大于占位者，才能获取全部奖池
    //合约拥有者 
    address owner;
    //合约管理者 
    address admin;
    //期数
    uint256 public round ;
    //色子单价
    uint256 public oneDicePrice;
    //总奖池
    uint256 public overallBalance;
    //总奖池上限 
    uint256 public overallBalanceUplimit;
    //总奖池key的获取：每一注21点都是key  
    
     //筛子的等级
    uint256 dicelevel;

    //开奖信息
    struct winInfo{
            uint8 rbykey;
            uint256 rbyoverallBalance;
            uint256 rbykeyonprice;
    }

    //每期开奖信息
    winInfo[] public everyrbywinInfo;
    //每期对应的所有用户
    mapping(
        uint256=>mapping(address=>playerStr)
        )private
         everyrbypalyerstrInfo;
    //当前所有的用户
    address[] trbyplayeradrr;
    //当期的所有用户对应的用户信息
    mapping(address=>playerStr) public trbyplayerStrs;
    //用户结构
    struct playerStr{
            //用户当前权重 为1 10 100 代表权重
            uint8 weight;
            //用户当前的点数 
            uint8 thisrbykey;
            //当前奖池大小
            uint256 PriceSize;
            //当前使用色子的个数
            uint8 dicemul;
            //当前色子的价格 
            uint256 dicesize;
            //用于锁定时间
            uint lockingTime; 
            //用于处理随机数
            uint randNonce; 
            //随机数
            uint8 random; 
            //所有色子的点数
            uint8[] randoms;
            //所有点数
            uint8 [] thisrbykeys;
            //所有奖池大小大小
            uint256 [] PriceSizes;
             //所有色子的个数
            uint8 [] dicemuls;
            // size => howmany 点数大小=》该点数出现的次数(次数 1倍一次 10倍10次 百倍100次) 用于开奖
            mapping(uint8=>uint256) sizebyhowmany;
            //是否提交
            bool issubmit;
            //是否占位  
            bool isinherent;
            //是否匹配
            bool ismatching;

    }
    //key=>Allkey
    mapping(uint8=>uint256) private Allkey;
    //抢占位  权重（倍数）=> 下标（index）=> 用户信息  private
    mapping(uint8=>mapping(uint8=>playerStr)) private inherent10Info;
    //抢占位地址状态 权重（倍数）=> 下标（index）=> 地址 private
    mapping(uint8=>mapping(uint8=>address)) private inherent10addrstate;
    //抢占位匹配状态 权重（倍数）=> 下标（index）=> bool private
    mapping(uint8=>mapping(uint8=>bool)) private inherent10matchingstate; 
    //抢占位匹配地址  权重（倍数）=> 下标（index）=> address private
    mapping(uint8=>mapping(uint8=>address)) private inherent10matchingaddr; 
    // //一倍十个抢占位 index=>playerStr
    // mapping(
    //     uint256 =>mapping(address=>playerStr)
    //     ) inherent10oneInfo;
    // //抢占位状态
    // mapping(uint256=>address)inherent10onestate;    
    // //十倍十个抢占位
    //  mapping(
    //     uint256 =>mapping(address=>playerStr)
    //     ) inherent10tenInfo;
    //     //抢占位状态
    //     mapping(uint256=>address)inherent10tenstate;
    // //百倍十个抢占位
    //  mapping(
    //    uint256 =>mapping(address=>playerStr)
    //     ) inherent10hundredInfo;
    //     //抢占位状态
    //  mapping(uint256=>address)inherent10hundredstate;
    //构造函数
    constructor() public{
        owner=msg.sender;
        oneDicePrice=0.001 ether;
        round=1;
        overallBalanceUplimit=0.001 ether;

    }

    //合约拥有者权限
    modifier OnlyOwner(){
        require(msg.sender==owner);
        _;
    }
    //合约管理者权限
    modifier OnlyAdmin(){
        require(msg.sender==owner||msg.sender==admin);
        _;
    }

    //合约拥有者授予管理权限
    function setAdmin(address _adm) 
        OnlyOwner()
        external{
            admin=_adm;
    }
   

    //两两开奖事件
    //总奖池开奖事件

  
    
     //生成一个骰子(1-6)
    function Dice(address challenger,uint8 den) internal {
        playerStr storage player = trbyplayerStrs[challenger];
        player.random = uint8(keccak256(abi.encodePacked(now, msg.sender, player.randNonce)))%den+1;
        player.randNonce.add(1);
    }

    //购买色子 计算这次色子产生的随机值，并将这个值返回给用户，同时需要在用户信息中存储当前奖池注的变化，如果炸掉自动开奖
    function BuyDice(uint8 weight,uint8 index) public payable {
        require(trbyplayerStrs[msg.sender].isinherent==true||trbyplayerStrs[msg.sender].ismatching==true);
        require(inherent10addrstate[weight][index]==msg.sender||inherent10matchingaddr[weight][index]==msg.sender);
        playerStr storage player = trbyplayerStrs[msg.sender];
        //判断骰子是否被锁
        require(msg.value==player.dicesize*weight);
        require(now <= (player.lockingTime + 5 minutes));
        //判断点数不能大于21不是第一次购买 
        require(player.thisrbykey <= 21&&player.thisrbykey!=0);
        require(msg.value==player.dicesize*weight);
            //更新锁定时间
            player.lockingTime = now;
            //生成一个骰子(1-6)
            Dice(msg.sender,6);
            //重构用户信息
            player.weight = weight;
            uint256 temp=player.dicesize;
            player.randoms.push(player.random);
            player.thisrbykey = player.thisrbykey + player.random;
            player.PriceSize = player.PriceSize + oneDicePrice;
            player.dicemul = uint8(player.dicemul.add(1));
            player.dicesize = temp.add(temp.div(2));
        if(inherent10addrstate[weight][index]==msg.sender){
            inherent10Info[weight][index]=player;
        }
       
    }
    //默认第一次购买 
     function Placeholder(address placeholder, uint8 weight, uint8 index) internal {
        playerStr storage player = trbyplayerStrs[placeholder];
        //默认购买一个骰子
        //更新锁定时间
        player.lockingTime = now;
        //生成一个骰子(1-6)
        Dice(placeholder,6);
        //重构用户信息
        player.weight = weight;
        player.thisrbykey = player.random;
        player.PriceSize = oneDicePrice;
        player.dicemul = 1;
        player.randoms.push(player.random);
        player.dicesize =oneDicePrice.add(oneDicePrice.div(2));
        if(inherent10addrstate[weight][index]==msg.sender){
            inherent10Info[weight][index] = player;
        }
        
    }
    
    //两两匹配开奖
    function matchingdraw(address _inherent,address _match,uint8 _weight,uint8 index) private                                                                                                                                                                                                                                                                                                                                                                                       {
        require(_inherent!=_match);
        require(inherent10addrstate[_weight][index]==_inherent);
        playerStr memory _inherentplayer=inherent10Info[_weight][index];
        playerStr memory _matchplayer=trbyplayerStrs[_match];
        require(_inherentplayer.issubmit==_matchplayer.issubmit==true);
        uint8 keyone=_inherentplayer.thisrbykey;
        uint8 keytwo=_matchplayer.thisrbykey;
        require(keyone!=0&&keytwo!=0);
        uint256 allprice=_inherentplayer.PriceSize.add(_matchplayer.PriceSize);
        if(keyone.sub(keytwo)>0){
            winTransfer(allprice,_inherent);
        }
        else if(keyone.sub(keytwo)==0){
              if(_inherentplayer.dicemul.sub(_matchplayer.dicemul)<0){
                      winTransfer(allprice,_inherent);
              }else{
                      winTransfer(allprice,_match);
              }  
        }
        else{
                uint256 isresidue= _inherentplayer.PriceSize.sub(_matchplayer.PriceSize);
                  if(isresidue>0){
                      allprice=_matchplayer.PriceSize.mul(2);
                      _inherent.transfer(isresidue);
                      winTransfer(allprice,_match);
                  }else{
                      winTransfer(allprice,_match);
                  }
        }
      wincleardata(_inherent,_match,_weight,index);
      if(overallBalance>=overallBalanceUplimit){
        overalldraw();
        }
    }
    
   //奖金结算 
    function winTransfer(uint256 allprice,address winaddr) private{
            uint256 winprice=allprice.mul(80).div(100);
            uint256 winownerpricae=allprice.mul(5).div(100);
            winaddr.transfer(winprice);
            overallBalance+=(allprice.mul(15).div(100));
            owner.transfer(winownerpricae);
    }
   
    //两两开奖数据清洗
    function wincleardata(address _inherent,address _match,uint8 _weight,uint8 index) private{
        clearPosition(index,_weight);
        //更新玩家数据
        updateplayer(_inherent);
        updateplayer(_match);
       
    }
    //更新数据  
    function updateplayer(address _addr) private{
        playerStr storage player= trbyplayerStrs[_addr];
        player.thisrbykeys.push(player.thisrbykey);
        player.PriceSizes.push(player.PriceSize);
        player.dicemuls.push(player.dicemul);
        player.sizebyhowmany[player.thisrbykey]+=player.weight;
        Allkey[player.thisrbykey]+=player.weight;
        player.weight=0;
        player.thisrbykey=0;
        player.dicemul=0;
        player.dicesize=0;
        player.lockingTime=0;
        player.randNonce=0;
        player.random=0;
        player.issubmit=false;
        uint8[] memory s1;
        player.randoms=s1;
        everyrbypalyerstrInfo[round][_addr]=player;
        playerStr memory p1;
        trbyplayerStrs[_addr]=p1;
    }

   

    //出位置,只为pk（本方法是出位置为了其它的方法）
    //seatNumber位子roomNum房间号
    //清除位置数据 
    function clearPosition(uint8 seatNumber,uint8 roomNum)private{
        //找到房间的对应位置的address设为0
       require(inherent10addrstate[roomNum][seatNumber]!=address(0));
       inherent10addrstate[roomNum][seatNumber]=address(0);
       inherent10matchingstate[roomNum][seatNumber]=false;
       inherent10matchingaddr[roomNum][seatNumber]=address(0);
        //新建一个playerStr
        playerStr memory  pl;
       inherent10Info[roomNum][seatNumber]=pl;
      
    }
    
    //   //抢占位  权重（倍数）=> 下标（index）=> 用户信息  
    // mapping(uint8=>mapping(uint8=>playerStr)) private inherent10Info;
    // //抢占位地址状态 权重（倍数）=> 下标（index）=> 地址
    // mapping(uint8=>mapping(uint8=>address)) private inherent10addrstate;
    // //抢占位匹配状态 权重（倍数）=> 下标（index）=> bool
    // mapping(uint8=>mapping(uint8=>bool)) private inherent10matchingstate; 
    // //抢占位匹配地址  权重（倍数）=> 下标（index）=> address
    // mapping(uint8=>mapping(uint8=>address)) private inherent10matchingaddr; 
        //占位置
    //seatNumber//位子序号, roomNum//房间序号代表权重, periodsNum//期数
    function takePosition(uint8 seatNumber,uint8 roomNum)public payable returns(uint8 random,uint8 weight_ ,uint8 index_){
      require(roomNum==1||roomNum==10||roomNum==100);
      require(seatNumber>0&&seatNumber<=10);
      require(trbyplayerStrs[msg.sender].isinherent==false);
      trbyplayerStrs[msg.sender].isinherent=true;
      require(oneDicePrice *roomNum==msg.value);
        ////找到房间的对应位置的address,并判断是否为空
      require(inherent10addrstate[roomNum][seatNumber]==address(0)&&
      inherent10matchingaddr[roomNum][seatNumber]==address(0)&&
      inherent10matchingstate[roomNum][seatNumber]==false);
       //将房间号对应位子序号对应地址（既是用户mapping映射完全）
      inherent10addrstate[roomNum][seatNumber]=msg.sender;
      inherent10matchingstate[roomNum][seatNumber]=true;
      //添加到当前所有用户
      trbyplayeradrr.push(msg.sender);
      Placeholder(msg.sender,roomNum,seatNumber);
       index_=seatNumber;
       weight_=roomNum;
       random=trbyplayerStrs[msg.sender].random;
    }

    //匹配，外来者相匹配位子上面的人
    function matchingPosition(uint8 seatNumber,uint8 roomNum)public payable returns(uint8 random,uint8 weight_ ,uint8 index_){
       require(roomNum==1||roomNum==10||roomNum==100);
       require(seatNumber>0&&seatNumber<=10);
       require(trbyplayerStrs[msg.sender].ismatching==false);
       trbyplayerStrs[msg.sender].ismatching=true;
        require(oneDicePrice *roomNum==msg.value);
        //找到房间的对应位置的上面的人是否被匹配了
       require(inherent10matchingstate[roomNum][seatNumber]!=false);
       require(inherent10addrstate[roomNum][seatNumber]!=address(0));
       //判断挑战者是不是占位者自己
       require(msg.sender != inherent10addrstate[roomNum][seatNumber]);
        //挑战者入挑战位
        inherent10matchingaddr[roomNum][seatNumber]=msg.sender;
        //挑战者入所有玩家
        trbyplayeradrr.push(msg.sender);
        //挑战者购买骰子
        Placeholder(msg.sender,roomNum,seatNumber);
        index_=seatNumber;
        weight_=roomNum;
        random=trbyplayerStrs[msg.sender].random;
    }
    //占位者提交
    function inherentsubmit(uint8 seatNumber,uint8 roomNum) public returns(bool){
       playerStr storage player=inherent10Info [roomNum][seatNumber];
       require( player.issubmit!=true);
       return player.issubmit=true;
    }
    
    //匹配者提交
    function matchingsubmit(uint8 seatNumber,uint8 roomNum) payable public{
        playerStr storage player=trbyplayerStrs[msg.sender];
         require( player.issubmit!=true);
        player.issubmit=true;
        address _inherent=inherent10addrstate[roomNum][seatNumber];
        require(_inherent!=address(0));
        matchingdraw(_inherent,msg.sender,roomNum,seatNumber);
    }

   
    //总奖池开奖
    function overalldraw() private{
        require(overallBalance>=overallBalanceUplimit);
        uint8 key= uint8(keccak256(abi.encodePacked(now, msg.sender, overallBalance)))%21+1;
        uint256 onkeyprice=Allkey[key];
        everyrbywinInfo[round].rbykeyonprice=onkeyprice;
        everyrbywinInfo[round].rbyoverallBalance=overallBalance;
        everyrbywinInfo[round].rbykey=key;
        round++;
        if(roundbyonediceprice[round]!=0){
            oneDicePrice=roundbyonediceprice[round];
        }
        if(roundbyallbalanceuplimit[round]!=0){
            overallBalanceUplimit=roundbyallbalanceuplimit[round];
        }
    }        
    //总奖池提奖
    function drawmoneybyround(uint256 _round,uint256 _balance) external{
        uint8 key_;
        uint256 oneprice_;
        uint256 allbalance_;
        uint256 allkeys_;
       (key_, oneprice_, allbalance_,allkeys_)= iswinbyallbalance(_round);
       require(allkeys_!=0);
       require(allbalance_>=_balance);
       uint256 residuesize=allkeys_.sub(_balance.div(oneprice_));
       everyrbypalyerstrInfo[_round][msg.sender].sizebyhowmany[key_]=residuesize;
       msg.sender.transfer(_balance);
    }
    
    //总奖池中奖查询 
    function iswinbyallbalance(uint256 _round) public view returns(uint8 key_,uint256 oneprice_,uint256 allbalance_,uint256 allkeys_){
        key_=everyrbywinInfo[_round].rbykey;
        oneprice_=everyrbywinInfo[_round].rbykey;
        allkeys_=everyrbypalyerstrInfo[_round][msg.sender].sizebyhowmany[key_];
        allbalance_=allkeys_.mul(oneprice_);
    }
    
    //设置色子的单价 管理员和合约拥有着都可以设置 合约
    mapping(uint256=>uint256) private roundbyonediceprice;
    function setOneDicePrice(uint256 _price) external OnlyAdmin{
        uint256  round_=round;
        round_++;
        roundbyonediceprice[round_]=_price;
    }
    
    //设置总奖池上限
    mapping(uint256=>uint256) private roundbyallbalanceuplimit;
    function setoverallBalanceUplimit(uint256 _price) external OnlyAdmin{
         uint256  round_=round;
         round_++;
         roundbyallbalanceuplimit[round_]=_price;
    }

    //根据期数查询某一期的总奖池开奖信息
     function queryeveryrbywinInfobyround(uint256 _round) view public returns(uint8 key_,uint256 allbalance_,uint256 oneprice_){
         key_=everyrbywinInfo[_round].rbykey;
         allbalance_=everyrbywinInfo[_round].rbyoverallBalance;
         oneprice_=everyrbywinInfo[_round].rbykeyonprice;
     }
    //用户查寻每期所有的key and pricesize
    function queryallkeyandallpricesizebyround(uint256 _round) public view returns(uint8[] keys_,uint256[] priceSizes_){
        keys_=everyrbypalyerstrInfo[_round][msg.sender].thisrbykeys;
        priceSizes_=everyrbypalyerstrInfo[_round][msg.sender].PriceSizes;
    }
    
    //call site 的状态
    function callsite(uint8 weight,uint8 index) public view returns(address playaddr,uint256 balance,uint8 weight_,uint8 index_){
        playaddr=inherent10addrstate[weight][index];
        balance=inherent10Info[weight][index].PriceSize;
        weight_=weight;
        index_=index;
    }
    // 当前匹配或占领用户查询自己信息
    function callinherent(uint8 _weight,uint8 _index)public view returns(uint8[] randoms_){
        require(trbyplayerStrs[msg.sender].isinherent==true);
        require(inherent10addrstate[_weight][_index]==msg.sender);
        randoms_=trbyplayerStrs[msg.sender].randoms;
    }
     function callmathing(uint8 _weight,uint8 _index)public view returns(uint8[] randoms_){
        require(trbyplayerStrs[msg.sender].ismatching==true);
        require(inherent10matchingaddr[_weight][_index]==msg.sender);
        randoms_=trbyplayerStrs[msg.sender].randoms;
    }
    
     //销毁合约
    function kill() OnlyOwner() external{
        selfdestruct(owner);
    }
    
    function balanceofthis() view public returns(uint256){
        return address(this).balance;
    }

    }