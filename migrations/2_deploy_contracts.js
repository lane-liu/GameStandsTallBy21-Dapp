var Game = artifacts.require("./GameStandsTallBy21.sol");

module.exports = function(deployer) {
  deployer.deploy(Game);
};
