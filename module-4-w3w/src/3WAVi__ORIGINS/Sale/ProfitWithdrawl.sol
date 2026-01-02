// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    CreatorProfitStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";

import {
    ReturnMapMapping
} from "../../../src/3WAVi__Helpers/ReturnMapping/ReturnMapMapping.sol";

contract ProfitWithdrawl {
    error ProfitWithdrawl__InsufficientEarnings();
    error ProfitWithdrawl__TransferFailed();
    /**
     * @notice Withdraws earnings from the caller's balance.
     * @dev Ensures sufficient balance, updates and transfers value. Gasless checks and automated inputs preformed by front-end.
     * @param _creatorId The address of the creator.
     * @param _to The address to send the funds to.
     * @param _amount The amount to withdraw.
     */
    function withdrawEthEarnings(
        address _creatorId,
        bytes32 _hashId,
        address payable _to,
        uint256 _amount
    ) external {
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        uint256 _earnings = CreatorProfitStructStorage.s_ethEarnings[
            _creatorId
        ][_hashId];
        // Ensure caller has enough balance
        if (_earnings < _amount) {
            revert ProfitWithdrawl__InsufficientEarnings();
        }
        _earnings -= _amount;
        CreatorProfitStructStorage.s_ethEarnings[_creatorId][
            _hashId
        ] = _earnings;

        // Safe Transfer Pattern
        (bool _sent, ) = _to.call{value: _amount}("");
        if (!_sent) {
            revert ProfitWithdrawl__TransferFailed();
        }
    }

    /**
     * @notice Returns associated earnings pool of a Content Token.
     * @dev Returns unclaimed balance of provided hashId.
     * @param _creatorId Address of the publisher.
     * @param _hashId Identifier of Content Token being queried.
     */
    function returnEthEarnings(
        address _creatorId,
        bytes32 _hashId
    ) external view returns (uint256 _earnings) {
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        _earnings = CreatorProfitStructStorage.s_ethEarnings[_creatorId][
            _hashId
        ];
        return _earnings;
    }

    /**
     * @notice Returns associated collaborator reserve of a Content Token.
     * @dev Returns unclaimed collaborator earnings of provided hashId.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     */
    function getCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken
    ) external view returns (uint256 _value) {
        _value = ReturnMapMapping._returnCollaboratorReserve(
            _hashId,
            _numToken
        );
        return _value;
    }
}
