// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    LibAllocateWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/AllocateSupply/LibAllocateWavSupplies.sol";

// consolidate into LibAllocateWavSupplies by moving shift logic for maximum slot access efficiency
import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract AllocateWavStore {
    event AllocatedToWavStore(
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 indexed _quantityAllocated
    );

    function allocateUnallocatedToWavStore(
        WavSaleToken.WavSale calldata _wavSaleToken
    ) external {
        ReturnValidation.returnIsAuthorized;

        {
            LibAllocateWavSupplies._allocateUnallocatedToWavStore(
                _wavSaleToken
            );
        }

        emit AllocatedToWavStore(
            _wavSaleToken.hashId,
            _wavSaleToken.numToken,
            _wavSaleToken.purchaseQuantity
        );
    }
}
