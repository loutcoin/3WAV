// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishSVariant
} from "../../src/3WAVi__ORIGINS/Publish/PublishSVariant.sol";

contract PublishSVariantScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishSVariant publishSVariant = new PublishSVariant();
        _facetAddress = address(publishSVariant);

        vm.stopBroadcast();
    }
}
