App = {
  web3Provider: null,
  contracts: {},
  GoldInstance: {},
  GoldDataInstance: {},
  approveAddress: '0x05f86Ac443EC17F5F4157C7eEa5f17Bcd95DAa10',

  init: function() {
    return App.initWeb3();
  },
  initWeb3: async function() {
    if (window.ethereum) {
      App.web3Provider = window.ethereum
      web3 = new Web3(App.web3Provider);
        try {
          await ethereum.enable()
          } catch (error) {
      }
      } else {
          if (window.web3) {
            App.web3Provider = web3.currentProvider
            web3 = new Web3(App.web3Provider);
          } else {
            // set the provider you want from Web3.providers
            App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545');
            web3 = new Web3(App.web3Provider);
          }
      }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Gold.json', async function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var GoldArtifact = data;
      App.contracts.Gold = TruffleContract(GoldArtifact);

      // Set the provider for our contract.
      App.contracts.Gold.setProvider(App.web3Provider);
      App.GoldInstance = await App.contracts.Gold.deployed();
      // Use our contract to retieve and mark the adopted pets.
    });
    $.getJSON('CompassCpcToken.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var CompassCpcTokenArtifact = data;
      App.contracts.CompassCpcToken = TruffleContract(CompassCpcTokenArtifact);

      // Set the provider for our contract.
      App.contracts.CompassCpcToken.setProvider(App.web3Provider);
    
      // Use our contract to retieve and mark the adopted pets.
    });
    $.getJSON('GoldData.json', async function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var GoldDataArtifact = data;
      App.contracts.GoldData = TruffleContract(GoldDataArtifact);

      // Set the provider for our contract.
      App.contracts.GoldData.setProvider(App.web3Provider)
      App.GoldDataInstance = await App.contracts.GoldData.deployed();
      App.getInvestData()
      App.getCanWithdrawalAmount()
      // Use our contract to retieve and mark the adopted pets.
    });
    $.getJSON('Usdt.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var UsdtArtifact = data;
      App.contracts.Usdt = TruffleContract(UsdtArtifact);

      // Set the provider for our contract.
      App.contracts.Usdt.setProvider(App.web3Provider)

      // Use our contract to retieve and mark the adopted pets.
    });
    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#investButton', App.invest);
    $(document).on('click', '#withdrawalButton', App.withdrawal)
    $(document).on('click', '#allowButton', App.setAllowAccess);
    $(document).on('click', '#backTimeButton', App.setTime)
  },
  invest: async function(event) {
    event.preventDefault();
    var amount = parseInt($('#investAmount').val());
    amount = new BigNumber(Number(amount)*Math.pow(10, 18)).toFixed()
    var introAddress = $('#investAddress').val();

    var GoldInstance;
    var CompassCpcTokenInstance;
    var UsdtInstance;
    var usdtAmount = (amount*80)/100;
    console.log(App.GoldDataInstance)
    var hjlPrice = await App.GoldDataInstance.getHjlPrice();
    var hjlAmount = (amount*20*700) / (100 * hjlPrice);
    web3.eth.getAccounts(async function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      CompassCpcTokenInstance = await App.contracts.CompassCpcToken.deployed();
      UsdtInstance = await App.contracts.Usdt.deployed();
      CompassCpcTokenAllowance = await CompassCpcTokenInstance.allowance(hjlAmount, App.approveAddress)
      UsdtAllowance = await UsdtInstance.allowance(usdtAmount, App.approveAddress)
      console.log(CompassCpcTokenAllowance/Math.pow(10, 18),UsdtAllowance/Math.pow(10, 18))
      Promise.all([CompassCpcTokenInstance.approve(App.approveAddress,amount, {from: account, gas: 100000}),
        UsdtInstance.approve(App.approveAddress,amount, {from: account, gas: 100000})
      ])
      .then(() => {
        App.contracts.Gold.deployed().then(function(instance) {
          GoldInstance = instance;
          return GoldInstance.invest(amount, introAddress, {from: account, gas: 500000});
        }).then(function(result) {
          console.log(result)
        }).catch(function(err) {
          console.log(err.message);
        });
      })
    });
  },
  withdrawal: function (event) {
    event.preventDefault();
    var withdrawalAmount = $('#withdrawalAmount').val();
    withdrawalAmount = new BigNumber(Number(withdrawalAmount)*Math.pow(10, 18)).toFixed()
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      App.GoldInstance.withdrawal(withdrawalAmount, {from: account, gas: 500000}).then((err, result)=>{
        console.log(result)
      })
   })
  },
  setAllowAccess: function (event) {
    event.preventDefault();
    var allowAccessAddress = $('#allowAccessAddress').val();
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      App.GoldDataInstance.allowAccess(allowAccessAddress, {from: account, gas: 100000}).then(function(result){ 
      })
   })
  },
  getInvestData: function () {
    console.log(App.GoldDataInstance)
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      App.GoldDataInstance.getInvestment(account, {from: account, gas: 1000000}).then(function(result){ 
        console.log('getInvestment', result)
        console.log('investAmount', result[0].toString()/Math.pow(10, 18))
        console.log('startTime', result[1].toString())
        console.log('isInvested', result[2])
        console.log('canWithdrawal', result[3].dividedBy(new BigNumber(Math.pow(10, 18))).toFixed())
        console.log('dynamic', result[4].toString())
        console.log('haveWithdrawal', result[5].toString()/Math.pow(10, 18))
      })
    })
  },
  getCanWithdrawalAmount: function () {
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      App.GoldDataInstance.getCanWithdrawalAmount(account).then(function(result){ 
        console.log('getCanWithdrawalAmount----',result.dividedBy(new BigNumber(Math.pow(10, 18))).toFixed())
      })
    })
  },
  setTime: function(event) {
    event.preventDefault()
    var time = $('#backTime').val();
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.GoldDataInstance.changeBackTime(time,{from: account, gas: 100000}).then((result) => {
        console.log(result)
      })
    })
  }
};

$(function() {
  App.init();
});
