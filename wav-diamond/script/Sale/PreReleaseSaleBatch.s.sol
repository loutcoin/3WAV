// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PreReleaseSaleBatch
} from "../../src/3WAVi__ORIGINS/Sale/PreReleaseSaleBatch.sol";

contract PreReleaseSaleBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PreReleaseSaleBatch preReleaseSaleBatch = new PreReleaseSaleBatch();
        _facetAddress = address(preReleaseSaleBatch);

        vm.stopBroadcast();
    }
}
