// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {WavDiamond} from "../../src/3WAVi__ORIGINS/WavDiamond.sol";
import {
    DiamondCutFacet
} from "../../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {LibDiamond} from "../../src/Diamond__Libraries/LibDiamond.sol";
import {
    PublishCContentToken
} from "../../src/3WAVi__ORIGINS/Publish/PublishCContentToken.sol";

import {
    PublishCVariant
} from "../../src/3WAVi__ORIGINS/Publish/PublishCVariant.sol";

import {
    PublishSContentToken
} from "../../src/3WAVi__ORIGINS/Publish/PublishSContentToken.sol";

import {
    PublishSVariant
} from "../../src/3WAVi__ORIGINS/Publish/PublishSVariant.sol";

import {WavExchange} from "../../src/3WAVi__ORIGINS/Sale/WavExchange.sol";

import {
    CreatorTokenStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CContentTokenStorage
} from "../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {WavAccess} from "../../src/3WAVi__ORIGINS/WavAccess.sol";

import {WavSale} from "../../src/3WAVi__ORIGINS/Sale/WavSale.sol";

import {
    WavSaleToken
} from "../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

import {
    WavResaleToken
} from "../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavResaleToken.sol";

import {WavFortress} from "../../src/3WAVi__ORIGINS/WavFortress.sol";

import {
    CollaboratorStructStorage
} from "../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {ReturnHashId} from "../../src/3WAVi__Helpers/ReturnHashId.sol";

import {MockV3Aggregator} from "../../test/Mock/MockV3Aggregator.t.sol";

import {TestPriceFeedSetter} from "../../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../../src/Interfaces/IDiamondCut.sol";

import {
    MessageHashUtils
} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

// 0x27D6c944a3855CBe56612cE786fe5693173DF375

contract WavExchangeToken is Test {
    uint112 constant EX_CSUPPLY_01 = 100000099990000000999100000000000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_SPRICE_USD_01 = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD_01 = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY_01 =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE_01 = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE_01 = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp // is returning 7 digit integer,

    uint256 constant NONCE = 0; // Should really update this proper ****
    uint96 constant EX_PURCHASE_STAMP_01 = 4900570000000000000;

    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentToken public publishCContentToken;
    PublishCVariant public publishCVariant;
    PublishSContentToken public publishSContentToken;
    PublishSVariant public publishSVariant;
    WavExchange public wavExchange;
    WavSale public wavSale;
    WavAccess public wavAccess;
    WavFortress public wavFortress;
    TestPriceFeedSetter public priceSetterFacet;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
    uint256 public ownerKey =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    address public buyer_01 =
        address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
    address public buyer_02 =
        address(0x14dC79964da2C08b23698B3D3cc7Ca32193d9955);

    uint96 constant EX_RESERVE_STAMP = 1764205200;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentToken = new PublishCContentToken();
        publishCVariant = new PublishCVariant();
        publishSContentToken = new PublishSContentToken();
        publishSVariant = new PublishSVariant();
        wavSale = new WavSale();
        wavExchange = new WavExchange();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        wavAccess = new WavAccess();
        wavFortress = new WavFortress();
        priceSetterFacet = new TestPriceFeedSetter();
        MockV3Aggregator _mockAggregator = new MockV3Aggregator(
            8,
            int256(3000 * 10 ** 8)
        );

        // Deploy
        wavDiamond = new WavDiamond(owner, address(diamondCutFacet));

        // Build the cut array (which facet selectors to include)
        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](10);

        // Publish facet selectors
        bytes4[] memory _publishCCTSelectors = new bytes4[](1);
        _publishCCTSelectors[0] = PublishCContentToken
            .publishCContentToken
            .selector;

        //_publishSelectors[1] = PublishCContentToken.getPublishedInfo.selector;
        _cut[0] = LibDiamond.FacetCut({
            facetAddress: address(publishCContentToken),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCCTSelectors
        });

        bytes4[] memory _publishCVSelectors = new bytes4[](1);
        _publishCVSelectors[0] = PublishCVariant.publishCVariant.selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishCVariant),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCVSelectors
        });

        bytes4[] memory _publishSCTSelectors = new bytes4[](1);
        _publishSCTSelectors[0] = PublishSContentToken
            .publishSContentToken
            .selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentToken),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTSelectors
        });

        bytes4[] memory _publishSVSelectors = new bytes4[](1);
        _publishSVSelectors[0] = PublishSVariant.publishSVariant.selector;

        _cut[3] = LibDiamond.FacetCut({
            facetAddress: address(publishSVariant),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSVSelectors
        });

        bytes4[] memory _loupeSelectors = new bytes4[](3);
        _loupeSelectors[0] = DiamondLoupeFacet.facets.selector;
        _loupeSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        _loupeSelectors[2] = DiamondLoupeFacet.facetAddresses.selector;

        _cut[4] = LibDiamond.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _loupeSelectors
        });

        bytes4[] memory _setterSelectors = new bytes4[](1);
        _setterSelectors[0] = TestPriceFeedSetter.setPriceFeed.selector;

        _cut[5] = LibDiamond.FacetCut({
            facetAddress: address(priceSetterFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _setterSelectors
        });

        bytes4[] memory _wavExchangeSelectors = new bytes4[](2);
        _wavExchangeSelectors[0] = WavExchange.wavResaleSingle.selector;
        _wavExchangeSelectors[1] = WavExchange.wavExchange.selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(wavExchange),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavExchangeSelectors
        });

        bytes4[] memory _wavSaleSelectors = new bytes4[](2);
        _wavSaleSelectors[0] = WavSale.wavSaleSingle.selector;
        _wavSaleSelectors[1] = WavSale.wavAccess.selector;

        _cut[7] = LibDiamond.FacetCut({
            facetAddress: address(wavSale),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavSaleSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](5);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[2] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[3] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[4] = WavAccess.removeApprovedAddr.selector;

        _cut[8] = LibDiamond.FacetCut({
            facetAddress: address(wavAccess),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavAccessSelectors
        });

        bytes4[] memory _wavFortressSelectors = new bytes4[](1);
        _wavFortressSelectors[0] = WavFortress.getCurrentNonce.selector;

        _cut[9] = LibDiamond.FacetCut({
            facetAddress: address(wavFortress),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavFortressSelectors
        });

        vm.prank(owner);
        IDiamondCut(address(wavDiamond)).diamondCut(_cut, address(0), "");

        vm.prank(owner);
        TestPriceFeedSetter(address(wavDiamond)).setPriceFeed(
            address(_mockAggregator)
        );

        vm.prank(owner);
        WavAccess(address(wavDiamond)).addOwnerAddr(owner);
    }
    // forge test --match-test testWavExchangeCContentTokenHappyPath -vvvv

    function testWavExchangeCContentTokenHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
                    numToken: uint16(8),
                    cSupplyVal: EX_CSUPPLY_01,
                    sPriceUsdVal: EX_SPRICE_USD_01,
                    cPriceUsdVal: EX_CPRICE_USD_01,
                    sSupplyVal: EX_SSUPPLY_01,
                    sReserveVal: EX_SRESERVE_01,
                    cReleaseVal: EX_CRELEASE_01
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCContentToken(address(wavDiamond)).publishCContentToken(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = EX_CPRICE_USD_01;
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = 1 ether; //(usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 100 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }

        {
            WavResaleToken.WavResale memory _wavResale = WavResaleToken
                .WavResale({
                    seller: buyer_01,
                    creatorId: publisher,
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    numToken: uint16(0),
                    purchaseQuantity: uint112(1),
                    priceInEth: 1 ether
                });

            uint256 _nonce = wavFortress.getCurrentNonce(owner);

            bytes32 messageHash = keccak256(
                abi.encodePacked(_nonce, owner, _wavResale.priceInEth)
            );

            bytes32 ethSignedMessageHash = MessageHashUtils
                .toEthSignedMessageHash(messageHash);

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(
                ownerKey,
                ethSignedMessageHash
            );
            bytes memory signature65 = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchange(address(wavDiamond)).wavResaleSingle{value: 1 ether}(
                buyer_02,
                _wavResale,
                _nonce,
                signature65
            );
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer_02,
            0
        );
    }

    // forge test --match-test testWavExchangeCVariantHappyPath -vvvv

    function testWavExchangeCVariantHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
                    numToken: uint16(8),
                    cSupplyVal: EX_CSUPPLY_01,
                    sPriceUsdVal: EX_SPRICE_USD_01,
                    cPriceUsdVal: EX_CPRICE_USD_01,
                    sSupplyVal: EX_SSUPPLY_01,
                    sReserveVal: EX_SRESERVE_01,
                    cReleaseVal: EX_CRELEASE_01
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCContentToken(address(wavDiamond)).publishCContentToken(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
                    numToken: uint16(8),
                    cSupplyVal: EX_CSUPPLY_01,
                    sPriceUsdVal: EX_SPRICE_USD_01,
                    cPriceUsdVal: EX_CPRICE_USD_01,
                    sSupplyVal: EX_SSUPPLY_01,
                    sReserveVal: EX_SRESERVE_01,
                    cReleaseVal: EX_CRELEASE_01
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCVariant(address(wavDiamond)).publishCVariant(
                _creatorTokenVariant,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = EX_CPRICE_USD_01;
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = 1 ether; //(usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);

            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }

        {
            WavResaleToken.WavResale memory _wavResale = WavResaleToken
                .WavResale({
                    seller: buyer_01,
                    creatorId: publisher,
                    hashId: bytes32(
                        0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                    ),
                    numToken: uint16(0),
                    purchaseQuantity: uint112(1),
                    priceInEth: 1 ether
                });

            uint256 _nonce = wavFortress.getCurrentNonce(owner);

            bytes32 messageHash = keccak256(
                abi.encodePacked(_nonce, owner, _wavResale.priceInEth)
            );

            bytes32 ethSignedMessageHash = MessageHashUtils
                .toEthSignedMessageHash(messageHash);

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(
                ownerKey,
                ethSignedMessageHash
            );
            bytes memory signature65 = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchange(address(wavDiamond)).wavResaleSingle{value: 1 ether}(
                buyer_02,
                _wavResale,
                _nonce,
                signature65
            );
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer_02,
            0
        );
    }

    // forge test --match-test testWavExchangeSContentTokenHappyPath -vvvv

    function testWavExchangeSContentTokenHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = EX_CPRICE_USD_01;
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = 1 ether; //(usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 100 ether);

            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }
        {
            WavResaleToken.WavResale memory _wavResale = WavResaleToken
                .WavResale({
                    seller: buyer_01,
                    creatorId: publisher,
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    numToken: uint16(0),
                    purchaseQuantity: uint112(1),
                    priceInEth: 1 ether
                });

            uint256 _nonce = wavFortress.getCurrentNonce(owner);

            bytes32 messageHash = keccak256(
                abi.encodePacked(_nonce, owner, _wavResale.priceInEth)
            );

            bytes32 ethSignedMessageHash = MessageHashUtils
                .toEthSignedMessageHash(messageHash);

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(
                ownerKey,
                ethSignedMessageHash
            );
            bytes memory signature65 = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchange(address(wavDiamond)).wavResaleSingle{value: 1 ether}(
                buyer_02,
                _wavResale,
                _nonce,
                signature65
            );
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer_02,
            0
        );
    }

    // forge test --match-test testWavExchangeSVariantHappyPath -vvvv
    function testWavExchangeSVariantHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSVariant(address(wavDiamond)).publishSVariant(
                _creatorTokenVariant,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = EX_CPRICE_USD_01;
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = 1 ether; //(usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }
        {
            WavResaleToken.WavResale memory _wavResale = WavResaleToken
                .WavResale({
                    seller: buyer_01,
                    creatorId: publisher,
                    hashId: bytes32(
                        0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                    ),
                    numToken: uint16(0),
                    purchaseQuantity: uint112(1),
                    priceInEth: 1 ether
                });

            uint256 _nonce = wavFortress.getCurrentNonce(owner);

            bytes32 messageHash = keccak256(
                abi.encodePacked(_nonce, owner, _wavResale.priceInEth)
            );

            bytes32 ethSignedMessageHash = MessageHashUtils
                .toEthSignedMessageHash(messageHash);

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(
                ownerKey,
                ethSignedMessageHash
            );
            bytes memory signature65 = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchange(address(wavDiamond)).wavResaleSingle{value: 1 ether}(
                buyer_02,
                _wavResale,
                _nonce,
                signature65
            );
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer_02,
            0
        );
    }
}
