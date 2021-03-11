// const path = require('path')
const Web3 = require('web3')
const web3 = new Web3();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const NonceTrackerSubprovider = require('web3-provider-engine/subproviders/nonce-tracker');
const env = 'dev';
const infuraKey = 'ef06f7345ff54c2d90aa91310d3a1fa9';
const mnemonic =
  env === 'dev'
    ? '7bd88db8482d6f6b11d796d553b032bcb0e3cfa88b263496b62dd770e17e5628'
    : '7bd88db8482d6f6b11d796d553b032bcb0e3cfa88b263496b62dd770e17e5628';

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  // contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      port: 7545
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraKey}`),
      network_id: 3,       // Ropsten's id
      gasPrice: web3.utils.toWei('50', 'gwei'),
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true    // Skip dry run before migrations? (default: false for public nets )
    },
    test: {
      provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-2-s3.binance.org:8545/`),
      network_id: 97,       // Ropsten's id
      gasPrice: web3.utils.toWei('50', 'gwei'),
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true    // Skip dry run before migrations? (default: false for public nets )
    },
    mainnet: {
      provider: function () {
        var wallet = new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/${infuraKey}`);
        var nonceTracker = new NonceTrackerSubprovider();  
        wallet.engine._providers.unshift(nonceTracker);
        nonceTracker.setEngine(wallet.engine); 
       return wallet;
      },
      network_id: 1,
      gasPrice: web3.utils.toWei('20', 'gwei')
    }
  },
  compilers: {
    solc: {
      version: '^0.6.9' // 版本号或约束字符串 - 如： "^0.5.0"
    }
  }
};
