// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library WavEvents {
    event WavStore__PreSalePausing(
        bytes32 indexed _hashId,
        uint256 indexed _pausedAt
    );

    event WavStore__PreSaleResume(bytes32 indexed _hashId);

    event WavStore__MusicPurchased(
        address indexed buyer,
        bytes32 indexed hashId,
        uint64 indexed purchaseQuantity
    );

    event WavStore__MusicResale(
        address indexed seller,
        address indexed buyer,
        uint256 indexed contentId,
        uint256 priceInEth
    );

    event WavStore__PreReleaseSale(
        address _artistId,
        uint256 _contentId,
        uint256 _priceInEth,
        uint16 _numCollaborator
    );
}
