pragma solidity ^0.6.9;
interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}
library UniswapV2Library {
    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
    }
}

contract Study {
  address public BETH = address(0x163f9d7a590e1921C1461bf6eD455B67E7877E95);
  address public BUSD = address(0xc74cc783ed2dBCd06e06266E72aD9d9680Cf3CEE);
  address public factory = address(0xd417A0A4b65D24f5eBD0898d9028D92E3592afCC);
  function getEthUsd () public view returns(uint rate) {
    (address token0,) = UniswapV2Library.sortTokens(BETH, BUSD);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(BETH, BUSD)).getReserves();
    (uint reserveA, uint reserveB) = BETH == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    rate = reserveB.mul(10**10).div(reserveA);
  }
}