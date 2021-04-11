// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract MarketToken is Ownable{

    string private _marketName;
    uint256 private _decimal;

    mapping(uint => uint) private markets;
    
    constructor(string memory marketname,uint256 decimal) public{
        _marketName = marketname;
        _decimal = decimal;
    }

    function name() public view returns (string memory) {
        return _marketName;
    }

    function decimal() public view returns (uint256) {
        return _decimal;
    }

    function getMarket(uint256 blocknum) public view returns (uint256){
        uint price = markets[blocknum];
        return price;
    }

    function setMarket(uint256 blocknum,uint256 price) public onlyOwner {
        require(price>0,"the price cannot be zero");
        markets[blocknum]=price;
    }

}