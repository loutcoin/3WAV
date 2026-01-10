// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IDiamondLoupe {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return _facets Facet
    function facets() external view returns (Facet[] memory _facets);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return _facetFunctionSelectors
    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory _facetFunctionSelectors);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return _facetAddresses
    function facetAddresses()
        external
        view
        returns (address[] memory _facetAddresses);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return _facetAddress The facet address.
    function facetAddress(
        bytes4 _functionSelector
    ) external view returns (address _facetAddress);
}
