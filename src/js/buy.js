App = {
    web3Provider: null,
    contracts: {},
    accounts:{},
    weight:null,
    index:null,
    ismathing:null,
    rondoms:{},
    init: async function() {
      return await App.initWeb3();
    },
    getRequest:function(strParame){
            var args = new Object();
            var query = location.search.substring(1);
            var pairs = query.split("&"); // Break at ampersand
            for (var i = 0; i < pairs.length; i++) {
                var pos = pairs[i].indexOf("=");
                if (pos == -1) continue;
                var argname = pairs[i].substring(0, pos);
                var value = pairs[i].substring(pos + 1);
                value = decodeURIComponent(value);
                args[argname] = value;
                if(strParame==argname){
                    return args[strParame];
                }
        }
    },
    initWeb3: async function() {
        if(typeof web3 !=='undefined'){
            App.web3Provider=web3.currentProvider;
        }else{
            App.web3Provider=new Web3.prviders.HttpProvider("http://127.0.0.1:8545");
        }
        web3=new Web3(App.web3Provider);
      return App.initContract();
    },

    initContract: function() {
      $.getJSON('GameStandsTallBy21.json', function(data) {
        var GameStandsTallBy21Artifact=data;
        App.contracts.GameStandsTallBy21=TruffleContract(GameStandsTallBy21Artifact);
        App.contracts.GameStandsTallBy21.setProvider(App.web3Provider);

        return App.markAdopted();
      });

      return App.bindEvents();
    },

    bindEvents: function() {
      $(document).on('click','.buyButton',App.buyDice);
      $(document).on('click','.buysubmit',App.buysubmitInfo);
    },

    markAdopted: function() {
        App.index=App.getRequest("index");
        App.ismathing=App.getRequest("ismathing");
        App. weight=App.getRequest("weight");
      web3.eth.getAccounts(function(error,accounts){
       App.accounts=accounts;
      });
      App.contracts.GameStandsTallBy21.deployed().then(function(instance){
        App.GameStandsTallBy21De=instance;
        return  instance.oneDicePrice.call()
      }).then(function(value){
        if(App.ismathing==1){
            App.GameStandsTallBy21De.callmathing(App.weight,App.index,{from:App.accounts[0]}).then(function(value){
                App.rondoms=value;
                value.map((v, i) => { // 遍历
                    var src="<img src='../img/"+v+".gif'>"
                    $(".BuyImgRoom").append(src);
                });
                $(".roundnumclass").text("当前点数:"+value[0]);
            });
        }else{
            App.GameStandsTallBy21De.callinherent(App.weight,App.index,{from:App.accounts[0]}).then(function(value){
                App.rondoms=value;
                value.map((v, i) => { // 遍历
                    var src="<img src='../img/"+v+".gif'>"
                    $(".BuyImgRoom").append(src);
                });
         console.log(App.rondoms);
        var rondomsum=0;
        for (var k=0;k<App.rondoms.length;k++){
            rondomsum+=parseInt(App.rondoms[k]);
        }
        rondomsum=parseInt(rondomsum+"",10);
        $(".roundnumclass").text("当前点数:"+rondomsum);
            });
        }
        App.oneDicePrice=value;
        });
    },
    buyDice:function(){
        console.log("买筛子");
        var val=App.oneDicePrice;
        for(i=0;i<App.rondoms.length;i++){
            val*=1.5;
        }
        App.GameStandsTallBy21De.BuyDice(App.weight,App.index,{from:App.accounts[0],value:val,gasPrice:1*10**9}).then(function(value){
            if(App.ismathing==1){
                App.GameStandsTallBy21De.callmathing(App.weight,App.index,{from:App.accounts[0]}).then(function(value){
                    App.rondoms=value;
                    $(".BuyImgRoom").html("");
                    value.map((v, i) => { // 遍历
                        var src="<img src='../img/"+v+".gif'>"
                        $(".BuyImgRoom").append(src);
                    });
                });
            }else{
                App.GameStandsTallBy21De.callinherent(App.weight,App.index,{from:App.accounts[0]}).then(function(value){
                    App.rondoms=value;
                    $(".BuyImgRoom").html("");
                    value.map((v, i) => { // 遍历
                        var src="<img src='../img/"+v+".gif'>"
                        $(".BuyImgRoom").append(src);
                    });
                });
            }
        });
        var rondomsum;
        for (var k=0;k<App.rondoms.length;k++){
            rondomsum+=parseInt(App.rondoms[k]);
        }
        rondomsum=parseInt(rondomsum+"",10);
        $(".roundnumclass").text("当前点数:"+rondomsum);
    },
    buysubmitInfo:function(){
        if(App.ismathing==1){
            App.GameStandsTallBy21De.matchingsubmit(App.index,App.weight,{from:App.accounts[0],gasPrice:2*10**9}).then(function(value){
                window.location.replace("http://192.168.46.1:3000");
            });
        }else{
            App.GameStandsTallBy21De.inherentsubmit(App.index,App.weight,{from:App.accounts[0],gasPrice:2*10**9}).then(function(value){
                console.log(value);
                window.location.replace("http://192.168.46.1:3000");
            });
        }
    }
  };
  $(function() {
    $(window).load(function() {
      App.init();
    });
  });