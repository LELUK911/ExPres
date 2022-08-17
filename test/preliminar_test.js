const nftGenerator = artifacts.require("createNftContract");
const IERC721 = artifacts.require("IERC721");
const stakingContract = artifacts.require("StakingContract");
const truffleAssert = require("truffle-assertions");

contract("Preliminar Test", (accounts) => {
  const Owners = accounts[0];
  const client1 = accounts[1];
  const client2 = accounts[2];

  it("Client can generate new Nft contract?", async () => {
    const generator = await nftGenerator.deployed();

    const tx = await generator.newContractNft(client1, "firstNft", "1nft", {
      from: client1,
    });
    //console.log(tx);
  });
  it("client can mint many NFT ?", async () => {
    const generator = await nftGenerator.deployed();
    //executeMint(uint256 _amount,uint256 _idNftContract,string calldata tokenURI,address _client
    const tx = await generator.executeMint(
      10,
      0,
      `{name:"StockNFT",describ:"sell at end vesting at 104% value to buy"}`,
      client1,
      { from: client1 }
    );
    //console.log(tx)
  });
  it("can client register nft for next staking?", async () => {
    const stC = await stakingContract.deployed();
    const generator = await nftGenerator.deployed();

    const nftMint = await generator.newContractNft(
      client1,
      "firstNft",
      "1nft",
      {
        from: client1,
      }
    );

    await stC.registerNftForStaking(
      nftMint.logs[0].address,
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      { from: client1 }
    );
  });
});
