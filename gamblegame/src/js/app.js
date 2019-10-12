App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.

    //init web3
    return App.initWeb3();
  },

  initWeb3: function() {

    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      //App.web3Provider = new Web3.prviders.HttpProvider("http://127.0.0.1:7545");
      alert("请先安装MetaMask钱包");
      return
    }
    web3 = new Web3(App.web3Provider);
    
    return App.initContract();
  },

  initContract: function() {
    $.getJSON('GambleToken.json', function(data) {
      var GambleArtifact = data;
      var gambleInstance;

      App.contracts.Gamble = TruffleContract(GambleArtifact);
      App.contracts.Gamble.setProvider(App.web3Provider);

      // App.contracts.Adoption.defaults({from:'0x1894881F2C1131c21bb62945f7512ddb273E9037'});

      console.log('Contract init success');
      console.log('current address :'+web3.eth.defaultAccount);

      //跳转登录页面
      let isLoginPage = window.location.href.indexOf("login.html") != -1
      if(!isLoginPage){
        App.contracts.Gamble.deployed().then(function(instance){
          gambleInstance = instance;
    
          return gambleInstance.checkLogin();
        }).then(function(result) {
          console.log('checkLogin result:',result);
          if(result==false){
            window.location.href = "login.html";
            return
          }
        } ).catch(function(err) {
          console.log(err.message);
        });
      }


      return App.checkEnv();
    });

    return App.bindEvents();
  },
  checkEnv:function(){
    console.log('check env');

    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.getPlayInfo();
    }).then(function(result) {
      console.log('getPlayInfo result:',result);
      $('.lb-username').html('用户名 :'+result[0].toString());
      $('.lb-balance').html(result[2].toString());
      $('.lb-game-pool').html('当前奖池为 : '+result[3].toString() +'MC');
      
      // console.log('getBalance result:',result['c'][0]);
      // $('.lb-username').html('username : zhangsan');
      // $('.lb-balance').html('balance : '+result.toString());
    } ).catch(function(err) {
      console.log(err.message);
    });

  },


  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
    $(document).on('click', '.btn-accounts', App.getAccounts);
    $(document).on('click', '.btn-bid', App.doBid);
    $(document).on('click', '.btn-bonus', App.getBonus);
    $(document).on('click', '.btn-owner', App.selectOwner);
    $(document).on('click', '.btn-login', App.login);
    $(document).on('click', '.btn-extend-bid', App.doExtendBid);
    $(document).on('click', '.btn-transfer', App.doTransfer);
  },

  getAccounts: function(event){

    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.checkBonus();
    }).then(function(result) {
      console.log('checkBonus result:',result);
      // return App.markAdopted();
    } ).catch(function(err) {
      console.log(err.message);
    });

  },
  selectOwner:function(event){
    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.owner();
    }).then(function(result) {
      console.log('owner result:',result);
      // return App.markAdopted();
    } ).catch(function(err) {
      console.log(err.message);
    });
  },
  getBonus:function(event){

    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.getBonus();
    }).then(function(result) {
      console.log('getBonus result:',result);
      return App.checkEnv();
    } ).catch(function(err) {
      console.log(err.message);
    });

  },

  doBid:function(event){

    let bidNum = ~~$(".et-bid").val();
    let curNum = $(".lb-balance").text();

    console.log('bid num'+bidNum);
    console.log('cur num'+curNum);
    if(bidNum == ""){
      alert('请设置参与的金额！！！');
      return;
    }

    if(bidNum>curNum){
      alert("没有足够的余额,再申请多一点低保吧");
      return
    }

    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.bid(bidNum);
    }).then(function(result) {
      console.log('bid result:',result);
      return App.checkEnv();
    } ).catch(function(err) {
      console.log(err.message);
    });

  },

  doExtendBid:function(event){

    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.extendBid(1);
    }).then(function(result) {
      console.log('extendBid result:',result);
      return App.checkEnv();
    } ).catch(function(err) {
      console.log(err.message);
    });

  },

  doTransfer:function(event){

    var gambleInstance;
    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.transfer(0x7Cb9975c6493148f59e742e54F4833918df3E766,1);
    }).then(function(result) {
      console.log('transfer result:',result);
      return App.checkEnv();
    } ).catch(function(err) {
      console.log(err.message);
    });

  },

  login: function(event) {
    
    var gambleInstance;
    let username = $(".et-username").val();
    if(username == ""){
      alert('请设置用户名！！！');
      return;
    }
    console.log(username);


    App.contracts.Gamble.deployed().then(function(instance){
      gambleInstance = instance;

      return gambleInstance.register(username);
    }).then(function(result) {
      console.log('login result:',result);
      // return App.checkEnv();
      window.location.href = "index.html";
    } ).catch(function(err) {
      console.log(err.message);
    });


    // window.location.href = "index.html";
  },

  handleAdopt: function(event) {
    event.preventDefault();
    
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
