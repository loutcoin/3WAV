// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    DiamondCutFacet
} from "../../src/Diamond__ProxyFacets/DiamondCutFacet.sol";

contract DiamondCutFacetScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        _facetAddress = address(diamondCutFacet);

        vm.stopBroadcast();
    }
}
