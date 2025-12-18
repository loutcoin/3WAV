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
    // THIS FUNCTION COULD AND SHOULD BE MADE MUCH BETTER IMO
    /*
     * @notice Partitions gross revenue into collaborator reserve.
     * @dev Accesses Collaborator struct and debits earnings based on relevant royalty split
     *      Function Selector: 0x784c9669
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _grossWei Total available ETH share.
     */
    /*function _allocateCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei
    ) internal returns (uint256) {
        if (_grossWei == 0) return 0;

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        CollaboratorStructStorage.Collaborator
            storage CollaboratorStruct = CollaboratorStructStorage
                .collaboratorStructStorage();

        CollaboratorMapStruct.s_collaborators[_hashId];

        // Needs to be altered to access s_collaborators
        //uint256 _bitmap = CollaboratorMapStruct.s_royalties[_hashId];
        // *** NTS: Specific "page" is to be determined relative to numToken being queried.
        // That can probably be done in a simple sub-function (I think we have to do something similar elsewhere already)
        uint256 _bitmap = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .royaltyMap;

        //uint8 _tokenState = Binary3BitDBC._encode3BitState(_hashId, _numToken);
        uint8 _tokenState = Binary3BitDBC._decode3BitState(_bitmap, _numToken);

        if (CollaboratorStruct.numCollaborator == 0 || _tokenState == 0) {
            // Collaborators disabled for numToken
            return _grossWei;
        }

        uint32 _selectedSlot;

        (
            ,
            uint32 r1,
            uint32 r2,
            uint32 r3,
            uint32 r4,
            uint32 r5,
            uint32 r6
        ) = RoyaltyDBC._royaltyValDecoder(CollaboratorStruct.royaltyVal);
        if (_tokenState == 1) _selectedSlot = r1;
        else if (_tokenState == 2) _selectedSlot = r2;
        else if (_tokenState == 3) _selectedSlot = r3;
        else if (_tokenState == 4) _selectedSlot = r4;
        else if (_tokenState == 5) _selectedSlot = r5;
        else _selectedSlot = r6;

        if (_selectedSlot == 0) return _grossWei;

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
    }*/

    /*
     * @notice Partitions gross revenue into collaborator reserve.
     * @dev Accesses Collaborator struct and debits earnings based on relevant royalty split
     *      Function Selector: 0x784c9669
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _grossWei Total available ETH share.
     */
    /*function _allocateSCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei
    ) internal returns (uint256) {
        if (_grossWei == 0) return 0;

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        SCollaboratorStructStorage.SCollaborator
            storage SCollaboratorStruct = SCollaboratorStructStorage
                .sCollaboratorStructStorage();

        CollaboratorMapStruct.s_sCollaborators[_hashId];

        // Needs to be altered to access s_collaborators
        //uint256 _bitmap = CollaboratorMapStruct.s_royalties[_hashId];
        // *** NTS: Specific "page" is to be determined relative to numToken being queried.
        // That can probably be done in a simple sub-function (I think we have to do something similar elsewhere already)
        uint256 _bitmap = CollaboratorMapStruct
            .s_sCollaborators[_hashId]
            .royaltyMap;

        //uint8 _tokenState = Binary3BitDBC._encode3BitState(_hashId, _numToken);
        uint8 _tokenState = Binary3BitDBC._decode3BitState(_bitmap, _numToken);

        if (CollaboratorStruct.numCollaborator == 0 || _tokenState == 0) {
            // Collaborators disabled for numToken
            return _grossWei;
        }

        uint32 _selectedSlot;

        (
            ,
            uint32 r1,
            uint32 r2,
            uint32 r3,
            uint32 r4,
            uint32 r5,
            uint32 r6
        ) = RoyaltyDBC._royaltyValDecoder(CollaboratorStruct.royaltyVal);
        if (_tokenState == 1) _selectedSlot = r1;
        else if (_tokenState == 2) _selectedSlot = r2;
        else if (_tokenState == 3) _selectedSlot = r3;
        else if (_tokenState == 4) _selectedSlot = r4;
        else if (_tokenState == 5) _selectedSlot = r5;
        else _selectedSlot = r6;

        if (_selectedSlot == 0) return _grossWei;

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
    }*/

    /**
     * @notice Partitions gross revenue into collaborator reserve.
     * @dev Accesses Collaborator struct and debits earnings based on relevant royalty split
     *      Function Selector:
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _grossWei Total available ETH share.
     */
    function _allocateSCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei,
        uint256 _bitmap
    ) internal returns (uint256 _netWei) {
        if (_grossWei == 0) return 0;

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        SCollaboratorStructStorage.SCollaborator
            storage SCollaboratorStruct = SCollaboratorStructStorage
                .sCollaboratorStructStorage();

        //CollaboratorMapStruct.s_sCollaborators[_hashId];

        // Needs to be altered to access s_collaborators
        //uint256 _bitmap = CollaboratorMapStruct.s_royalties[_hashId];
        // *** NTS: Specific "page" is to be determined relative to numToken being queried.
        // That can probably be done in a simple sub-function (I think we have to do something similar elsewhere already)

        //uint8 _tokenState = Binary3BitDBC._encode3BitState(_hashId, _numToken);
        uint8 _tokenState = Binary3BitDBC._decode3BitState(_bitmap, _numToken);

        if (SCollaboratorStruct.numCollaborator == 0 || _tokenState == 0) {
            // Collaborators disabled for numToken
            return _grossWei;
        }

        uint32 _selectedSlot;

        {
            (
                ,
                uint32 r1,
                uint32 r2,
                uint32 r3,
                uint32 r4,
                uint32 r5,
                uint32 r6
            ) = RoyaltyDBC._royaltyValDecoder(SCollaboratorStruct.royaltyVal);
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

        _netWei = _grossWei - _collaboratorReserveWei;
        return _netWei;
    }

    // THIS FUNCTION COULD AND SHOULD BE MADE MUCH BETTER IMO
    /*
     * @notice Partitions gross revenue into collaborator reserve.
     * @dev Accesses Collaborator struct and debits earnings based on relevant royalty split
     *      Function Selector: 0x784c9669
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _grossWei Total available ETH share.
     */
    /*function _allocateCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei
    ) internal returns (uint256) {
        if (_grossWei == 0) return 0;

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        CollaboratorStructStorage.Collaborator
            storage CollaboratorStruct = CollaboratorStructStorage
                .collaboratorStructStorage();

        CollaboratorMapStruct.s_collaborators[_hashId];

        // Needs to be altered to access s_collaborators
        //uint256 _bitmap = CollaboratorMapStruct.s_royalties[_hashId];
        // *** NTS: Specific "page" is to be determined relative to numToken being queried.
        // That can probably be done in a simple sub-function (I think we have to do something similar elsewhere already)
        uint256[] storage _bitmap = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .royaltyMap;

        Binary3BitDBC._get3BitMapPage(_bitmap, _numToken);

        //uint8 _tokenState = Binary3BitDBC._encode3BitState(_hashId, _numToken);
        uint8 _tokenState = Binary3BitDBC._decode3BitState(_bitmap, _numToken);

        if (CollaboratorStruct.numCollaborator == 0 || _tokenState == 0) {
            // Collaborators disabled for numToken
            return _grossWei;
        }

        uint32 _selectedSlot;

        (
            ,
            uint32 r1,
            uint32 r2,
            uint32 r3,
            uint32 r4,
            uint32 r5,
            uint32 r6
        ) = RoyaltyDBC._royaltyValDecoder(CollaboratorStruct.royaltyVal);
        if (_tokenState == 1) _selectedSlot = r1;
        else if (_tokenState == 2) _selectedSlot = r2;
        else if (_tokenState == 3) _selectedSlot = r3;
        else if (_tokenState == 4) _selectedSlot = r4;
        else if (_tokenState == 5) _selectedSlot = r5;
        else _selectedSlot = r6;

        if (_selectedSlot == 0) return _grossWei;

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
    }*/

    // THIS FUNCTION COULD AND SHOULD BE MADE MUCH BETTER IMO
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

        CollaboratorStructStorage.Collaborator
            storage CollaboratorStruct = CollaboratorStructStorage
                .collaboratorStructStorage();

        //CollaboratorMapStruct.s_collaborators[_hashId];

        /*uint256[] storage _bitmap = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .royaltyMap;

        Binary3BitDBC._get3BitMapPage(_bitmap, _numToken);*/

        //uint8 _tokenState = Binary3BitDBC._encode3BitState(_hashId, _numToken);
        uint8 _tokenState = Binary3BitDBC._decode3BitState(_bitmap, _numToken);

        if (CollaboratorStruct.numCollaborator == 0 || _tokenState == 0) {
            // Collaborators disabled for numToken
            return _grossWei;
        }

        uint32 _selectedSlot;

        {
            (
                ,
                uint32 r1,
                uint32 r2,
                uint32 r3,
                uint32 r4,
                uint32 r5,
                uint32 r6
            ) = RoyaltyDBC._royaltyValDecoder(CollaboratorStruct.royaltyVal);
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

    function _collaboratorReserveRouter(
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _grossWei
    ) internal returns (uint256) {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint256 _sBitmap = CollaboratorMapStruct
            .s_sCollaborators[_hashId]
            .royaltyMap;

        if (_sBitmap != 0) {
            // logic
            return
                _allocateSCollaboratorReserve(
                    _hashId,
                    _numToken,
                    _grossWei,
                    _sBitmap
                );
        }
        uint256[] storage _cBitmap = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .royaltyMap; // _cBitmap[0] could be mildly problematic, should look into
        if (_cBitmap.length > 0 && _cBitmap[0] != 0) {
            // logic
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
