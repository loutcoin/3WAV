// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library ReturnValidation {
    // <~ Wav Access ~> \\

    /**
     * @notice Ensures that the function is called only by authorized personnel.
     * @dev Internal function that reverts if the caller is not an authorized address.
     *      Function Selector: 0x8b4db110
     */
    function onlyAuthorized() internal view {
        if (msg.sender != s_lout && !s_authorizedAddr[msg.sender]) {
            revert WavStore__IsNotLout();
        }
    }

    /** MAYBE belongs as external view in WavAccess
     * @notice Checks if an alias is already taken.
     * @dev Ensures that the desired alias is not already associated with another artist.
     *      Function Selector: 0xd97eaaa9
     * @param _creatorAlias The username to be checked.
     */
    function checkAlias(string memory _creatorAlias) internal view {
        if (s_aliasToAddr[_creatorAlias] != address(0)) {
            revert WavAccess__NameIsTaken();
        }
    }
}
