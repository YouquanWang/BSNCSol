pragma solidity ^0.6.9;
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract Frozen is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public BUSD;
  address public windToken;

  struct User {
    uint frozenAmount;
    uint busdAmount;
    uint withdrawalAmount;
    bool isExist;
  }
  mapping(address => User) public users;
    mapping (address => bool) private accessAllowed;
  event AccessAllowedAddress(address indexed _addr, bool _access);
  event SetWindTokenAddress(address _old, address _new);
  event SetBUSDTokenAddress(address _old, address _new);
  event FreezeToken(address indexed _user, uint _amount, uint _time);
  event WithdrawalWind(address indexed _user, uint _amount, uint _time);
  event ThawWind(address indexed _user, uint _amount, uint _time);
  constructor (address _BUSD, address _windToken) public {
    BUSD = _BUSD;
    windToken = _windToken;
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
  function setWindTokenAddress(address _windToken) onlyOwner public {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
  }
  function setBUSDTokenAddress(address _BUSD) onlyOwner public {
    emit SetBUSDTokenAddress(BUSD, _BUSD);
    BUSD = _BUSD;
  }
  function freezeToken (uint _amount) external nonReentrant {
    require(_amount > 0);
    if (users[msg.sender].isExist) {
      _withdrawalWind(msg.sender);
      users[msg.sender].frozenAmount = users[msg.sender].frozenAmount.add(_amount);
    } else {
      User memory _user = users[msg.sender];
     _user.frozenAmount = _amount;
     _user.isExist = true;
     _user.busdAmount = IERC20(BUSD).balanceOf(address(this));
     users[msg.sender] = _user;
   }
   IERC20(windToken).safeTransferFrom(msg.sender, address(this), _amount);
   emit FreezeToken(msg.sender, _amount, block.timestamp);
  }
  function _withdrawalWind (address _user) private {
    require(users[_user].frozenAmount > 0);
    uint _usdAmount = IERC20(BUSD).balanceOf(address(this));
    uint _amount = _usdAmount > users[_user].busdAmount ? _usdAmount.sub(users[_user].busdAmount) : 0;
    uint _wintoken = IERC20(windToken).balanceOf(address(this));
    uint _userRecive = _amount.mul(users[_user].frozenAmount).div(_wintoken);
    users[_user].busdAmount = _usdAmount.sub(_userRecive);
    users[_user].withdrawalAmount = users[_user].withdrawalAmount.add(_userRecive);
    if (_userRecive > 0) {
      IERC20(BUSD).safeTransfer(_user, _userRecive);
    }
    emit WithdrawalWind(_user, _userRecive, block.timestamp);
  }
  function withdrawalWind () external nonReentrant {
    require(users[msg.sender].isExist);
    _withdrawalWind(msg.sender);
  }
  function thawWind() external nonReentrant {
    require(users[msg.sender].isExist);
    require(users[msg.sender].frozenAmount > 0);
    uint frozenAmount = users[msg.sender].frozenAmount;
    users[msg.sender].frozenAmount = 0;
    _withdrawalWind(msg.sender);
    IERC20(windToken).safeTransfer(msg.sender, frozenAmount);
    emit ThawWind(msg.sender, frozenAmount, block.timestamp);
  }
}