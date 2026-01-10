// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishCVariant
} from "../../src/3WAVi__ORIGINS/Publish/PublishCVariant.sol";

contract PublishCVariantScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishCVariant publishCVariant = new PublishCVariant();
        _facetAddress = address(publishCVariant);

        vm.stopBroadcast();
    }
}
