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

import {WavAccess} from "../../src/3WAVi__ORIGINS/WavAccess.sol";

import {WavSale} from "../../src/3WAVi__ORIGINS/Sale/WavSale.sol";

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

import {
    WavSaleToken
} from "../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

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

contract WavSaleTokenTest is Test {
    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentToken public publishCContentToken;
    PublishCVariant public publishCVariant;
    PublishSContentToken public publishSContentToken;
    PublishSVariant public publishSVariant;
    WavSale public wavSale;
    WavAccess public wavAccess;
    TestPriceFeedSetter public priceSetterFacet;

    //WavZip public wavZip;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    address public buyer = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

    //uint96 internal constant SECOND_TO_HOUR_PRECISION = 3600;

    uint112 constant EX_CSUPPLY = 100000099990000000999100000000000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_SPRICE_USD = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp
    uint96 constant EX_PURCHASE_STAMP = 4900570000000000000;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentToken = new PublishCContentToken();
        publishCVariant = new PublishCVariant();
        publishSContentToken = new PublishSContentToken();
        publishSVariant = new PublishSVariant();
        wavSale = new WavSale();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        wavAccess = new WavAccess();
        priceSetterFacet = new TestPriceFeedSetter();
        MockV3Aggregator _mockAggregator = new MockV3Aggregator(
            8,
            int256(3000 * 10 ** 8)
        );

        // Deploy
        wavDiamond = new WavDiamond(owner, address(diamondCutFacet));

        // Build the cut array (which facet selectors to include)
        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](8);

        // Publish facet selectors
        bytes4[] memory _publishCCTSelectors = new bytes4[](1);
        _publishCCTSelectors[0] = PublishCContentToken
            .publishCContentToken
            .selector;

        //_publishSelectors[1] = PublishCContentToken.getPublishedInfo.selector; //
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

        bytes4[] memory _wavSaleSelectors = new bytes4[](2);
        _wavSaleSelectors[0] = WavSale.wavSaleSingle.selector;
        _wavSaleSelectors[1] = WavSale.wavAccess.selector;

        _cut[6] = LibDiamond.FacetCut({
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

        _cut[7] = LibDiamond.FacetCut({
            facetAddress: address(wavAccess),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavAccessSelectors
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

    function testWavSaleCContentTokenHappyPath() public {
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
                cSupplyVal: EX_CSUPPLY,
                sPriceUsdVal: EX_SPRICE_USD,
                cPriceUsdVal: EX_CPRICE_USD,
                sSupplyVal: EX_SSUPPLY,
                sReserveVal: EX_SRESERVE,
                cReleaseVal: EX_CRELEASE
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
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PURCHASE_STAMP);
        WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
            buyer,
            _wavSale
        );

        (bytes32 _hash, uint16 _num, uint256 _bal) = WavAccess(
            address(wavDiamond)
        ).returnOwnershipIndex(buyer, 0);

        //WavAccess(address(wavDiamond)).returnOwnership(buyer);
        //console.log("returnOwnership length:", _owned.length);
    }

    function testWavSaleCVariantHappyPath() public {
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
                    cSupplyVal: EX_CSUPPLY,
                    sPriceUsdVal: EX_SPRICE_USD,
                    cPriceUsdVal: EX_CPRICE_USD,
                    sSupplyVal: EX_SSUPPLY,
                    sReserveVal: EX_SRESERVE,
                    cReleaseVal: EX_CRELEASE
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
                cSupplyVal: EX_CSUPPLY,
                sPriceUsdVal: EX_SPRICE_USD,
                cPriceUsdVal: EX_CPRICE_USD,
                sSupplyVal: EX_SSUPPLY,
                sReserveVal: EX_SRESERVE,
                cReleaseVal: EX_CRELEASE
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
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        vm.deal(buyer, 10 ether);

        //uint256 initialBalance = buyer.balance;

        vm.prank(owner);
        vm.warp(EX_PURCHASE_STAMP);
        WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
            buyer,
            _wavSale
        );

        (bytes32 _hash, uint16 _num, uint256 _bal) = WavAccess(
            address(wavDiamond)
        ).returnOwnershipIndex(buyer, 0);
    }

    function testWavSaleSContentTokenHappyPath() public {
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
                priceUsdVal: uint32(EX_CPRICE_USD),
                supplyVal: uint112(EX_CSUPPLY),
                releaseVal: uint96(EX_CRELEASE)
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        SCollaboratorStructStorage.SCollaborator
            memory _sCollaborator = SCollaboratorStructStorage.SCollaborator({
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
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PURCHASE_STAMP);
        WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
            buyer,
            _wavSale
        );

        (bytes32 _hash, uint16 _num, uint256 _bal) = WavAccess(
            address(wavDiamond)
        ).returnOwnershipIndex(buyer, 0);
    }

    function testWavSaleSVariantHappyPath() public {
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
                    priceUsdVal: uint32(EX_CPRICE_USD),
                    supplyVal: uint112(EX_CSUPPLY),
                    releaseVal: uint96(EX_CRELEASE)
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
                priceUsdVal: uint32(EX_CPRICE_USD),
                supplyVal: uint112(EX_CSUPPLY),
                releaseVal: uint96(EX_CRELEASE)
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        SCollaboratorStructStorage.SCollaborator
            memory _sCollaborator = SCollaboratorStructStorage.SCollaborator({
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
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PURCHASE_STAMP);
        WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
            buyer,
            _wavSale
        );

        (bytes32 _hash, uint16 _num, uint256 _bal) = WavAccess(
            address(wavDiamond)
        ).returnOwnershipIndex(buyer, 0);
    }

    // EVERYTHING WORKS! HOWEVER _contentId WAS returning '0' then I updated it to return it from storage and it returned '2' this time
    // I believe it is to do with this line:
    /* uint256 _contentId = ++CreatorTokenMapStruct.s_ownershipIndex[
            _creatorId
        ];
        from LibPublishCreatorToken. It can be modified slightly to resolve the issue but other than that,
        everything seems to be working under ideal conditions :)
    */

    //uint256 remainingBalance = buyer.balance;

    /*assertTrue(
            initialBalance - remainingBalance >= expectedWei,
            "Buyer did not pay amount expected"
        );*/

    /*function testPrintHashId() public {
        uint256 contentId = 0;
        uint16 variantId = 0;
        bytes32 hashId = keccak256(abi.encode(publisher, contentId, variantId));
        console.logBytes32(hashId);
        // HashId: 0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
    }*/

    /*function testPrintHashId() public {
        uint256 contentId = 1;
        uint16 variantId = 1;
        bytes32 hashId = keccak256(abi.encode(publisher, contentId, variantId));
        console.logBytes32(hashId);
        // HashId: 0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
    }*/

    /*function testPrintHashId() public {
        uint256 contentId = 1;
        uint16 variantId = 0;
        bytes32 hashId = keccak256(abi.encode(publisher, contentId, variantId));
        console.logBytes32(hashId);
    }*/

    function testPrintHashId() public view {
        uint256 contentId = 1;
        uint16 variantId = 1;
        bytes32 hashId = keccak256(abi.encode(publisher, contentId, variantId));
        console.logBytes32(hashId);
    }

    /*function testPrintHourStamp() public {
        uint96 _timeStamp = uint96(block.timestamp);
        _hourStamp = _timeStamp / SECOND_TO_HOUR_PRECISION;

        console.logUint(uint256(_hourStamp));

        //return _hourStamp;
    }*/
}
