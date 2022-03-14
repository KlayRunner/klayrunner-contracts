var KlayRunner = artifacts.require('KlayRunner');

module.exports = function(deployer) {
  deployer.deploy(KlayRunner, 'KlayRunner', 'KLR', 'unknownhost', 100, 100000000000000000n, 5, { gas: 100000000 })
};
