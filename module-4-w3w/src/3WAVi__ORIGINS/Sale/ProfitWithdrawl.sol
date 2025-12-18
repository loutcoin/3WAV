// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CreatorProfitStorage} from "../../../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";
//import {ReturnMapping} from "../../../src/3WAVi__Helpers/ReturnMapping.sol";

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
        address payable _to, // Address to send the funds to
        uint256 _amount // Amount to withdraw
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
}
