// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    LibCollaboratorReserve
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibCollaboratorReserve.sol";

import {
    LibWavReserveSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/DebitSupply/LibWavReserveSupplies.sol";

import {ReleaseDBC} from "../../../src/3WAVi__Helpers/DBC/ReleaseDBC.sol";

import {
    CreatorProfitStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";

import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    CreatorTokenMapStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";

import {
    TokenBalanceStorage
} from "../../../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";

import {
    ReserveExchangeToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/ReserveExchangeToken.sol";

contract ReserveExchangeBatch {
    event ReserveExchangeBatchQuantity(
        address indexed _creatorId,
        uint256 indexed _contentCount
    );

    event ReserveExchangeBatchIndex(
        address indexed _recipient,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 _quantity
    );

    error ReserveExchangeBatch__LengthMismatch();

    /**
     * @notice Handles core logic for batch transfers of WavReserve supply.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param _creatorId Address of the Content Token publisher.
     * @param _reserveExchangeToken Batch of user-defined ReserveExchangeToken structs.
     */
    function reserveExchangeBatch(
        address _creatorId,
        ReserveExchangeToken.ReserveExchange[] calldata _reserveExchangeToken
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (_reserveExchangeToken.length < 2) {
            revert ReserveExchangeBatch__LengthMismatch();
        }

        // WavExchange logic
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        for (uint256 i = 0; i < _reserveExchangeToken.length; ) {
            address _recipient = _reserveExchangeToken[i].recipient;
            bytes32 _hashId = _reserveExchangeToken[i].hashId;
            uint16 _numToken = _reserveExchangeToken[i].numToken;
            uint112 _quantity = _reserveExchangeToken[i].purchaseQuantity;

            if (_numToken == 0) {
                LibWavReserveSupplies.cDebitWavReserve(_hashId, _quantity);
            } else {
                uint16 _wordIndex = _numToken >> 6;
                uint8 _within = uint8(_numToken & 63);

                ContentTokenSupplyMapStorage.ContentTokenSupplyMap
                    storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                        .contentTokenSupplyMapStorage();

                uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[
                    _hashId
                ][_wordIndex];
                uint256 _shift = uint256(_within) * 4;
                uint8 _tierId = uint8((_packed >> _shift) & 0xF);
                LibWavReserveSupplies.sDebitWavReserve(
                    _hashId,
                    _tierId,
                    _quantity
                );
            }
            TokenBalanceStruct.s_tokenBalance[_recipient][_hashId][
                _numToken
            ] += uint256(_quantity);

            uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
                _recipient
            ];
            CreatorTokenMapStruct.s_ownershipMap[_recipient][
                _ownershipIndex
            ] = _hashId;
            CreatorTokenMapStruct.s_ownershipToken[_recipient][
                _ownershipIndex
            ] = _numToken;

            CreatorTokenMapStruct.s_ownershipIndex[_recipient] =
                _ownershipIndex +
                1;

            emit ReserveExchangeBatchIndex(
                _reserveExchangeToken[i].recipient,
                _reserveExchangeToken[i].hashId,
                _reserveExchangeToken[i].numToken,
                _reserveExchangeToken[i].purchaseQuantity
            );

            unchecked {
                ++i;
            }
        }

        emit ReserveExchangeBatchQuantity(
            _creatorId,
            _reserveExchangeToken.length
        );
    }
}
