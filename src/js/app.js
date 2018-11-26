App = {
    web3Provider: null,
    contracts: {},
    accounts:{},
  
    init: async function() {
      return await App.initWeb3();
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
      $.getJSON('MyTonkenERC20.json', function(data) {
        var MyTonkenERC20Artifact=data;
        App.contracts.MyTonkenERC20=TruffleContract(MyTonkenERC20Artifact);
        App.contracts.MyTonkenERC20.setProvider(App.web3Provider);
  
        return App.markAdopted();
      });
  
      return App.bindEvents();
    },
  
    bindEvents: function() {
      $(document).on('click', '.selectValueBtn', App.handleSelect);
      $(document).on('click', '.TansferBtn', App.handleTansfer);
      $(document).on('click', '.approveBtn', App.handleApprove);
      $(document).on('click', '.approveselectValueBtn', App.handleapproveselectValueBtn);
      $(document).on('click', '.transferFromBtn', App.handletransferFromBtn);
      
    },
  
    markAdopted: function(adopters, account) {
      web3.eth.getAccounts(function(error,accounts){
       App.accounts=accounts;
       var account=accounts[0];
        $(".address").val(account);
        console.log(account);
      });
     
     

    },
    //查询余额
    handleSelect: function(event) {
      event.preventDefault();
      console.log("ssssss");
      App.contracts.MyTonkenERC20.deployed().then(function(instance){
        MyTonkenERC20Instance=instance;
        var address= $(".address").val();
        return MyTonkenERC20Instance.balanceOf.call(address);
      }).then(function (value){
       console.log(value);
       if(value!=null){
         if(value>10**18){
          $(".balanceSizeClass").text("余额："+value/10**18+"MT");
         }else{
          $(".balanceSizeClass").text("余额："+value+"MTs");
         }
       
       }
      });

  
    },
    //转账
    handleTansfer: function(event) {
      event.preventDefault();
      var toaddress=$(".TansferaddressTo").val();
      var tovalue=$(".TansferValue").val();
      App.contracts.MyTonkenERC20.deployed().then(function(instance){
        MyTonkenERC20Instance=instance;
        return MyTonkenERC20Instance.transfer(toaddress,tovalue,{from:App.accounts[0]});
      }).then(function(result){
          alert("转账成功");
      }).catch(function(err){
        console.log(err.message);
    });
    },
    //根据输入授权给授权用户
    handleApprove: function(event) {
      event.preventDefault();
      var toaddress=$(".approveAddress").val();
      var tovalue=$(".approveValue").val();
      App.contracts.MyTonkenERC20.deployed().then(function(instance){
        MyTonkenERC20Instance=instance;
        return MyTonkenERC20Instance.approve(toaddress,tovalue,{from:App.accounts[0]});
      }).then(function(result){
        if(result){
          alert("转账成功");
        }else{
          alert("转账失败");
        }  
      }).catch(function(err){
        console.log(err.message);
    });
    },
    //查询授权额度
    handleapproveselectValueBtn: function(event) {
      event.preventDefault();
      App.contracts.MyTonkenERC20.deployed().then(function(instance){
        MyTonkenERC20Instance=instance;
        var address= $(".approveaddress").val();
        return MyTonkenERC20Instance.allowance.call(App.accounts[0],address);
      }).then(function (value){
       console.log(value);
       if(value!=null){
         if(value>10**18){
          $(".approvebalanceSizeClass").text("余额："+value/10**18+"MT");
         }else{
          $(".approvebalanceSizeClass").text("余额："+value+"MTs");
         }
       
       }
      });
    },
    handletransferFromBtn: function(event) {
      event.preventDefault();
      var aoaddress=$(".transferFromFAddress").val();
      var toaddress=$(".transferFromToAddress").val();
      var tovalue=$(".transferFromValue").val();
      console.log("from:"+App.accounts[0]+"to:"+toaddress+"msg.sender:"+aoaddress);
      App.contracts.MyTonkenERC20.deployed().then(function(instance){
        MyTonkenERC20Instance=instance;
        return MyTonkenERC20Instance.transferFrom(App.accounts[0],toaddress,tovalue,{from:aoaddress});
      }).then(function(result){
        if(result){
          alert("转账成功");
        }else{
          alert("转账失败");
        }  
      }).catch(function(err){
        console.log(err.message);
    });
    }
  };
  
  $(function() {
    $(window).load(function() {
      
      App.init();
    });
  });
  