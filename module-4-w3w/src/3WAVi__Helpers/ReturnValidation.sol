// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    AuthorizedAddrStorage
} from "../../src/Diamond__Storage/ActiveAddresses/AuthorizedAddrStorage.sol";

library ReturnValidation {
    // <~ Wav Access ~> \\
    error ReturnValidation__AccessProhibited();
    uint96 internal constant SECOND_TO_HOUR_PRECISION = 3600;

    /**
     * @notice Ensures that the function is called only by authorized personnel.
     * @dev Internal function that reverts if the caller is not an authorized address.
     *      Function Selector: 0x8b4db110
     */
    function returnIsAuthorized() internal view {
        AuthorizedAddrStorage.AuthorizedAddrStruct
            storage AuthorizedAddrStructStorage = AuthorizedAddrStorage
                .authorizedAddrStorage();
        if (
            AuthorizedAddrStructStorage.s_authorizedAddrMap[msg.sender] != true
        ) {
            revert ReturnValidation__AccessProhibited();
        }
    }

    /**
     * @notice Provides current timestamp in an hour-based format.
     * @dev Generates timestamp in more compact format
     *      Function Selector: 0x42d86570
     */
    function _returnHourStamp() internal view returns (uint96 _hourStamp) {
        uint256 _timeStamp = block.timestamp;
        _hourStamp = uint96(_timeStamp / SECOND_TO_HOUR_PRECISION);
        //uint96 _timeStamp = uint96(block.timestamp);
        //_hourStamp = _timeStamp / SECOND_TO_HOUR_PRECISION;
        return _hourStamp;
    }
}
