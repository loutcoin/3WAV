// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {WavSale} from "../../src/3WAVi__ORIGINS/Sale/WavSale.sol";

contract WavSaleScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavSale wavSale = new WavSale();
        _facetAddress = address(wavSale);

        vm.stopBroadcast();
    }
}
