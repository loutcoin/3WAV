// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {WavRoot} from "../src/WavRoot.sol";

import {ReturnValidation} from "../../src/3WAVi__Helpers/ReturnValidation.sol";
//import {ReturnMapping} from "../../src/3WAVi__Helpers/ReturnMapping.sol";

import {
    AuthorizedAddrStorage
} from "../Diamond__Storage/ActiveAddresses/AuthorizedAddrStorage.sol";

import {
    CreatorAliasMapStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorAliasMapStorage.sol";
import {
    CreatorTokenStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {
    CreatorTokenMapStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {
    TokenBalanceStorage
} from "../../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";

/* Allows for myself/team to grant access to individuals to become official artists (capable of publishing content)
Preforms automated cryptographic key checks to return verified 'owned content' accessible in library.
(Can only access content either YOU published as an artist, OR that you've PURCHASED!)
*/

contract WavAccess {
    event Test1a(bool _success);
    event DebugReturnReady(address _owner, uint256 _count);
    event ApprovedAddress(address indexed _approvedAddr);

    event RemovedAddress(address indexed _removedAddr);

    error WavAccess__TokenBalanceZero();
    error WavAccess__AlreadyInitialized();
    /**
     * @notice Returns an array of all content owned by a particular user factoring s_tokenBalance.
     * @dev Function called in a gasless manner to update/refresh user content library.
     *      Function Selector: 0x2a8e407b
     * @param _userAddr Address of the user whose content ownership is being queried.
     * @return CreatorToken An array of all owned CreatorToken assets.
     */
    function returnOwnership(
        address _userAddr
    ) external view returns (CreatorTokenStorage.CreatorToken[] memory) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        uint256 _contentCount = CreatorTokenMapStruct.s_ownershipIndex[
            _userAddr
        ];

        uint256 _validCount = 0;
        for (uint256 i = 0; i < _contentCount; ++i) {
            bytes32 _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
                i
            ];
            if (_hashId == bytes32(0)) continue;

            uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[
                _userAddr
            ][i];
            uint256 _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][
                _hashId
            ][_numToken];
            if (_balance > 0) {
                ++_validCount;
            }
        }
        CreatorTokenStorage.CreatorToken[]
            memory _ownedContentToken = new CreatorTokenStorage.CreatorToken[](
                _contentCount
            );

        uint256 _idx = 0;
        for (uint256 i = 0; i < _contentCount; ++i) {
            bytes32 _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
                i
            ];
            if (_hashId == bytes32(0)) {
                continue;
            }
            uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[
                _userAddr
            ][i];
            uint256 _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][
                _hashId
            ][_numToken];
            if (_balance == 0) continue;

            /*CreatorTokenStorage.CreatorToken
                storage CreatorTokenStruct = CreatorTokenMapStruct
                    .s_publishedTokenData[_hashId][_numToken];*/

            CreatorTokenStorage.CreatorToken
                storage CreatorTokenStruct = CreatorTokenMapStruct
                    .s_publishedTokenData[_hashId];

            _ownedContentToken[i] = CreatorTokenStorage.CreatorToken({
                creatorId: CreatorTokenStruct.creatorId,
                contentId: CreatorTokenStruct.contentId,
                hashId: CreatorTokenStruct.hashId
            });

            ++_idx;
        }

        return _ownedContentToken;
    }

    /**
     * @notice Returns an array of all content owned by a particular user factoring s_tokenBalance.
     * @dev Function called in a gasless manner to update/refresh user content library.
     *      Function Selector: 0x2a8e407b
     * @param _userAddr Address of the user whose content ownership is being queried.
     * @return _hashIds An array of all owned CreatorToken assets.
     * @return _numTokens Index
     */
    function returnOwnership2(
        address _userAddr
    ) external returns (bytes32[] memory _hashIds, uint16[] memory _numTokens) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();

        uint256 _contentCount = CreatorTokenMapStruct.s_ownershipIndex[
            _userAddr
        ];
        _hashIds = new bytes32[](_contentCount);
        _numTokens = new uint16[](_contentCount);

        for (uint256 i = 0; i < _contentCount; ++i) {
            emit Test1a(true);
            bytes32 _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
                i
            ];
            uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[
                _userAddr
            ][i];

            _hashIds[i] = _hashId;
            _numTokens[i] = _numToken;
        }
        emit DebugReturnReady(_userAddr, _contentCount);
        return (_hashIds, _numTokens);
    }

    /*
    TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();
    */

    /*
     * @notice Returns an array of all content owned by a particular user factoring s_tokenBalance.
     * @dev Function called in a gasless manner to update/refresh user content library.
     *      Function Selector: 0x2a8e407b
     * @param _userAddr Address of the user whose content ownership is being queried.
     * @return CreatorToken An array of all owned CreatorToken assets.
     */
    /*function returnOwnership(
        address _userAddr
    ) external view returns (CreatorTokenStorage.CreatorToken[] memory) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        uint256 _contentCount = CreatorTokenMapStruct.s_ownershipIndex[
            _userAddr
        ];

        uint256 _validCount = 0;
        for (uint256 i = 0; i < _contentCount; ++i) {
            bytes32 _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
                i
            ];
            if (_hashId == bytes32(0)) continue;
            uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[
                _userAddr
            ][i];
            uint256 _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][
                _hashId
            ][_numToken];
            if (_balance > 0) {
                ++_validCount;
            }
        }
        if (_validCount == 0) {
            return new CreatorTokenStorage.CreatorToken[](0);
        }

        CreatorTokenStorage.CreatorToken[]
            memory _ownedContent = new CreatorTokenStorage.CreatorToken[](
                _validCount
            );
        uint256 _idx = 0;
        for (uint256 i = 0; i < _contentCount; ++i) {
            bytes32 _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
                i
            ];
            if (_hashId == bytes32(0)) continue;
            uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[
                _userAddr
            ][i];
            uint256 _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][
                _hashId
            ][_numToken];
            if (_balance == 0) continue;

            CreatorTokenStorage.CreatorToken
                storage CreatorTokenStruct = CreatorTokenMapStruct
                    .s_publishedTokenData[_hashId];

            _ownedContent[_idx] = CreatorTokenStorage.CreatorToken({
                creatorId: CreatorTokenStruct.creatorId,
                contentId: CreatorTokenStruct.contentId,
                hashId: CreatorTokenStruct.hashId
            });

            ++_idx;
        }

        return _ownedContent;
    }*/

    function returnOwnershipIndex(
        address _userAddr,
        uint16 _ownershipIndex
    )
        external
        view
        returns (
            bytes32 _hashId,
            uint256 _contentId,
            address _creatorId,
            uint16 _numToken,
            uint256 _balance
        )
    {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();

        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
            _ownershipIndex
        ];
        _numToken = CreatorTokenMapStruct.s_ownershipToken[_userAddr][
            _ownershipIndex
        ];
        _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][_hashId][
            _numToken
        ];

        if (_balance == 0) {
            revert WavAccess__TokenBalanceZero();
        }

        /*CreatorTokenStorage.CreatorToken
            memory _ownedContent = CreatorTokenStorage.CreatorToken({
                creatorId: ,
                contentId: CreatorTokenStruct.contentId,
                hashId: _hashId
            });*/

        CreatorTokenStorage.CreatorToken
            storage CreatorTokenStruct = CreatorTokenMapStruct // so this MUST be _numToken or "dynamic / variable"
            // but the key being pushed in here should likely always be '0'
                .s_publishedTokenData[_hashId];

        _creatorId = CreatorTokenStruct.creatorId;
        _contentId = CreatorTokenStruct.contentId;

        return (_hashId, _contentId, _creatorId, _numToken, _balance);
    }

    function returnOwnershipIndex2(
        address _userAddr,
        uint16 _ownershipIndex
    )
        external
        returns (bytes32 _hashId, address _creatorId, uint256 _contentId)
    {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();

        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
            _ownershipIndex
        ];
        uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[_userAddr][
            _ownershipIndex
        ];
        uint256 _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][
            _hashId
        ][_numToken];

        if (_balance == 0) {
            revert WavAccess__TokenBalanceZero();
        }

        CreatorTokenStorage.CreatorToken
            storage CreatorTokenStruct = CreatorTokenMapStruct // so this MUST be _numToken or "dynamic / variable"
            // but the key being pushed in here should likely always be '0'
                .s_publishedTokenData[_hashId];

        _hashId = CreatorTokenStruct.hashId;
        _creatorId = CreatorTokenStruct.creatorId;
        _contentId = CreatorTokenStruct.contentId;

        emit Test1a(true);
        return (_hashId, _creatorId, _contentId);
        // I should make sure this is not because something is wrong with the index logic of ownershipIndex,
        // but that would barely make sense because why is it returning the exact values and just randomly reverting?
    }

    /*_creatorId = CreatorTokenMapStruct
            .s_publishedTokenData[_hashId][0]*/

    /*CreatorTokenStorage.CreatorToken
                storage CreatorTokenStruct = CreatorTokenMapStruct
                    .s_publishedTokenData[_hashId][_numToken];

         CreatorTokenStorage.CreatorToken({
                creatorId: CreatorTokenStruct.creatorId,
                contentId: CreatorTokenStruct.contentId,
                hashId: CreatorTokenStruct.hashId
            });*/

    //return (_hashId, _creatorId, _numToken, _balance);

    //

    /*function returnCreatorTokenMap(
        CreatorTokenStorage.CreatorToken memory _creatorToken
    ) external returns (CreatorTokenStorage.CreatorToken memory _ct) {
        bytes32 _hashId = _creatorToken.hashId;
        uint16 _numToken = _creatorToken.numToken;
        CreatorTokenMapStorage.CreatorTokenMap storage _creatorTokenMap = CreatorTokenMapStorage.creatorTokenMapStorage();
        return _creatorTokenMap.s_publishedTokenData[_hashId][_numToken];
    }*/

    /**
     * @notice Removes an address from the list of authorized addresses.
     * @dev Callable exclusively by current address(s_lout). Removes an address authorized access.
     * @param _addr The address to removed from the authorized list.
     */
    function removeApprovedAddr(address _addr) external {
        ReturnValidation.returnIsAuthorized();
        AuthorizedAddrStorage.AuthorizedAddrStruct
            storage AuthorizedAddrStructStorage = AuthorizedAddrStorage
                .authorizedAddrStorage();
        AuthorizedAddrStructStorage.s_authorizedAddrMap[_addr] = false;
        emit RemovedAddress(_addr);
        // Other mapping deducted by 1
    }

    /**
     * @notice Adds a new address to the list of currently authorized addresses.
     * @dev Callable exclusively by authorized addresses. Grants authorized access to specified address.
     * @param _addr The address to authorize.
     */
    function addApprovedAddr(address _addr) external {
        ReturnValidation.returnIsAuthorized();
        AuthorizedAddrStorage.AuthorizedAddrStruct
            storage AuthorizedAddrStructStorage = AuthorizedAddrStorage
                .authorizedAddrStorage();
        AuthorizedAddrStructStorage.s_authorizedAddrMap[_addr] = true;
        emit ApprovedAddress(_addr);
    }

    function addOwnerAddr(address _addr) external {
        AuthorizedAddrStorage.AuthorizedAddrStruct
            storage AuthorizedAddrStructStorage = AuthorizedAddrStorage
                .authorizedAddrStorage();

        uint8 _initialization = AuthorizedAddrStructStorage.initialization;

        if (_initialization < 1) {
            AuthorizedAddrStructStorage.s_authorizedAddrMap[_addr] = true;
            AuthorizedAddrStructStorage.s_authorizedAddrSearch[0] = _addr;
            AuthorizedAddrStructStorage.initialization += 1;

            emit ApprovedAddress(_addr);
        } else {
            revert WavAccess__AlreadyInitialized();
        }
    }

    /**
     * @notice Provides current timestamp in an hour-based format.
     * @dev Generates timestamp in more compact format
     *      Function Selector: 0xed91a6c8
     */
    function returnHourStamp() external view returns (uint96 _hourStamp) {
        return ReturnValidation._returnHourStamp();
    }
}
