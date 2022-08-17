const createNftContract = artifacts.require("createNftContract");
const stakingNft = artifacts.require("StakingContract");
module.exports = function (deployer) {
  deployer.deploy(createNftContract);
  deployer.deploy(stakingNft);
};
