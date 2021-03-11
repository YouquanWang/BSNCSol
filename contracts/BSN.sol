pragma solidity ^0.6.9;
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}
library UniswapV2Library {
    using SafeMath for uint;
    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
    }
}
interface IOracle {
  function getMarket(uint256 blocknum) external view returns (uint256);
}
interface IWindToken {
  function mint(address _to, uint256 _amount) external returns (bool);
}
interface IBSNInterface {
  function invest(
    address _investor,
    uint _investType,
    uint _minute,
    uint _investAmount,
    uint _investBlock,
    uint _investTime,
    uint _openBlock,
    uint _busdPerBeth
  ) external;
  function getMarketToTalMoney () external view returns(uint);
  function getOrderById (uint _id) external view returns (
    address investor,
    uint investType,
    uint minute,
    uint investAmount,
    uint investBlock,
    uint investTime,
    uint openBlock,
    uint busdPerBeth,
    uint dayNum,
    bool isOpen);
    function getBlockRecords(uint _block, uint _minute) external view returns(uint[] memory ids);
    function win(uint _amount, address _user,uint _id) external;
    function fail (uint _id) external;
    function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory records,
    uint marketProvide,
    bool isMarker
  );
  function addPoolMoney (address _user, uint _amount) external;
  function withdrawPoolMoney (address _user, uint _amount, uint _trueAmount)  external;
  function getCurCycleData (uint _dayNum) external view returns(
    uint windToken,
    uint totalInvest,
    uint totalPay,
    uint marketAdd,
    uint dayMarketTotal
  );
  function getUserDayMarket (address _user, uint _dayNum) external view returns(uint _marketAmount);
  function getCurDayStartBlock () external view returns(uint);
  function changeCycle(uint _block, uint _dayMarketTotal, uint _windToken) external;
  function transferPool(uint _amount) external;
  function getCurDayNum () external view returns(uint);
  function receiveDividends (address _user, uint amount, uint _dayNum, address _teamAddress, uint _teamAmount) external;
}
contract BSN is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  address factory;  // 交易对工厂地址
  address public BETH; // BETH代币地址
  address public BUSD; // BUSD代币地址
  address public windToken; // windToken代币地址
  address teamAddress; // 团队收币地址
  uint public BUSDDecimals;
  uint public windTokenDecimals;
  address public BSNData; // 数据合约地址
  // uint public singleInvestAmount;
  uint[] public marketTypeIds;
  struct MarketType{
    uint minute;
    uint duration;
    uint minAmount;
    uint maxAmount;
    mapping(uint => uint) singleMarketInvest;
    bool isExist;
  }
  address oracle;
  uint up = 1;
  uint down = 0;
  uint public addMarketMin;
  uint public addMarketMax;
  bool public isHaveWinUsd = false;
  uint public failRate = 20;
  uint public successRate = 10;
  mapping(uint => MarketType) public marketTypes;
  mapping(uint => mapping(uint => uint)) public dayMinuteNum;
  mapping (address => bool) private accessAllowed;
  mapping(address => mapping(uint => bool)) public isDividend;
  event AccessAllowedAddress(address indexed _addr, bool _access);
  event SetPairAddress(address _BETH, address _BUSD);
  event SetFactoryAddress(address _old, address _new);
  event SetOracleAddress(address _old, address _new);
  event SetBSNDataAddress(address _old, address _new);
  event SetWindTokenAddress(address _old, address _new);
  event Invest(address indexed _user, uint _startBlock, uint _openBlock);
  event OpenAward(uint _amount, uint _windAmount, uint _orderId, address indexed _user);
  event SetAddMarketLimit(uint _min, uint _max);
  event SetHaveWinUsd(bool _old, bool _new);
  event AddPoolMoney(address indexed _user, uint _amount, uint _dayNum, uint _time);
  event ShareBonus(uint _amount, uint _dayNum, uint _busdAmount);
  event MarkerRedeem(address indexed _user, uint _amount, uint _trueAmount, uint _time, uint _block);
  event SetTeamAddress(address _old, address _new);
  event SetRate(uint _failRate, uint _successRate);
  event ReceiveDividends(uint _dayNum, uint _canReceive, address _user);
  constructor (address _BSNData,address _oracle, address _factory, address _BETH, address _BUSD, address _windToken, address _teamAddress) public {
    BSNData = _BSNData;
    oracle = _oracle;
    factory = _factory;
    BETH = _BETH;
    BUSD = _BUSD;
    teamAddress = _teamAddress;
    BUSDDecimals = IERC20(BUSD).decimals();
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
    // singleInvestAmount = 100 * (10 ** BUSDDecimals);
  }
  
  /* 
   * 验证 accessAllowed 权限
  */   
  modifier platform() {
    require(accessAllowed[msg.sender] == true, 'no access');
    _;
  }
   /* 添加 accessAllowed 权限
  */ 
  function allowAccess(address _addr) onlyOwner public {
    accessAllowed[_addr] = true;
    emit AccessAllowedAddress(_addr, true);
  }
   /* 
   * 删除 accessAllowed 权限
  */ 
  function denyAccess(address _addr) onlyOwner public {
    accessAllowed[_addr] = false;
    emit AccessAllowedAddress(_addr, false);
  }
  function setHaveWinUsd (bool _have) onlyOwner public {
    emit SetHaveWinUsd(isHaveWinUsd, _have);
    isHaveWinUsd = _have;
  }
  function setPairAddress(address _BETH, address _BUSD) onlyOwner public {
    BETH = _BETH;
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
    // singleInvestAmount = 100 * (10 ** BUSDDecimals);
    emit SetPairAddress(BETH, BUSD);
  }
  function setFactoryAddress(address _factory) onlyOwner public {
    emit SetFactoryAddress(factory, _factory);
    factory = _factory;
  }
  function setTeamAddress(address _teamAddress) onlyOwner public {
    emit SetTeamAddress(teamAddress, _teamAddress);
    teamAddress = _teamAddress;
  }
  function setOracleAddress(address _oracle) onlyOwner public {
    emit SetOracleAddress(oracle, _oracle);
    oracle = _oracle;
  }
  function setBSNDataAddress(address _BSNData) onlyOwner public {
    emit SetBSNDataAddress(BSNData, _BSNData);
    BSNData = _BSNData;
  }
  function setAddMarketLimit(uint _min, uint _max) onlyOwner public {
    require(_max > _min);
    emit SetAddMarketLimit(_min, _max);
    addMarketMin = _min.mul(10 ** BUSDDecimals);
    addMarketMax = _max.mul(10 ** BUSDDecimals);
  }
  function setRate(uint _failRate, uint _successRate) onlyOwner public {
    emit SetRate(_failRate, _successRate);
    failRate = _failRate;
    successRate = _successRate;
  }
  function setWindTokenAddress(address _windToken) onlyOwner public {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
  }
  function addMarketType(uint _minute, uint _duration, uint _minAmount, uint _maxAmount, uint _singleMarketInvest) onlyOwner public{
    require(_maxAmount > _minAmount);
    if (!marketTypes[_minute].isExist) {
      marketTypeIds.push(_minute);
      marketTypes[_minute].isExist = true;
    }
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    marketTypes[_minute].minute = _minute;
    marketTypes[_minute].duration = _duration;
    marketTypes[_minute].minAmount = _minAmount.mul(10 ** BUSDDecimals);
    marketTypes[_minute].maxAmount = _maxAmount.mul(10 ** BUSDDecimals);
    marketTypes[_minute].singleMarketInvest[dayNum] = _singleMarketInvest.mul(10 ** BUSDDecimals);
  }
  function invest(uint _investType, uint _minute, uint _investAmount) public nonReentrant {
    require(marketTypes[_minute].isExist);
    require(_investAmount >= marketTypes[_minute].minAmount);
    require(_investAmount <= marketTypes[_minute].maxAmount);
    require(_investType == up || _investType == down);
    (uint curDayAmount, uint marketInvest) = getCurCycleIncome();
    if (marketInvest > curDayAmount) {
       require(marketInvest.sub(curDayAmount) < marketInvest.mul(10).div(100));
    }
    changeCycle(block.number);
    // require(_investAmount <= marketTypes[_minute].minute.mul(singleInvestAmount));
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _investAmount);
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    dayMinuteNum[dayNum][_minute] = dayMinuteNum[dayNum][_minute].add(_investAmount);
    uint price = getEthUsd();
    uint openBlock = marketTypes[_minute].duration.add(block.number);
    IBSNInterface(BSNData).invest(msg.sender, uint(_investType), _minute, _investAmount, block.number, block.timestamp, openBlock ,price);
    emit Invest(msg.sender, block.number, openBlock);
  }
  function changeCycle (uint _block) private {
    uint curBlock = IBSNInterface(BSNData).getCurDayStartBlock();
    if (_block >= curBlock.add(28800)) {
      (uint curDayAmount, uint marketInvest) = getCurCycleIncome();
      uint dayNum = IBSNInterface(BSNData).getCurDayNum();
      for(uint i = 0; i < marketTypeIds.length; i++) {
        uint total = dayMinuteNum[dayNum][marketTypeIds[i]];
        if (total > marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum].mul(24)){
          marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum.add(1)] = marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum].add(10000 * (10 ** BUSDDecimals));
        }
        if (marketInvest > curDayAmount && marketInvest.sub(curDayAmount) > marketInvest.mul(5).div(100)) {
          marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum.add(1)] = marketTypes[marketTypeIds[i]].singleMarketInvest[dayNum].div(2);
        }
      }
      uint _dayMarketTotal;
      uint amount;
      uint busdAmount;
      if (curDayAmount < marketInvest) {
         _dayMarketTotal = curDayAmount;
         amount = marketInvest.sub(curDayAmount);
      } else {
        _dayMarketTotal = marketInvest;
        amount = curDayAmount.sub(marketInvest);
        if (amount > 0) {
          IBSNInterface(BSNData).transferPool(amount);
          busdAmount = amount;
        }
      }
       if (dayNum <= 60) {
          uint amountMarket = marketInvest.div(100);
          amount = amount > amountMarket ? amount : amountMarket;
       }
       uint windTokenAmount = isHaveWinUsd ? amount.mul(getPerUSdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 10) : amount.mul(100).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       uint teamAmount = windTokenAmount.div(9);
       IWindToken(windToken).mint(teamAddress, teamAmount);
       IWindToken(windToken).mint(BSNData, windTokenAmount.sub(teamAmount));
      emit ShareBonus(windTokenAmount.sub(teamAmount), dayNum, busdAmount);
      IBSNInterface(BSNData).changeCycle(_block, _dayMarketTotal, windTokenAmount.sub(teamAmount));
    }
  }
  function openAward (uint _orderId) public nonReentrant {
    (address investor,,,,,,uint openBlock,,,bool isOpen) = IBSNInterface(BSNData).getOrderById(_orderId);
    require(msg.sender == investor);
    require(!isOpen);
    uint openBlockPrice = getBlockPrice(openBlock);
    require(openBlockPrice > 0);
    (uint back, uint winTokenAmount) = getWin(_orderId);
    if (back > 0) {
      IBSNInterface(BSNData).win(back, msg.sender, _orderId);
    } else {
      IBSNInterface(BSNData).fail(_orderId);
    }
    uint teamAmount = winTokenAmount.div(9);
    if (winTokenAmount > 0) {
      IWindToken(windToken).mint(teamAddress, teamAmount);
      IWindToken(windToken).mint(msg.sender, winTokenAmount.sub(teamAmount));
    }
    emit OpenAward(back, winTokenAmount.sub(teamAmount), _orderId, msg.sender);
    changeCycle(block.number);
  }
  function getWin (uint _orderId) public view returns(uint back, uint winTokenAmount){
    (,uint investType,uint minute,uint _investAmount,uint investBlock,,uint openBlock,uint busdPerBeth,uint investDayNum,) = IBSNInterface(BSNData).getOrderById(_orderId);
    uint openBlockPrice = getBlockPrice(openBlock);
    (uint upTotal, uint downTotal) = getBlockUpAndDown(investBlock, minute);
    uint singleMarketInvest = marketTypes[minute].singleMarketInvest[investDayNum];
    uint investAmount = _investAmount;
    if (busdPerBeth == openBlockPrice) {
      back = investAmount;
      winTokenAmount = 0;
    }
    if (investType == up && busdPerBeth > openBlockPrice) {
       winTokenAmount = isHaveWinUsd ? investAmount.mul(failRate).mul(getPerUSdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(failRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       back = 0;
    }
    if (investType == up && busdPerBeth < openBlockPrice) {
        back = investAmount.mul(downTotal.add(singleMarketInvest)).div(upTotal.add(singleMarketInvest)).mul(85).div(100).add(investAmount);
        winTokenAmount = isHaveWinUsd ? investAmount.mul(successRate).mul(getPerUSdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(successRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
    }
    if(investType == down && busdPerBeth > openBlockPrice) {
       back = investAmount.mul(upTotal.add(singleMarketInvest)).div(downTotal.add(singleMarketInvest)).mul(85).div(100).add(investAmount);
       winTokenAmount = isHaveWinUsd ? investAmount.mul(successRate).mul(getPerUSdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(successRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
    }
    if(investType == down && busdPerBeth < openBlockPrice) {
       winTokenAmount = isHaveWinUsd ? investAmount.mul(failRate).mul(getPerUSdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(failRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       back = 0;
    }
  }
  function addMarketPool(uint _amount) public nonReentrant {
    require(_amount >= addMarketMin);
    require(_amount <= addMarketMax);
    changeCycle(block.number);
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _amount);
    IBSNInterface(BSNData).addPoolMoney(msg.sender,_amount);
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    emit AddPoolMoney(msg.sender, _amount, dayNum, block.timestamp);
  }
  function markerRedeem (uint _amount) public nonReentrant {
    require(_amount >= addMarketMin);
     (, , uint marketProvide,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
     require(marketProvide >= _amount);
     (uint curDayAmount, uint marketInvest) = getCurCycleIncome();
     uint trueAmount;
     if (curDayAmount < marketInvest) {
      trueAmount = _amount.mul(marketInvest.sub(curDayAmount)).div(marketInvest);
     } else {
       trueAmount = _amount;
     }
     IBSNInterface(BSNData).withdrawPoolMoney(msg.sender, _amount , trueAmount);
     changeCycle(block.number);
     emit MarkerRedeem(msg.sender, _amount, trueAmount, block.timestamp, block.number);
  }
  function receiveDividends (uint _dayNum) public nonReentrant {
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    require(_dayNum < dayNum);
    require(!isDividend[msg.sender][_dayNum]);
    (,, uint marketProvide,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
    require(marketProvide > 0);
    uint dayMarketProvide = IBSNInterface(BSNData).getUserDayMarket(msg.sender, _dayNum);
    require(dayMarketProvide > 0);
    (uint _windToken,,uint _marketToTalMoney,,) = IBSNInterface(BSNData).getCurCycleData(_dayNum);
    uint canReceive = _windToken.mul(dayMarketProvide).div(_marketToTalMoney);
    isDividend[msg.sender][_dayNum] = true;
    IBSNInterface(BSNData).receiveDividends(msg.sender, canReceive, _dayNum, teamAddress, 0);
    emit ReceiveDividends(_dayNum, canReceive, msg.sender);
  }
  function giveDividends (address _user,uint _dayNum) public nonReentrant onlyOwner{
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    require(_dayNum < dayNum);
    require(!isDividend[_user][_dayNum]);
    (,, uint marketProvide,) = IBSNInterface(BSNData).getUserInfo(_user);
    require(marketProvide > 0);
    uint dayMarketProvide = IBSNInterface(BSNData).getUserDayMarket(_user, _dayNum);
    require(dayMarketProvide > 0);
    (uint _windToken,,uint _marketToTalMoney,,) = IBSNInterface(BSNData).getCurCycleData(_dayNum);
    uint canReceive = _windToken.mul(dayMarketProvide).div(_marketToTalMoney);
    uint teamReceive = canReceive.div(100);
    isDividend[_user][_dayNum] = true;
    IBSNInterface(BSNData).receiveDividends(_user, canReceive.sub(teamReceive), _dayNum, teamAddress, teamReceive);
    emit ReceiveDividends(_dayNum, canReceive, _user);
  }
  function getEthUsd () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BETH, BUSD);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BETH, BUSD)).getReserves();
    (uint reserveA, uint reserveB) = BETH == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10**10).div(reserveA);
  }
  function getPerUSdtWind () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BUSD, windToken);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BUSD, windToken)).getReserves();
    (uint reserveA, uint reserveB) = BUSD == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10 ** BUSDDecimals).mul(10 ** 10).div(reserveA).div(windTokenDecimals);
  }
  function getBlockUpAndDown (uint _block, uint _minute) public view returns(uint upTotal, uint downTotal) {
    uint[] memory records = IBSNInterface(BSNData).getBlockRecords(_block, _minute);
    uint _upTotal = 0;
    uint _downTotal = 0;
    for(uint i = 0; i < records.length; i++) {
      (,uint investType,,uint investAmount,,,,,,) = IBSNInterface(BSNData).getOrderById(records[i]);
      if (investType == up) {
        _upTotal = _upTotal.add(investAmount);
      } else {
        _downTotal = _downTotal.add(investAmount);
      }
    }
    return (_upTotal, _downTotal);
  }
  function getBlockPrice(uint _block) public view returns(uint price) {
    uint _price = IOracle(oracle).getMarket(_block);
    return _price;
  }
  function getCurCycleIncome ()  public view returns (uint curAmount, uint marketInvest){
    curAmount = IERC20(BUSD).balanceOf(BSNData);
    marketInvest = IBSNInterface(BSNData).getMarketToTalMoney();
  }
  function getMarketTypeIds () public view returns(uint[] memory _marketTypeIds) {
    return marketTypeIds;
  }
}