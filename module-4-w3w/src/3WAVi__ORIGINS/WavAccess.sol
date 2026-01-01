// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReturnValidation} from "../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    AuthorizedAddrStorage
} from "../Diamond__Storage/ActiveAddresses/AuthorizedAddrStorage.sol";

import {
    CreatorTokenStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {
    CreatorTokenMapStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {
    TokenBalanceStorage
} from "../../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";

contract WavAccess {
    event ApprovedAddress(address indexed _approvedAddr);
    event RemovedAddress(address indexed _removedAddr);

    error WavAccess__TokenBalanceZero();
    error WavAccess__AlreadyInitialized();

    /**
     * @notice Returns an array of all content owned by a particular user factoring s_tokenBalance.
     * @dev Function called in a gasless manner to update/refresh user content library.
     *      Function Selector: 0x2a8e407b
     * @param _userAddr Address of the user whose content ownership is being queried.
     * @return _hashIds An array of all owned CreatorToken assets.
     * @return _numTokens Index
     */
    function returnOwnership(
        address _userAddr
    )
        external
        view
        returns (
            bytes32[] memory _hashIds,
            uint16[] memory _numTokens,
            uint256[] memory _balances
        )
    {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();

        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        uint256 _contentCount = CreatorTokenMapStruct.s_ownershipIndex[
            _userAddr
        ];
        _hashIds = new bytes32[](_contentCount);
        _numTokens = new uint16[](_contentCount);
        _balances = new uint256[](_contentCount);

        for (uint256 i = 0; i < _contentCount; ++i) {
            bytes32 _hashId = CreatorTokenMapStruct.s_ownershipMap[_userAddr][
                i
            ];
            uint16 _numToken = CreatorTokenMapStruct.s_ownershipToken[
                _userAddr
            ][i];
            uint256 _balance = TokenBalanceStruct.s_tokenBalance[_userAddr][
                _hashId
            ][_numToken];

            _hashIds[i] = _hashId;
            _numTokens[i] = _numToken;
            _balances[i] = _balance;
        }
        return (_hashIds, _numTokens, _balances);
    }

    /**
     * @notice Returns content ownership data in relation to an address user and ownership index.
     * @dev Function called in a gasless manner to parse specified ownership index data.
     * @param _userAddr Address of the user whose content ownership is being queried.
     * @return _hashId Identifier of Content Token being queried.
     * @return _numToken Content Token identifier used to specify the token index being queried.
     * @return _balance Quantity of the specified Content Token owned by the user.
     */
    function returnOwnershipIndex(
        address _userAddr,
        uint16 _ownershipIndex
    )
        external
        view
        returns (bytes32 _hashId, uint16 _numToken, uint256 _balance)
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

        CreatorTokenStorage.CreatorToken
            storage CreatorTokenStruct = CreatorTokenMapStruct
                .s_publishedTokenData[_hashId];

        _hashId = CreatorTokenStruct.hashId;

        return (_hashId, _numToken, _balance);
    }

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

    /**
     * @notice Initializes system owner address.
     * @dev Initialization will revert if attempted more than once.
     * @param _addr Address to initialize as the system owner.
     */
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
