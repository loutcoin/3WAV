// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishCContentToken
} from "../../src/3WAVi__ORIGINS/Publish/PublishCContentToken.sol";

contract PublishCContentTokenScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishCContentToken publishCContentToken = new PublishCContentToken();
        _facetAddress = address(publishCContentToken);

        vm.stopBroadcast();
    }
}
