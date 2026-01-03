// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    CollaboratorStructStorage
} from "src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    CollaboratorStructStorage
} from "src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    SCollaboratorStructStorage
} from "src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {
    CollaboratorMapStorage
} from "src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";

import {Binary3BitDBC} from "../../../src/3WAVi__Helpers/DBC/Binary3BitDBC.sol";

import {RoyaltyDBC} from "../../../src/3WAVi__Helpers/DBC/RoyaltyDBC.sol";

import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library LibCollaboratorReserve {
    /**
     * @notice Partitions gross revenue into collaborator reserve.
     * @dev Accesses SCollaborator struct and debits earnings based on relevant royalty split
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _cRoyaltyVal Encoded cRoyaltyVal SContentToken data.
     * @param _grossWei Total available ETH share.
     */
    function _allocateSCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken,
        uint32 _cRoyaltyVal,
        uint256 _grossWei
    ) internal returns (uint256 _netWei) {
        if (_grossWei == 0) return 0;

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint32 _cSlot = RoyaltyDBC._cRoyaltyValDecoder(_cRoyaltyVal);
        if (_cSlot == 0) return _grossWei;

        uint256 _collaboratorReserveWei = (_grossWei * uint256(_cSlot)) /
            uint256(NumericalConstants.CRELEASE_6_MAX);

        if (_collaboratorReserveWei > _grossWei) {
            _collaboratorReserveWei = _grossWei;
        }

        CollaboratorMapStruct.s_collaboratorReserve[_hashId][
            _numToken
        ] += _collaboratorReserveWei;

        _netWei = _grossWei - _collaboratorReserveWei;
        return _netWei;
    }

    /**
     * @notice Partitions gross revenue into collaborator reserve.
     * @dev Accesses Collaborator struct and debits earnings based on relevant royalty split
     *      Function Selector: 0x784c9669
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _grossWei Total available ETH share.
     */
    function _allocateCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei,
        uint256 _bitmap
    ) internal returns (uint256) {
        if (_grossWei == 0) return 0;

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint8 _tokenState = Binary3BitDBC._decode3BitState(_bitmap, _numToken);

        uint32 _selectedSlot;

        if (_numToken == 0) {
            uint32 _cSlot = CollaboratorMapStruct
                .s_collaborators[_hashId]
                .cRoyaltyVal;

            uint32 _rawVal = RoyaltyDBC._cRoyaltyValDecoder(_cSlot);
            if (_rawVal == 0) return _grossWei;
            _selectedSlot = _rawVal;
        } else {
            uint128 _cSlot = CollaboratorMapStruct
                .s_collaborators[_hashId]
                .sRoyaltyVal;

            (
                ,
                uint32 r1,
                uint32 r2,
                uint32 r3,
                uint32 r4,
                uint32 r5,
                uint32 r6
            ) = RoyaltyDBC._royaltyValDecoder(_cSlot);
            if (_tokenState == 1) _selectedSlot = r1;
            else if (_tokenState == 2) _selectedSlot = r2;
            else if (_tokenState == 3) _selectedSlot = r3;
            else if (_tokenState == 4) _selectedSlot = r4;
            else if (_tokenState == 5) _selectedSlot = r5;
            else _selectedSlot = r6;

            if (_selectedSlot == 0) return _grossWei;
        }

        uint256 _collaboratorReserveWei = (_grossWei * uint256(_selectedSlot)) /
            uint256(NumericalConstants.CRELEASE_6_MAX);

        if (_collaboratorReserveWei > _grossWei) {
            _collaboratorReserveWei = _grossWei;
        }

        CollaboratorMapStruct.s_collaboratorReserve[_hashId][
            _numToken
        ] += _collaboratorReserveWei;

        uint256 _netWei = _grossWei - _collaboratorReserveWei;
        return _netWei;
    }

    /**
     * @notice Routes call appropriately depending on the stored presence of collaborator royalty data.
     * @dev Checks s_sCollaborators and s_collaborators mappings. If no royalty data is found _grossWei input is returned.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _grossWei Total available ETH share.
     */
    function _collaboratorReserveRouter(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei
    ) internal returns (uint256) {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint32 _cRoyalty = CollaboratorMapStruct
            .s_sCollaborators[_hashId]
            .cRoyaltyVal;
        if (_cRoyalty != 0) {
            return
                _allocateSCollaboratorReserve(
                    _hashId,
                    _numToken,
                    _cRoyalty,
                    _grossWei
                );
        }
        uint256[] storage _cBitmap = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .royaltyMap;

        if (_cBitmap.length > 0 && _cBitmap[0] != 0) {
            (uint256 _bitmap, ) = Binary3BitDBC._get3BitMapPage(
                _cBitmap,
                _numToken
            );
            return
                _allocateCollaboratorReserve(
                    _hashId,
                    _numToken,
                    _grossWei,
                    _bitmap
                );
        } else {
            return _grossWei;
        }
    }
}
