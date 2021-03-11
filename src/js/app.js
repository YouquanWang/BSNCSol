App = {
  web3Provider: null,
  contracts: {},
  GoldInstance: {},
  GoldDataInstance: {},
  approveAddress: '0x6F18cED823e527a229546ccCe72701D0bD082705',

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
      web3.eth.getGasPrice((err, data) => {
        console.log(data.toString())
      })
    // return App.initContract();
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
  miningInput:async function (event) {
      event.preventDefault();
      var amountTotal = $(this).val()
      var proportion = await App.GoldInstance.getUsdtProportion.call()
      var usdtProportion = proportion[0].toFixed()
      var hjlProportion = proportion[1].toFixed()
      var usdtPrice = await App.GoldDataInstance.getUsdtPrice.call();
      var hjlPrice = await App.GoldDataInstance.getHjlPrice.call();
      var usdtAmount = (amountTotal * usdtProportion) / 100;
      var hjlPrice = await App.GoldDataInstance.getHjlPrice.call();
      var hjlAmount = (amountTotal * hjlProportion * usdtPrice) / (100 * hjlPrice);
      $('#usdtAmount').text(Number(usdtAmount).toFixed(2))
      $('#hjlAmount').text(Number(hjlAmount).toFixed(2))
    },
    invest: async function (event) {
      event.preventDefault();
      var amount = Number($('#investAmount').val());
      if (Number(amount) <=0) {
        layer.open({
          content: qsr + ' USDT '+ sl
          ,skin: 'msg'
          ,time: 1 //2秒后自动关闭
        });
        return
      }
      $('#investButton').attr('disabled', true)
      $('#miningInput').val('')
      $('#usdtAmount').text('0.00')
      $('#hjlAmount').text('0.00')
      amount = new BigNumber(Number(amount) * Math.pow(10, 6)).toFixed()
      var introAddress = $('#investAddress').val();
      var proportion = await App.GoldInstance.getUsdtProportion.call()
      var usdtProportion = proportion[0].toFixed()
      var hjlProportion = proportion[1].toFixed()
      var usdtPrice = await App.GoldDataInstance.getUsdtPrice.call();
      var usdtAmount = new BigNumber(amount * usdtProportion).dividedBy(new BigNumber(100)).toFixed()
      var hjlPrice = await App.GoldDataInstance.getHjlPrice.call();
      var hjlAmount = new BigNumber(amount).multipliedBy(hjlProportion * usdtPrice).multipliedBy(Math.pow(10, 12)).dividedBy(100).dividedBy(hjlPrice).toFixed();
      var usdtBlance = await App.UsdtInstance.balanceOf.call(App.currentAddress);
      var hjlBlance = await App.HjlTokenInstance.balanceOf.call(App.currentAddress);
      var usdtAllowance = await App.UsdtInstance.allowance.call(App.currentAddress, App.approveAddress);
      var hjlAllowance = await App.HjlTokenInstance.allowance.call(App.currentAddress, App.approveAddress);
      if (Number(usdtBlance) < Number(usdtAmount)) {
        layer.open({
          content:'USDT' + slbz
          ,skin: 'msg'
          ,time: 1 //2秒后自动关闭
        });
        $('#investButton').attr('disabled', false)
        return
      }
      if (Number(hjlBlance) < Number(hjlAmount)) {
        layer.open({
          content:'HJL' + slbz
          ,skin: 'msg'
          ,time: 1 //2秒后自动关闭
        });
        $('#investButton').attr('disabled', false)
        return
      }
      var promiseArr = []
      if (Number(usdtAllowance) < Number(usdtAmount)) {
        promiseArr.push(App.UsdtInstance.approve(App.approveAddress, usdtAmount, { from: App.currentAddress, gas: App.gasLimit }))
      }
      if (Number(hjlAllowance) < Number(hjlAmount)) {
         promiseArr.push(App.HjlTokenInstance.approve(App.approveAddress, hjlAmount, { from: App.currentAddress, gas: App.gasLimit }))
       }
       if (promiseArr.length) {
        Promise.all(promiseArr).then(() => {
              App.GoldInstance.invest(amount, introAddress, { from: App.currentAddress, gas: App.gasBigLimit }).then(function (result) {
                 App.initData()
                  $('#investButton').attr('disabled', false)
                }).catch(function (err) {
                  $('#investButton').attr('disabled', false)
                  console.log(err.message);
                });
            }).catch(() => {
              $('#investButton').attr('disabled', false)
            })
       } else {
        App.GoldInstance.invest(amount, '0x0913249bE694F0681aBcaa972DC8Cec03814f20b', { from: App.currentAddress, gas: App.gasBigLimit }).then(function (result) {
          App.initData()
          $('#investButton').attr('disabled', false)
        }).catch(function (err) {
          $('#investButton').attr('disabled', false)
          console.log(err.message);
        }); 
       }
      
    },
    reinvest: async function (event) {
      event.preventDefault();
      var amount = Number($('#miningInput').val());
      if (Number(amount) <=0) {
        layer.open({
          content: qsr + ' USDT '+ sl
          ,skin: 'msg'
          ,time: 1 //2秒后自动关闭
        });
        return
      }
      $('#reinvestButton').attr('disabled', true)
      $('#miningInput').val('')
      $('#usdtAmount').text('0.00')
      $('#hjlAmount').text('0.00')
      var proportion = await App.GoldInstance.getUsdtProportion.call()
      var usdtProportion = proportion[0].toFixed()
      var hjlProportion = proportion[1].toFixed()
      amount = new BigNumber(Number(amount) * Math.pow(10, 6)).toFixed()
      var usdtAmount = new BigNumber(amount * usdtProportion).dividedBy(new BigNumber(100)).toFixed()
      var hjlPrice = await App.GoldDataInstance.getHjlPrice.call();
      var usdtPrice = await App.GoldDataInstance.getUsdtPrice.call();
      var hjlAmount = new BigNumber(amount).multipliedBy(hjlProportion * usdtPrice).multipliedBy(Math.pow(10, 12)).dividedBy(100).dividedBy(hjlPrice).toFixed();
      var usdtBlance = await App.UsdtInstance.balanceOf.call(App.currentAddress);
      var hjlBlance = await App.HjlTokenInstance.balanceOf.call(App.currentAddress);
      var usdtAllowance = await App.UsdtInstance.allowance.call(App.currentAddress, App.approveAddress);
      var hjlAllowance = await App.HjlTokenInstance.allowance.call(App.currentAddress, App.approveAddress);
      if (Number(usdtBlance) < Number(usdtAmount)) {
        layer.open({
          content:'USDT' + slbz
          ,skin: 'msg'
          ,time: 1 //2秒后自动关闭
        });
        $('#reinvestButton').attr('disabled', false)
        return
      }
      if (Number(hjlBlance) < Number(hjlAmount)) {
        layer.open({
          content:'HJL' + slbz
          ,skin: 'msg'
          ,time: 1 //2秒后自动关闭
        });
        $('#reinvestButton').attr('disabled', false)
        return
      }
      var promiseArr = []
      if (Number(usdtAllowance) < Number(usdtAmount)) {
        promiseArr.push(App.UsdtInstance.approve(App.approveAddress, usdtAmount, { from: App.currentAddress, gas: App.gasLimit }))
      }
      if (Number(hjlAllowance) < Number(hjlAmount)) {
         promiseArr.push(App.HjlTokenInstance.approve(App.approveAddress, hjlAmount, { from: App.currentAddress, gas: App.gasLimit }))
       }
      if (promiseArr.length) {
        Promise.all(promiseArr).then(() => {
              App.GoldInstance.ReInvest(amount, { from: App.currentAddress, gas: App.gasBigLimit }).then(function (result) {
                App.initData()
                  $('#reinvestButton').attr('disabled', false)
                }).catch(function (err) {
                  $('#reinvestButton').attr('disabled', false)
                  console.log(err.message);
                });
            }).catch(() => {
              $('#reinvestButton').attr('disabled', false)
            })
       } else {
        App.GoldInstance.ReInvest(amount, { from: App.currentAddress, gas: App.gasBigLimit }).then(function (result) {
          App.initData()
          $('#reinvestButton').attr('disabled', false)
        }).catch(function (err) {
          $('#reinvestButton').attr('disabled', false)
          console.log(err.message);
        });
      }
    },
    getUser: async function () {
      var userInfo = await App.GoldDataInstance.getUser.call(App.currentAddress, { from: App.currentAddress, gas: App.gasLimit});
      var hjlHave = userInfo[4].dividedBy(Math.pow(10, 18)).toFixed(2)
      var recordIds = userInfo[3]
      recordIds.forEach((item) => {
        App.getRecords(item.toString())
      })
      $('#exchangeHjlAmount').text(hjlHave)
    },
    throttle: function (fn, wait) {
      var timer = null;
      return function () {
        var context = this;
        var args = arguments;
        if (!timer) {
          timer = setTimeout(function () {
            fn.apply(context, args);
            timer = null;
          }, wait)
        }
      }
    },
    dateFormat: function (time, format) {
      const t = new Date(time)
      // 日期格式
      format = format || 'Y-m-d h:i:s'
      let year = t.getFullYear()
      // 由于 getMonth 返回值会比正常月份小 1
      let month = t.getMonth() + 1
      let day = t.getDate()
      let hours = t.getHours()
      let minutes = t.getMinutes()
      let seconds = t.getSeconds()
    
      const hash = {
        'y': year,
        'm': month,
        'd': day,
        'h': hours,
        'i': minutes,
        's': seconds
      }
      // 是否补 0
      const isAddZero = (o) => {
        return /M|D|H|I|S/.test(o)
      }
      return format.replace(/\w/g, o => {
        let rt = hash[o.toLocaleLowerCase()]
        return rt > 10 || !isAddZero(o) ? rt : `0${rt}`
      })
    },
    queryParse: function (str) {
      if (!str || str === '0') {
        return {}
      }
      let dataArr = decodeURIComponent(str).split('&')
      let params = {}
      dataArr.forEach(query => {
        let queryItem = query.split('=')
        if (queryItem.length === 1) {
          params.id = queryItem[0]
        } else {
          params[queryItem[0]] = queryItem[1]
        }
      })
      return params
    },
    getInvestData: async function () {
      var record = await App.GoldDataInstance.getInvestment.call(App.currentAddress);
      var investNumber = record[0].dividedBy(Math.pow(10, 6)).toFixed(2)
      var time = App.dateFormat(new Date(Number(record[1].toString())*1000), 'Y-m-d h:i')
      var hjlNumber = record[5].dividedBy(Math.pow(10, 18)).toFixed(3)
      var usdtNumber = record[4].dividedBy(Math.pow(10, 6)).toFixed(3)
      if (record[2]) {
        var itemStr = `<div class="item">
      <div class="amount">${investNumber}</div>
      <div class="row flex-between">
        <span>${xiaohao}USDT：${usdtNumber}</span>
        <span>${xiaohao}HJL：${hjlNumber}</span>
      </div>
      <div class="row flex-between">
          <span>${leixing}：${touzi}</span>
          <span>${shijian}：${time}</span>
        </div>
     </div>`
     $('#invest-record').append(itemStr)
      }
    },
    getRecords: async function (item) {
      var record = await App.GoldDataInstance.getInvesHistory.call(App.currentAddress,item);
      var investNumber = record[0].dividedBy(Math.pow(10, 6)).toFixed(2)
      var time = App.dateFormat(new Date(Number(record[1].toString())*1000), 'Y-m-d h:i')
      var hjlNumber = record[5].dividedBy(Math.pow(10, 18)).toFixed(3)
      var usdtNumber = record[4].dividedBy(Math.pow(10, 6)).toFixed(3)
      var itemStr = `<div class="item">
      <div class="amount">${investNumber}</div>
      <div class="row flex-between">
        <span>${xiaohao}USDT：${usdtNumber}</span>
        <span>${xiaohao}HJL：${hjlNumber}</span>
      </div>
      <div class="row flex-between">
          <span>${leixing}：${touzi}</span>
          <span>${shijian}：${time}</span>
        </div>
     </div>`
     $('#invest-record').append(itemStr)
    },
    getInfo: function () {
      $.post(window.location.origin + '/index.php/DmsUser/Public/getTotalBonus', {eth_address: App.currentAddress}).then((res) => {
        var data = JSON.parse(res).data
        $('#HJ-amount').val(Number(data.sumbonus).toFixed(2))
        switch (Number(data.tzstatus)) {
          case 0: 
            $('#mining-button-box').hide()
            break;
          case 1: 
            $('#reinvestButton').hide()
            break;
          case 2: 
            $('#investButton').hide()
            break;
        }
      })
    },
    getHjlPrice: async function () {
      var hjlPrice = await App.GoldDataInstance.getHjlPrice.call();
      return Number(hjlPrice.toString()).toFixed(2) / 100
    }
  };
  
  $(function () {
    App.init();
  });
