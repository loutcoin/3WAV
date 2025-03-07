// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CContentToken} from "../ContentToken/CContentTokenStorage.sol";
//3
library ContentTokenPriceMapStorage {
    bytes32 constant STORAGE_SLOT =
        keccak256("Content.Token.Price.Map.Storage");

    struct ContentTokenPriceMap {
        mapping(bytes32 hashId => mapping(uint256 priceMap => CContentToken)) s_contentPriceMap;
    }

    function contentTokenPriceMapStorage()
        internal
        pure
        returns (ContentTokenPriceMap storage ContentTokenPriceMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            ContentTokenPriceMapStruct.slot := _storageSlot
        }
    }
}
