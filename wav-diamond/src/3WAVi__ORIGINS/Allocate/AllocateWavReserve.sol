// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    LibAllocateWavReserveSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/AllocateSupply/LibAllocateWavReserveSupplies.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract AllocateWavReserve {
    event AllocatedToWavReserve(
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 indexed _quantityAllocated
    );

    function allocateUnallocatedToWavReserve(
        WavSaleToken.WavSale calldata _wavSaleToken
    ) external {
        ReturnValidation.returnIsAuthorized;

        {
            LibAllocateWavReserveSupplies._allocateUnallocatedToWavReserve(
                _wavSaleToken
            );
        }

        emit AllocatedToWavReserve(
            _wavSaleToken.hashId,
            _wavSaleToken.numToken,
            _wavSaleToken.purchaseQuantity
        );
    }
}
