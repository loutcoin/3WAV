// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    DiamondLoupeFacet
} from "../../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";

contract DiamondLoupeFacetScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        _facetAddress = address(diamondLoupeFacet);

        vm.stopBroadcast();
    }
}
