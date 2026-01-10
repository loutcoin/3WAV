// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {CreatorTokenStorage} from "../CreatorToken/CreatorTokenStorage.sol";

library CreatorTokenVariantStorage {
    bytes32 constant STORAGE_SLOT =
        keccak256("Creator.Token.Variant.Struct.Storage");

    struct CreatorTokenVariant {
        CreatorTokenStorage.CreatorToken creatorToken;
        bytes32 baseHashId;
        uint16 variantIndex;
    }

    function creatorTokenVariantStructStorage()
        internal
        pure
        returns (CreatorTokenVariant storage CreatorTokenVariantStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CreatorTokenVariantStruct.slot := _storageSlot
        }
    }
}
