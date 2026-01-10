// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {WavAccess} from "../../src/3WAVi__ORIGINS/WavAccess.sol";

contract WavAccessScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavAccess wavAccess = new WavAccess();
        _facetAddress = address(wavAccess);

        vm.stopBroadcast();
    }
}
