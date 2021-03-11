var BSNData = artifacts.require("./BSNData.sol");
var BSN = artifacts.require("./Gold.sol");
module.exports = function(deployer) {
  deployer.deploy(BSNData).then((data) => {
    return deployer.deploy(BSN, data.address);
  })
};
