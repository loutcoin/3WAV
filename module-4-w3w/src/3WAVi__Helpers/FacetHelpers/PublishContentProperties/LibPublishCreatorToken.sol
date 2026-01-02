// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    CreatorTokenStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {
    CreatorTokenMapStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";

library LibPublishCreatorToken {
    error PublishCreatorToken__InputIssue();

    /**
     * @notice Publishes data within the CreatorTokenMap struct during publication of a Content Token.
     * @dev Writes and stores CreatorToken data on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     */
    function _publishCreatorToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken
    ) internal {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();

        uint256 _contentId = ++CreatorTokenMapStruct.s_ownershipIndex[
            _creatorId
        ];

        CreatorTokenMapStruct.s_publishedTokenData[
            _hashId
        ] = CreatorTokenStorage.CreatorToken({
            creatorId: _creatorId,
            contentId: _contentId,
            hashId: _hashId
        });

        CreatorTokenMapStruct.s_ownershipMap[_creatorId][_contentId] = _hashId;
        CreatorTokenMapStruct.s_ownershipToken[_creatorId][
            _contentId
        ] = _numToken;
    }
}
