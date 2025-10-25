// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibDiamond} from "../Diamond__Libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../Interfaces/IDiamondLoupe.sol";

library LibDiamondLoupe {
    function facets()
        internal
        view
        returns (IDiamondLoupe.Facet[] memory _facets)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numFacets = ds.facetAddresses.length;
        _facets = new IDiamondLoupe.Facet[](numFacets);
        for (uint256 i = 0; i < numFacets; ) {
            address _facetAddress = ds.facetAddresses[i];
            _facets[i].facetAddress = _facetAddress;
            _facets[i].functionSelectors = ds
                .facetFunctionSelectors[_facetAddress]
                .functionSelectors;
            unchecked {
                ++i;
            }
        }
    } // must return IDiamondLoupe interface

    // look over for reference translation accuracy
    function facetFunctionSelectors(
        address _facet
    ) internal view returns (bytes4[] memory _facetFunctionSelectors) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        _facetFunctionSelectors = ds
            .facetFunctionSelectors[_facet]
            .functionSelectors;
    }

    function facetAddresses()
        internal
        view
        returns (address[] memory _facetAddresses)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        _facetAddresses = ds.facetAddresses;
    }

    function facetAddress(
        bytes4 _functionSelector
    ) internal view returns (address _facetAddress) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        _facetAddress = ds
            .selectorToFacetAndPosition[_functionSelector]
            .facetAddress;
    }
}
