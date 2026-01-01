// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    ProfitWithdrawl
} from "../../src/3WAVi__ORIGINS/Sale/ProfitWithdrawl.sol";

contract ProfitWithdrawlScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        ProfitWithdrawl profitWithdrawl = new ProfitWithdrawl();
        _facetAddress = address(profitWithdrawl);

        vm.stopBroadcast();
    }
}
