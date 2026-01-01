// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    LibCollaboratorReserve
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibCollaboratorReserve.sol";

import {
    LibWavReserveSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibWavReserveSupplies.sol";

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

contract ReserveExchange {
    event WavReserveSingle(
        address indexed _recipient,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 _quantity
    );

    /**
     * @notice Handles core logic for the transfer of WavReserve supply.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param _creatorId Address of the Content Token publisher.
     * @param _reserveExchangeToken User-defined ReserveExchangeToken struct.
     */
    function reserveExchangeSingle(
        address _creatorId,
        ReserveExchangeToken.ReserveExchange calldata _reserveExchangeToken
    ) external {
        ReturnValidation.returnIsAuthorized();
        // numToken[0] ALWAYS references to the collective entity
        if (_reserveExchangeToken.numToken == 0) {
            LibWavReserveSupplies.cDebitWavReserve(
                _reserveExchangeToken.hashId,
                _reserveExchangeToken.purchaseQuantity
            );
            // Non-zero numToken refers to seperately sold supplies
        } else {
            // Debit pre-release supply tier
            uint16 _wordIndex = _reserveExchangeToken.numToken >> 6;
            uint8 _within = uint8(_reserveExchangeToken.numToken & 63);

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap
                storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                    .contentTokenSupplyMapStorage();

            uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[
                _reserveExchangeToken.hashId
            ][_wordIndex];
            uint256 _shift = uint256(_within) * 4;
            uint8 _tierId = uint8((_packed >> _shift) & 0xF);
            LibWavReserveSupplies.sDebitWavReserve(
                _reserveExchangeToken.hashId,
                _tierId,
                _reserveExchangeToken.purchaseQuantity
            );
        }

        // WavExchange logic
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        TokenBalanceStruct.s_tokenBalance[_reserveExchangeToken.recipient][
            _reserveExchangeToken.hashId
        ][_reserveExchangeToken.numToken] += uint256(
            _reserveExchangeToken.purchaseQuantity
        );

        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
            _reserveExchangeToken.recipient
        ];

        CreatorTokenMapStruct.s_ownershipMap[_reserveExchangeToken.recipient][
            _ownershipIndex
        ] = _reserveExchangeToken.hashId;
        CreatorTokenMapStruct.s_ownershipToken[_reserveExchangeToken.recipient][
            _ownershipIndex
        ] = _reserveExchangeToken.numToken;

        CreatorTokenMapStruct.s_ownershipIndex[
            _reserveExchangeToken.recipient
        ] = _ownershipIndex + 1;

        emit WavReserveSingle(
            _reserveExchangeToken.recipient,
            _reserveExchangeToken.hashId,
            _reserveExchangeToken.numToken,
            _reserveExchangeToken.purchaseQuantity
        );
    }
}
