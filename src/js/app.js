App = {
    web3Provider: null,
    contracts: {},
    accounts:{},
    inherentflag:true,
    mathingflag:true,
    round:null,
    init: async function() {
      return await App.initWeb3();
    },
  
    initWeb3: async function() {
        if(typeof web3 !='undefined'){
            App.web3Provider=web3.currentProvider;
        }else{
            App.web3Provider=new Web3.prviders.HttpProvider("http://127.0.0.1:7545");
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
      $(document).on('click','.btnmathing',App.mathingOrinherent);
      $(document).on('click','.btnmathingten',App.mathingOrinherentten);
      $(document).on('click','.btnmathinghub',App.mathingOrinherenthub);
      $(document).on('click','#CallBtn',App.callWinallInfo);
    },
  
    markAdopted: function() {
      web3.eth.getAccounts(function(error,accounts){
       App.accounts=accounts;
       var account=accounts[0];
        $("#palyAccountNamePId").text(account);
        console.log(account);
      });
      App.contracts.GameStandsTallBy21.deployed().then(function(instance){
        App.GameStandsTallBy21De=instance;
        return  instance.oneDicePrice.call();
      }).then(function(value){
        App.oneDicePrice=value;
        App.GameStandsTallBy21De.round.call().then(function(data){
          console.log("期数"+data);
          App.round=data;
          $("#RoundId").text("Round: "+data);
        });
        App.GameStandsTallBy21De.overallBalance.call().then(function(data){
          console.log("总奖池"+data);
          var balance=data/10**18;
          $("#JackPotId").text("JackPot: "+balance+"Ether");
        });
        for(var j=0;j<3;j++){
          for(var i=1;i<=10;i++){
            var temp;
            if(j==0){
              temp=1;
            }else if(j==1){
              temp=10;
            }else if(j==2){
              temp=100;
            }     
            App.GameStandsTallBy21De.callsite(temp,i,{from:App.accounts[0]}).then(function(value){
              console.log(value);
              if(value[0]!=0){
                var buttonclassname="";
                  if(value[2]==1){
                    buttonclassname=".btnmathing"+value[3];
                  }else if(value[2]==10){
                    buttonclassname=".btnmathingten"+value[3];
                  }else if(value[2]==100){
                    buttonclassname=".btnmathinghub"+value[3];
                  }
                  $(buttonclassname).text("匹配");
                  console.log($(buttonclassname));
                  var address=value[0];
                  address=address.substring(0,15)+"...";
                  $(buttonclassname).parent().parent().find("span.col-sm-10").text(address);
                  var balance=value[1]/(10**18);
                  $(buttonclassname).parent().find("span.col-sm-2").text(balance+"Ether");
              }
          });
          }
        }
        });
    
    },

    //占位匹配入口
    mathingOrinherent:function(event) {
      event.preventDefault();
      console.log('app.js适配合约1');
      var classname=$(this).attr("class");
      if($(this).text()=="抢占"){
        if(App.inherentflag){
          $(this).text("匹配");
          return App.inherent(1,classname);
        }
    }else{
        if(App.mathingflag){
          $(this).text("抢占");
          return App.mathing(1,classname);
        }
    }
    },
    //十倍占位匹配入口
    mathingOrinherentten:function(event) {
      event.preventDefault();
      var classname=$(this).attr("class");
      console.log('app.js适配合约10');
      if($(this).text()=="抢占"){
        if(App.inherentflag){
          $(this).text("匹配");
          return App.inherent(10,classname);
        }
    }else{
        if(App.mathingflag){
          $(this).text("抢占");
          return App.mathing(10,classname);
        }
    }
    },
    //百倍入口
    mathingOrinherenthub:function(event) {
      event.preventDefault();
      var classname=$(this).attr("class");
      console.log('app.js适配合约100');
      if($(this).text()=="抢占"){
        if(App.inherentflag){
          $(this).text("匹配");
          return App.inherent(100,classname);
        }
    }else{
        if(App.mathingflag){
          $(this).text("抢占");
          return App.mathing(100,classname);
        }
    }
    },

    //匹配
    mathing:function(data,className) {
        App.mathingflag=false;
        console.log(typeof className);
        var weight;
        var index;
        if(className.indexOf("btnmathingten") != -1){
          weight=10;
        }else if(className.indexOf("btnmathinghub") != -1){
          weight=100;
        }else {
          weight=1;
        }
        index=className.substring(className.length-1,className.length);
        console.log(index,weight);
      App.GameStandsTallBy21De.matchingPosition(index,weight,{from:App.accounts[0],value:App.oneDicePrice*data,gasPrice:2*10**9}).then(function (value){
        App.mathingflag=true;
        window.location.replace("http://192.168.46.1:3000/buy.html?"+"weight="+weight+"&index="+index+"&ismathing="+"1");
      })

    },
    //抢占
    inherent:function(data,className) {
      App.inherentflag=false;
      console.log(typeof className);
      var weight;
      var index;
      if(className.indexOf("btnmathingten") != -1){
        weight=10;
      }else if(className.search("btnmathinghub") != -1){
        weight=100;
      }else {
        weight=1;
      }
      index=className.substring(className.length-1,className.length);
      console.log(index,weight);
      App.GameStandsTallBy21De.takePosition(index,weight,{from:App.accounts[0],value:App.oneDicePrice*data,gasPrice:2*10**9}).then(function (value){
        console.log(value)
        App.inherentflag=true;
        console.log(weight+" "+index+"  "+App.accounts[0]);
        window.location.replace("http://192.168.46.1:3000/buy.html?"+"weight="+weight+"&index="+index+"&ismathing="+"0");
        //window.location.href="localhost:3000/buy.html?address="+App.accounts[0]+"&&weight="+weight+"&&index="+index+"&&ismathing="+"0";
    })
    },
    //根据期数查询总奖池开奖信息
    callWinallInfo:function(event){
      event.preventDefault();
     var round=$("#callRoudnInput").val();
      if(round!=null){
        App.GameStandsTallBy21De.queryeveryrbywinInfobyround().call(round).then(function(value){
          if(value!=null){
            console.log(value);
          }
        });
      }
    },
  };
  $(function() {
    $(window).load(function() {
      App.init();
    });
  });