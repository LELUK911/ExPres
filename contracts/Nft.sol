// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CostumNFT is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private contractMinter;

    constructor(
        address _newOwner,
        address _contractMinter,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        transferOwnership(_newOwner);
        contractMinter = _contractMinter;
    }

    event Mint(
        uint256 indexed tokenId,
        address indexed assignee,
        string tokenURI
    );

    function _minting(string calldata tokenURI, address _client) internal {
        require(contractMinter == msg.sender, "Not Contract Minter");

        uint256 _tokenId = _tokenIds.current();
        _tokenIds.increment();
        _mint(_client, _tokenId);
        _setTokenURI(_tokenId, tokenURI);
        emit Mint(_tokenId, _client, tokenURI);
    }

    function minting(string calldata tokenURI, address _client)
        external
        nonReentrant
    {
        _minting(tokenURI, _client);
    }
}
