// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Nft.sol";

contract createNftContract is Ownable, ReentrancyGuard {
    CostumNFT[] private Nft;
    mapping(address => uint256[]) nftOwner;

    constructor() {}

    function _newContractNft(
        address _newOwner,
        string memory name_,
        string memory symbol_
    ) internal {
        CostumNFT _nft = new CostumNFT(
            _newOwner,
            address(this),
            name_,
            symbol_
        );
        Nft.push(_nft);
        nftOwner[_newOwner].push(Nft.length - 1);
    }

    function _executeMint(
        uint256 _amount,
        uint256 _idNftContract,
        string calldata tokenURI,
        address _client
    ) internal {
        for (uint256 i; i < _amount; i++) {
            CostumNFT(Nft[_idNftContract]).minting(tokenURI, _client);
        }
    }

    function newContractNft(
        address _newOwner,
        string memory name_,
        string memory symbol_
    ) external {
        _newContractNft(_newOwner, name_, symbol_);
    }

    function executeMint(
        uint256 _amount,
        uint256 _idNftContract,
        string calldata tokenURI,
        address _client
    ) external {
        //require(_findOwner(msg.sender, _idNftContract), "not autorizate");
        _executeMint(_amount, _idNftContract, tokenURI, _client);
    }

    //await c.executeMint(5,0,"{name:"Luk",descript:"fa questo e quello"}",accounts[1])

    function getNftContract(uint256 id) external view returns (CostumNFT addC) {
        addC = Nft[id];
    }

    function _findOwner(address _owner, uint256 _id)
        internal
        view
        returns (bool response)
    {
        for (uint256 i; i < nftOwner[_owner].length; i++) {
            if (nftOwner[_owner][i] == _id) {
                response = true;
            }
        }
        response = false;
    }
}
