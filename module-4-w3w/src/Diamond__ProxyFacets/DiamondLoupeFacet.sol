// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {LibDiamond} from "../Diamond__Libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../Interfaces/IDiamondLoupe.sol";

contract DiamondLoupeFacet is IDiamondLoupe {
    /// @notice Gets all facets and their selectors.
    /// @return _facets
    function facets() external view override returns (Facet[] memory _facets) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numFacets = ds.facetAddresses.length;
        _facets = new Facet[](numFacets);
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
    }

    /// @notice Gets all the function selectors provided by a facet.
    /// @param _facet The address of the provided facet value.
    /// @return _facetFunctionSelectors
    function facetFunctionSelectors(
        address _facet
    ) external view override returns (bytes4[] memory _facetFunctionSelectors) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        _facetFunctionSelectors = ds
            .facetFunctionSelectors[_facet]
            .functionSelectors;
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return _facetAddresses
    function facetAddresses()
        external
        view
        override
        returns (address[] memory _facetAddresses)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        _facetAddresses = ds.facetAddresses;
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found, will return address(0).
    /// @param _functionSelector The function selector.
    /// @return _facetAddress
    function facetAddress(
        bytes4 _functionSelector
    ) external view override returns (address _facetAddress) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        _facetAddress = ds
            .selectorToFacetAndPosition[_functionSelector]
            .facetAddress;
    }
}
