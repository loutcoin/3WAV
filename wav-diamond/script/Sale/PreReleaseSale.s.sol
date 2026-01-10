// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {PreReleaseSale} from "../../src/3WAVi__ORIGINS/Sale/PreReleaseSale.sol";

contract PreReleaseSaleScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PreReleaseSale preReleaseSale = new PreReleaseSale();
        _facetAddress = address(preReleaseSale);

        vm.stopBroadcast();
    }
}
