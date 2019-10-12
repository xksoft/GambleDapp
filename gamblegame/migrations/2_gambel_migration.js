const GambleToken = artifacts.require("GambleToken");

module.exports = function(deployer) {
  deployer.deploy(GambleToken);
};
