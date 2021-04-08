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
  function totalSupply() external view returns (uint256);
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
    uint _busdPerBeth,
    address _intro
  ) external returns(bool);
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
    function win(uint _amount, address _user,uint _id, uint _investAmount) external;
    function fail (uint _id, uint _investAmount) external;
    function getUserInfo (address _user) external view returns(
    address userAddress,
    uint[] memory records,
    uint marketProvide,
    bool isMarker,
    address intro,
    uint reward,
    address[] memory children
  );
  function addPoolMoney (address _user, uint _amount, address _intro) external returns(bool);
  function withdrawPoolMoney (address _user, uint _amount)  external returns(uint);
  function getCurCycleData (uint _dayNum) external view returns(
    uint windToken,
    uint totalInvest,
    uint totalPay,
    uint marketAdd,
    uint dayMarketTotal,
    uint marketReduce,
    uint poolAmount,
    uint income,
    uint reduce,
    uint proportion
  );
  function getUserDayMarket (address _user, uint _dayNum) external view returns(uint _marketAmount, uint _trueAmount ,bool _isSet);
  function getCurDayStartBlock () external view returns(uint);
  function changeCycle(uint _dayMarketTotal, uint _windToken) external;
  function transferPool(uint _amount) external;
  function getCurDayNum () external view returns(uint);
  function receiveDividends (address _user, uint amount, uint _dayNum, address _teamAddress, uint _teamAmount) external returns(bool);
  function getIsDividend(address _user, uint _dayNum) external view returns(bool isSet);
  function getDayMinuteNum(uint _dayNum, uint _minute) external view returns(uint _amount);
  function getSingleMarketInvest(uint _minute, uint _dayNum) external view returns(uint _amount);
  function setSingleMarketInvest(uint _minute, uint _dayNum, uint _amount) external;
  function getPoolAddress () external view returns(address[] memory _poolAddress);
  function getProportion () external view returns(uint, uint);
  function setUserReward (address _intro, uint _amount, address _user) external;
  function getPoolRatio () external view returns(uint ratio);
  function getPoolInfo(address _poolAddress) external view returns (uint _ratio, bool _isAdd);
  function getTotalMarketWind () external view returns(uint);
  function withdrawTotalBack (address _user) external;
}

interface IStakeInterface {
  function platformStake(uint256 amount, address _user) external;
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
  uint public dayBlockNum = 28800;
  uint public longTail = 183;
  bool isStop = false;
  address public BSNData; // 数据合约地址
  // uint public singleInvestAmount;
  uint[] public marketTypeIds;
  struct MarketType{
    uint minute;
    uint duration;
    uint minAmount;
    uint maxAmount;
    bool isExist;
  }
  address oracle;
  uint constant up = 1;
  uint constant down = 0;
  uint public addMarketMin;
  uint public addMarketMax;
  bool public isHaveWinUsd = false;
  // uint public failRate = 20;
  uint public successRate = 2;
  uint public incomeRate = 90;
  mapping(uint => MarketType) public marketTypes;
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
  event SetRate(uint _old, uint _new);
  event SetLongTail(uint _old, uint _new);
  event SetDayBlockNum(uint _old, uint _new);
  event SetIsStop(bool _old, bool _new);
  event GetReward(address indexed _user, uint _windToken, uint _time);
  event ReceiveDividends(uint _dayNum, uint _canReceive, address indexed _user);
  event SetIncomeRate(uint _old, uint _new);
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
    addMarketMin = 10000 * (10 ** BUSDDecimals);
    addMarketMax = 1000000 * (10 ** BUSDDecimals);
  }
  
  function setHaveWinUsd (bool _have) onlyOwner external {
    emit SetHaveWinUsd(isHaveWinUsd, _have);
    isHaveWinUsd = _have;
  }
  function setIsStop (bool _stop) onlyOwner external {
    emit SetIsStop(isStop, _stop);
    isStop = _stop;
  }
  modifier stop () {
    require(isStop == false, 'is stop');
    _;
  }
  function setDayBlockNum (uint _dayBlockNum) onlyOwner external {
    emit SetDayBlockNum(dayBlockNum, _dayBlockNum);
    dayBlockNum = _dayBlockNum;
  }
  function setPairAddress(address _BETH, address _BUSD) onlyOwner external {
    BETH = _BETH;
    BUSD = _BUSD;
    BUSDDecimals = IERC20(BUSD).decimals();
    // singleInvestAmount = 100 * (10 ** BUSDDecimals);
    emit SetPairAddress(BETH, BUSD);
  }
  function setFactoryAddress(address _factory) onlyOwner external {
    emit SetFactoryAddress(factory, _factory);
    factory = _factory;
  }
  function setTeamAddress(address _teamAddress) onlyOwner external {
    emit SetTeamAddress(teamAddress, _teamAddress);
    teamAddress = _teamAddress;
  }
  function setOracleAddress(address _oracle) onlyOwner external {
    emit SetOracleAddress(oracle, _oracle);
    oracle = _oracle;
  }
  function setBSNDataAddress(address _BSNData) onlyOwner external {
    emit SetBSNDataAddress(BSNData, _BSNData);
    BSNData = _BSNData;
  }
  function setAddMarketLimit(uint _min, uint _max) onlyOwner external {
    require(_max > _min);
    emit SetAddMarketLimit(_min, _max);

    addMarketMin = _min.mul(10 ** BUSDDecimals);
    addMarketMax = _max.mul(10 ** BUSDDecimals);
  }
  function setLongTail(uint _longTail) onlyOwner external {
    emit SetLongTail(longTail, _longTail);
    longTail = _longTail;
  }
  function setRate(uint _successRate) onlyOwner external {
    emit SetRate(successRate, _successRate);
    successRate = _successRate;
  }
  function setIncomeRate(uint _incomeRate) onlyOwner external {
    emit SetIncomeRate(incomeRate, _incomeRate);
    incomeRate = _incomeRate;
  }
  function setWindTokenAddress(address _windToken) onlyOwner external {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
    windTokenDecimals = IERC20(windToken).decimals();
  }
  function addMarketType(uint _minute, uint _duration, uint _minAmount, uint _maxAmount, uint _dayNum, uint _singleMarketInvest) onlyOwner external{
    require(_maxAmount > _minAmount);
    if (!marketTypes[_minute].isExist) {
      marketTypeIds.push(_minute);
      marketTypes[_minute].isExist = true;
    }
    marketTypes[_minute].minute = _minute;
    marketTypes[_minute].duration = _duration;
    marketTypes[_minute].minAmount = _minAmount.mul(10 ** BUSDDecimals);
    marketTypes[_minute].maxAmount = _maxAmount.mul(10 ** BUSDDecimals);
    IBSNInterface(BSNData).setSingleMarketInvest(_minute, _dayNum, _singleMarketInvest.mul(10 ** BUSDDecimals));
  }
  function invest(uint _investType, uint _minute, uint _investAmount, address _intro) external stop nonReentrant {
    require(marketTypes[_minute].isExist);
    require(_investAmount >= marketTypes[_minute].minAmount);
    require(_investAmount <= marketTypes[_minute].maxAmount);
    require(_investType == up || _investType == down);
    require(IERC20(BUSD).balanceOf(msg.sender) >= _investAmount);
    (uint curDayAmount, uint curDayMarketTotal) = getCurCycleIncome();
    if (curDayMarketTotal > curDayAmount) {
       require(curDayMarketTotal.sub(curDayAmount) < curDayMarketTotal.mul(10).div(100));
    }
    // require(_investAmount <= marketTypes[_minute].minute.mul(singleInvestAmount));
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _investAmount);
    uint price = getEthUsd();
    uint openBlock = marketTypes[_minute].duration.add(block.number);
    bool isSet = IBSNInterface(BSNData).invest(msg.sender, uint(_investType), _minute, _investAmount, block.number, block.timestamp, openBlock ,price, _intro);
    emit Invest(msg.sender, block.number, openBlock);
    if(isSet) {
      changeCycle(block.number);
    }
  }
  function changeCycle (uint _block) private {
    uint curBlock = IBSNInterface(BSNData).getCurDayStartBlock();
    if (_block >= curBlock.add(dayBlockNum)) {
      (uint curDayAmount, uint curDayMarketTotal) = getCurCycleIncome();
      uint dayNum = IBSNInterface(BSNData).getCurDayNum();
      for(uint i = 0; i < marketTypeIds.length; i++) {
        uint total = IBSNInterface(BSNData).getDayMinuteNum(dayNum, marketTypeIds[i]);
        uint singleMarketInvest = IBSNInterface(BSNData).getSingleMarketInvest(marketTypeIds[i], dayNum);
        IBSNInterface(BSNData).setSingleMarketInvest(marketTypeIds[i], dayNum.add(1), singleMarketInvest);
        if (total > singleMarketInvest.mul(24)){
          uint limitAmount = curDayMarketTotal.mul(20).div(100).div(marketTypeIds.length) > singleMarketInvest.add(5000 * (10 ** BUSDDecimals)) ? singleMarketInvest.add(5000 * (10 ** BUSDDecimals)) : curDayMarketTotal.mul(20).div(100).div(marketTypeIds.length);
          IBSNInterface(BSNData).setSingleMarketInvest(marketTypeIds[i], dayNum.add(1), limitAmount);
        }
        if (curDayMarketTotal > curDayAmount && curDayMarketTotal.sub(curDayAmount) > curDayMarketTotal.mul(5).div(100)) {
         IBSNInterface(BSNData).setSingleMarketInvest(marketTypeIds[i], dayNum.add(1), singleMarketInvest.div(2));
        }
      }
      uint _dayMarketTotal;
      uint amount;
      uint busdAmount;
      if (curDayAmount <= curDayMarketTotal) {
         _dayMarketTotal = curDayAmount;
         amount = curDayMarketTotal.sub(curDayAmount).div(2);
      } else {
        _dayMarketTotal = curDayMarketTotal;
        amount = curDayAmount.sub(_dayMarketTotal).div(2);
        busdAmount = curDayAmount.sub(curDayMarketTotal);
        IBSNInterface(BSNData).transferPool(busdAmount);
      }
       if (dayNum <= 3) {
          uint amountMarket = curDayMarketTotal.div(100);
          amount = amount > amountMarket ? amount : amountMarket;
       }
       uint windTokenAmount = isHaveWinUsd ? amount.mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 10) : amount.mul(100).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       if (dayNum > longTail) {
         uint totalWindToken = IWindToken(windToken).totalSupply();
         uint fission = dayNum.sub(longTail).div(90);
         windTokenAmount = windTokenAmount > totalWindToken.div(100).div(2 ** fission) ? totalWindToken.div(100).div(2 ** fission) : windTokenAmount;
       }
       uint teamAmount = windTokenAmount.div(9);
       IWindToken(windToken).mint(teamAddress, teamAmount);
       IWindToken(windToken).mint(BSNData, windTokenAmount);
      IBSNInterface(BSNData).changeCycle(_dayMarketTotal, windTokenAmount);
      emit ShareBonus(windTokenAmount, dayNum, busdAmount);
    }
  }
  function openAward (uint _orderId) external nonReentrant {
    (address investor,,,uint investAmount,,,uint openBlock,,,bool isOpen) = IBSNInterface(BSNData).getOrderById(_orderId);
    require(msg.sender == investor);
    require(!isOpen);
    uint openBlockPrice = getBlockPrice(openBlock);
    require(openBlockPrice > 0);
    (uint back, uint winTokenAmount) = getWin(_orderId);
    if (back > 0) {
      IBSNInterface(BSNData).win(back, msg.sender, _orderId, investAmount);
    } else {
      IBSNInterface(BSNData).fail(_orderId, investAmount);
    }
    uint teamAmount = 0;
    uint introAmount = 0;
    if (winTokenAmount > 0) {
      (,,,,address intro,,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
      uint dayNum = IBSNInterface(BSNData).getCurDayNum();
      if (intro != address(0)) {
        (,,,,,uint introReward,) = IBSNInterface(BSNData).getUserInfo(intro);
        introAmount = winTokenAmount.div(2);
        IBSNInterface(BSNData).setUserReward(intro, introReward.add(introAmount), msg.sender);
       }
       teamAmount = (winTokenAmount.add(introAmount)).div(9);
       IWindToken(windToken).mint(teamAddress, teamAmount);
       if (dayNum <= 3) {
         _stakePool(winTokenAmount, msg.sender);
       } else {
         IWindToken(windToken).mint(msg.sender, winTokenAmount); 
       }
    }
    emit OpenAward(back, winTokenAmount, _orderId, msg.sender);
    changeCycle(block.number);
  }
  function getReward () external nonReentrant {
     (,,,,, uint reward,) = IBSNInterface(BSNData).getUserInfo(msg.sender);
     require(reward > 0);
     IBSNInterface(BSNData).setUserReward(msg.sender,0, address(0));
     IWindToken(windToken).mint(msg.sender, reward); 
     emit GetReward(msg.sender, reward, block.timestamp);
  }
  function getWin (uint _orderId) public view returns(uint back, uint winTokenAmount){
    (,uint investType,uint minute,uint _investAmount,uint investBlock,,uint openBlock,uint busdPerBeth,uint investDayNum,) = IBSNInterface(BSNData).getOrderById(_orderId);
    uint openBlockPrice = getBlockPrice(openBlock);
    (uint upTotal, uint downTotal) = getBlockUpAndDown(investBlock, minute);
    uint singleMarketInvest = IBSNInterface(BSNData).getSingleMarketInvest(minute, investDayNum);
    uint investAmount = _investAmount;
    if (busdPerBeth == openBlockPrice) {
      back = investAmount;
      winTokenAmount = 0;
    }
    if (investType == up && busdPerBeth > openBlockPrice) {
      //  winTokenAmount = isHaveWinUsd ? investAmount.mul(failRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(failRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       back = 0;
       winTokenAmount= 0;
    }
    if (investType == up && busdPerBeth < openBlockPrice) {
        back = investAmount.mul(downTotal.add(singleMarketInvest)).mul(incomeRate).div(upTotal.add(singleMarketInvest)).div(100).add(investAmount);
        winTokenAmount = isHaveWinUsd ? investAmount.mul(successRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(successRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
    }
    if(investType == down && busdPerBeth > openBlockPrice) {
       back = investAmount.mul(upTotal.add(singleMarketInvest)).mul(incomeRate).div(downTotal.add(singleMarketInvest)).div(100).add(investAmount);
       winTokenAmount = isHaveWinUsd ? investAmount.mul(successRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(successRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
    }
    if(investType == down && busdPerBeth < openBlockPrice) {
      //  winTokenAmount = isHaveWinUsd ? investAmount.mul(failRate).mul(getPerUsdtWind()).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals).div(10 ** 12) : investAmount.mul(failRate).mul(10 ** windTokenDecimals).div(10 ** BUSDDecimals);
       winTokenAmount = 0;
       back = 0;
    }
  }
  function addMarketPool(uint _amount, address _intro) external nonReentrant {
    require(_amount >= addMarketMin);
    require(_amount <= addMarketMax);
    IERC20(BUSD).safeTransferFrom(msg.sender, BSNData, _amount);
    bool isSet = IBSNInterface(BSNData).addPoolMoney(msg.sender,_amount,_intro);
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    emit AddPoolMoney(msg.sender, _amount, dayNum, block.timestamp);
    if (isSet) {
      changeCycle(block.number);
    }
  }
  function markerRedeem (uint _amount) external nonReentrant {
     require(_amount > 0);
     uint trueAmount = IBSNInterface(BSNData).withdrawPoolMoney(msg.sender, _amount);
     emit MarkerRedeem(msg.sender, _amount, trueAmount, block.timestamp, block.number);
  }
  function receiveDividends (uint _dayNum) external nonReentrant {
    bool isSetDividend = IBSNInterface(BSNData).getIsDividend(msg.sender, _dayNum);
    require(!isSetDividend);
    uint _canReceive = getDividends(_dayNum);
    bool isSet = IBSNInterface(BSNData).receiveDividends(msg.sender, _canReceive, _dayNum, teamAddress, 0);
    emit ReceiveDividends(_dayNum, _canReceive, msg.sender);
    if (isSet) {
      changeCycle(block.number);
    }
  }
  function withdrawTotalBack () external {
    IBSNInterface(BSNData).withdrawTotalBack(msg.sender);
  }
  function getDividends (uint _dayNum) public view returns(uint canReceive) {
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    require(_dayNum < dayNum);
    require(_dayNum >= 1);
    (,uint denominator) = IBSNInterface(BSNData).getProportion();
    (uint dayMarketProvide,,bool isSet)= IBSNInterface(BSNData).getUserDayMarket(msg.sender, _dayNum);
    if (!isSet) {
      for (uint i = _dayNum; i >= 1; i--) {
        (uint _dayMarketProvide,,bool _isSet) = IBSNInterface(BSNData).getUserDayMarket(msg.sender, i);
        if (_isSet) {
          dayMarketProvide = _dayMarketProvide;
          break;
        }
      }
    }
    (uint _windToken,,uint _marketToTalMoney,,,,,,,uint proportion) = IBSNInterface(BSNData).getCurCycleData(_dayNum);
    dayMarketProvide = dayMarketProvide.mul(proportion).div(denominator);
    canReceive = _marketToTalMoney > 0 ? _windToken.mul(dayMarketProvide).div(_marketToTalMoney) : 0;
  }
  function getEthUsd () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BETH, BUSD);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BETH, BUSD)).getReserves();
    (uint reserveA, uint reserveB) = BETH == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10**10).div(reserveA);
  }
  function getPerUsdtWind () public view returns(uint rate) {
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
  function getCurCycleIncome ()  public view returns (uint curAmount, uint curDayMarketTotal){
    uint dayNum = IBSNInterface(BSNData).getCurDayNum();
    (,,,uint marketAdd, uint dayMarketTotal, uint marketReduce,,uint income,uint reduce,uint proportion) = IBSNInterface(BSNData).getCurCycleData(dayNum);
    (,,,,,,,,,uint proportionYes) = IBSNInterface(BSNData).getCurCycleData(dayNum.sub(1));
    curAmount = dayMarketTotal.add(income).add(marketAdd.mul(proportion).div(proportionYes)).sub(reduce).sub(marketReduce);
    curDayMarketTotal = dayMarketTotal.add(marketAdd.mul(proportion).div(proportionYes)).sub(marketReduce);
  }
  function getMarketTypeIds () external view returns(uint[] memory _marketTypeIds) {
    return marketTypeIds;
  }
  function _stakePool (uint256 amount, address _user) private {
    address[] memory poolAddress = IBSNInterface(BSNData).getPoolAddress();
    uint ratio = IBSNInterface(BSNData).getPoolRatio();
    for(uint i = 0; i<poolAddress.length; i++) {
      (uint _ratio,) = IBSNInterface(BSNData).getPoolInfo(poolAddress[i]);
      IStakeInterface(poolAddress[i]).platformStake(amount.mul(_ratio).div(ratio), _user);
      IWindToken(windToken).mint(poolAddress[i], amount.mul(_ratio).div(ratio));
    }
  }
}