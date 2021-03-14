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
  uint public lastBlance;
  uint public haveTakeAmount;
  uint256 public rewardPerTokenStored;
  uint256 private _totalSupply;

  mapping(address => uint256) public userRewardPerTokenPaid;
  mapping(address => uint256) public rewards;
  mapping(address => uint256) private _balances;
  mapping (address => bool) private accessAllowed;
  event AccessAllowedAddress(address indexed _addr, bool _access);
  event SetWindTokenAddress(address _old, address _new);
  event SetBUSDTokenAddress(address _old, address _new);
  event FreezeToken(address indexed _user, uint _amount, uint _time);
  event WithdrawalWind(address indexed _user, uint _amount, uint _time);
  event RewardPaid(address indexed _user, uint256 _reward, uint _time);
  constructor (address _BUSD, address _windToken) public {
    BUSD = _BUSD;
    windToken = _windToken;
  }

   function setWindTokenAddress(address _windToken) onlyOwner public {
    emit SetWindTokenAddress(windToken, _windToken);
    windToken = _windToken;
  }
   function setBUSDAddress(address _BUSD) onlyOwner public {
    emit SetBUSDTokenAddress(BUSD, _BUSD);
    BUSD = _BUSD;
  }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    function getCurBlance () public view returns(uint){
      return IERC20(BUSD).balanceOf(address(this)).add(haveTakeAmount);
    }
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                getCurBlance().sub(lastBlance).mul(1e18).div(_totalSupply)
            );
    }

      function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        IERC20(windToken).safeTransferFrom(msg.sender, address(this), amount);
        emit FreezeToken(msg.sender, amount, block.timestamp);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        IERC20(windToken).safeTransfer(msg.sender, amount);
        emit WithdrawalWind(msg.sender, amount, block.timestamp);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IERC20(BUSD).safeTransfer(msg.sender, reward);
            haveTakeAmount = haveTakeAmount.add(reward);
            emit RewardPaid(msg.sender, reward, block.timestamp);
        }
    }
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastBlance = getCurBlance();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }
}