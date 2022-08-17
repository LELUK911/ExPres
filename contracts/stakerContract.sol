// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingContract {
    struct NftRegistered {
        address nftAddress;
        address NftOwner;
        uint256[] series;
    }

    NftRegistered[] private register;

    struct StakingReward {
        address owner;
        address reward;
        uint256 amountReward;
        uint256 emission;
        uint256 blockEnd;
        address nftContractStaking;
    }
    StakingReward[] private stakingReward;

    constructor() {}

    mapping(address => uint256[]) internal nftStakeForUser;
    mapping(address => mapping(uint256 => uint256)) internal blockStart;

    function _registerNftForStaking(
        address _nftAddress,
        address _nftOwner,
        uint256[] memory _series
    ) internal {
        //mancano controlli
        register.push(NftRegistered(_nftAddress, _nftOwner, _series));
    }

    function _setStakingReward(
        address _client,
        address _asset,
        uint256 _amount,
        uint256 _emission,
        uint256 _blockEnd,
        address _nftContract
    ) internal {
        IERC20(_asset).transferFrom(_client, address(this), _amount);

        stakingReward.push(
            StakingReward(
                _client,
                _asset,
                _amount,
                _emission,
                _blockEnd,
                _nftContract
            )
        );
    }

    function _cechSeries(uint256 _idNft, uint256 _idContract)
        internal
        view
        returns (bool response)
    {
        for (uint256 i; i < register[_idContract].series.length; i++) {
            if (register[_idContract].series[i] == _idNft) {
                response = true;
            }
        }
        response = false;
    }

    function _srcStakingRewardInfo(address _nftContractStaking)
        public
        view
        returns (StakingReward memory infomation)
    {
        for (uint256 i = 0; i < stakingReward.length; i++) {
            if (stakingReward[i].nftContractStaking == _nftContractStaking) {
                infomation = stakingReward[i];
            }
        }
        infomation = StakingReward(address(0), address(0), 0, 0, 0, address(0));
    }

    function userStakeNft(
        address _nftContract,
        address _user,
        uint256 _tokenId,
        uint256 _idNftRegisteredReward
    ) internal {
        require(
            register[_idNftRegisteredReward].nftAddress == _nftContract,
            "Stakin campain not present in this moment"
        );
        require(
            _cechSeries(_tokenId, _idNftRegisteredReward),
            "Series not in list reward"
        );
        IERC721(_nftContract).transferFrom(_user, address(this), _tokenId);
        require(
            _srcStakingRewardInfo(_nftContract).blockEnd > block.timestamp,
            "time for reward expired"
        );
        blockStart[_user][_tokenId] = block.timestamp;
        nftStakeForUser[_user].push(_tokenId);
    }

    function _srcNftStakeForUser(uint256 _tokenId, address _user)
        public
        view
        returns (uint256 indexToken, bool response)
    {
        for (
            uint256 index = 0;
            index < nftStakeForUser[_user].length;
            index++
        ) {
            if (nftStakeForUser[_user][index] == _tokenId) {
                indexToken = index;
                response = true;
            }
        }
        indexToken = 0;
        response = true;
    }

    function _unstakeNftAndReward(
        address _nftContract,
        address _user,
        uint256 _tokenId
    ) internal {
        require(
            _srcStakingRewardInfo(_nftContract).blockEnd <= block.timestamp,
            "time lock not expired"
        );
        (uint256 index, bool response) = _srcNftStakeForUser(_tokenId, _user);
        require(response, "NftId not present");
        uint256 _blockStart = blockStart[_user][_tokenId];
        blockStart[_user][_tokenId] = 0;
        nftStakeForUser[_user][index] = nftStakeForUser[_user][
            nftStakeForUser[_user].length - 1
        ];
        nftStakeForUser[_user].pop();

        uint256 rewardUser = (_srcStakingRewardInfo(_nftContract).emission *
            (_srcStakingRewardInfo(_nftContract).blockEnd - _blockStart));

        // miss sistem remove token staking from balance for staking
        IERC721(_nftContract).transferFrom(address(this), _user, _tokenId);
        // problay line balanceReward[_client][_asset][_nftContract] -= rewardUser;
        IERC20((_srcStakingRewardInfo(_nftContract).reward)).transfer(
            _user,
            rewardUser
        );
    }

    function registerNftForStaking(
        address _nftAddress,
        uint256[] memory _series
    ) external {
        _registerNftForStaking(_nftAddress, msg.sender, _series);
    }

    function setStakingReward(
        address _asset,
        uint256 _amount,
        uint256 _emission,
        uint256 _blockEnd,
        address _nftContract
    ) external {
        _setStakingReward(
            msg.sender,
            _asset,
            _amount,
            _emission,
            _blockEnd,
            _nftContract
        );
    }

    function UserStakeNft(
        address _nftContract,
        address _user,
        uint256 _tokenId,
        uint256 _idNftRegisteredReward
    ) external {
        userStakeNft(_nftContract, _user, _tokenId, _idNftRegisteredReward);
    }

    function unstakeNftAndReward(address _nftContract, uint256 _tokenId)
        external
    {
        _unstakeNftAndReward(_nftContract, msg.sender, _tokenId);
    }
}
