// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {WavDiamond} from "../src/3WAVi__ORIGINS/WavDiamond.sol";
import {DiamondCutFacet} from "../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {LibDiamond} from "../src/Diamond__Libraries/LibDiamond.sol";

import {
    PublishCContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCContentTokenBatch.sol";

import {
    PublishCVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCVariantBatch.sol";

import {
    PublishSContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSContentTokenBatch.sol";

import {
    PublishSVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSVariantBatch.sol";

import {
    WavExchangeBatch
} from "../src/3WAVi__ORIGINS/Sale/WavExchangeBatch.sol";

import {
    CreatorTokenStorage
} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CContentTokenStorage
} from "../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {WavAccess} from "../src/3WAVi__ORIGINS/WavAccess.sol";

import {WavSaleBatch} from "../src/3WAVi__ORIGINS/Sale/WavSaleBatch.sol";

import {
    WavSaleToken
} from "../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

import {
    WavResaleToken
} from "../src/Diamond__Storage/ContentToken/SaleTemporaries/WavResaleToken.sol";

import {WavFortress} from "../src/3WAVi__ORIGINS/WavFortress.sol";

import {
    CollaboratorStructStorage
} from "../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {ReturnHashId} from "../src/3WAVi__Helpers/ReturnHashId.sol";

import {MockV3Aggregator} from "../test/Mock/MockV3Aggregator.t.sol";

import {TestPriceFeedSetter} from "../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../src/Interfaces/IDiamondCut.sol";

contract WavExchangeTokenBatch is Test {
    uint112 constant EX_CSUPPLY_01 = 100000099990000000999100000000000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_SPRICE_USD_01 = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD_01 = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY_01 =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE_01 = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE_01 = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp // is returning 7 digit integer,

    uint96 constant EX_RESERVE_STAMP = 1764205200;
    uint96 constant EX_PURCHASE_STAMP_01 = 4900570000000000000;

    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentTokenBatch public publishCContentTokenBatch;
    PublishCVariantBatch public publishCVariantBatch;
    PublishSContentTokenBatch public publishSContentTokenBatch;
    PublishSVariantBatch public publishSVariantBatch;
    WavExchangeBatch public wavExchangeBatch;
    WavSaleBatch public wavSaleBatch;
    WavAccess public wavAccess;
    WavFortress public wavFortress;
    TestPriceFeedSetter public priceSetterFacet;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
    uint256 public ownerKey =
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    address public buyer_01 =
        address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
    address public buyer_02 =
        address(0x14dC79964da2C08b23698B3D3cc7Ca32193d9955);

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentTokenBatch = new PublishCContentTokenBatch();
        publishCVariantBatch = new PublishCVariantBatch();
        publishSContentTokenBatch = new PublishSContentTokenBatch();
        publishSVariantBatch = new PublishSVariantBatch();
        wavSaleBatch = new WavSaleBatch();
        wavExchangeBatch = new WavExchangeBatch();
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
        bytes4[] memory _publishCCTBSelectors = new bytes4[](1);
        _publishCCTBSelectors[0] = PublishCContentTokenBatch
            .publishCContentTokenBatch
            .selector;

        //_publishSelectors[1] = PublishCContentToken.getPublishedInfo.selector;
        _cut[0] = LibDiamond.FacetCut({
            facetAddress: address(publishCContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCCTBSelectors
        });

        bytes4[] memory _publishCVBSelectors = new bytes4[](2);
        _publishCVBSelectors[0] = PublishCVariantBatch
            .publishCVariantBatch
            .selector;
        _publishCVBSelectors[1] = PublishCVariantBatch
            .publishCContentTokenVariantBatch
            .selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishCVariantBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCVBSelectors
        });

        bytes4[] memory _publishSCTBSelectors = new bytes4[](1);
        _publishSCTBSelectors[0] = PublishSContentTokenBatch
            .publishSContentTokenBatch
            .selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTBSelectors
        });

        bytes4[] memory _publishSVBSelectors = new bytes4[](2);
        _publishSVBSelectors[0] = PublishSVariantBatch
            .publishSVariantBatch
            .selector;
        _publishSVBSelectors[1] = PublishSVariantBatch
            .publishSContentTokenVariantBatch
            .selector;

        _cut[3] = LibDiamond.FacetCut({
            facetAddress: address(publishSVariantBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSVBSelectors
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

        bytes4[] memory _wavExchangeBatchSelectors = new bytes4[](2);
        _wavExchangeBatchSelectors[0] = WavExchangeBatch
            .wavResaleBatch
            .selector;
        _wavExchangeBatchSelectors[1] = WavExchangeBatch
            .wavExchangeBatch
            .selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(wavExchangeBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavExchangeBatchSelectors
        });

        bytes4[] memory _wavSaleBatchSelectors = new bytes4[](2);
        _wavSaleBatchSelectors[0] = WavSaleBatch.wavSaleBatch.selector;
        _wavSaleBatchSelectors[1] = WavSaleBatch.wavAccessBatch.selector;

        _cut[7] = LibDiamond.FacetCut({
            facetAddress: address(wavSaleBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavSaleBatchSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](8);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnership2.selector;
        _wavAccessSelectors[2] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[3] = WavAccess.returnOwnershipIndex2.selector;
        _wavAccessSelectors[4] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[5] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[6] = WavAccess.removeApprovedAddr.selector;
        _wavAccessSelectors[7] = WavAccess.returnHourStamp.selector;

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

    // forge test --match-test testWavExchangeCContentTokenBatchHappyPath -vvvv

    function testWavExchangeCContentTokenBatchHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            CContentTokenStorage.CContentToken[]
                memory _cContentToken = new CContentTokenStorage.CContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // was both '1' just temporarily modified
            uint256[] memory _tierPages = new uint256[](2);
            uint256[] memory _pricePages = new uint256[](2);

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _cContentToken[0] = CContentTokenStorage.CContentToken({
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

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _tierPages[0] = uint256(0x058885580);
            _pricePages[0] = uint256(0x5564);

            // cContentToken[1]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _cContentToken[1] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_01,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

            _collaborator[1] = _collaborator[0];

            _tierPages[1] = uint256(0x058885580);
            _pricePages[1] = uint256(0x5564);

            vm.prank(owner);
            PublishCContentTokenBatch(address(wavDiamond))
                .publishCContentTokenBatch(
                    _creatorToken,
                    _cContentToken,
                    _collaborator,
                    _tierPages,
                    _pricePages
                );

            WavSaleToken.WavSale[]
                memory _wavSaleToken = new WavSaleToken.WavSale[](2);

            _wavSaleToken[0] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken[0].hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            _wavSaleToken[1] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken[1].hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            // Feed determination logic goes here

            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: 1 ether}(
                buyer_01,
                _wavSaleToken
            );
        }

        {
            WavResaleToken.WavResale[]
                memory _wavResaleToken = new WavResaleToken.WavResale[](2);

            _wavResaleToken[0] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            _wavResaleToken[1] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            bytes memory _packed;

            for (uint256 i = 0; i < _wavResaleToken.length; ++i) {
                _packed = abi.encodePacked(
                    _packed,
                    _wavResaleToken[i].seller,
                    _wavResaleToken[i].creatorId,
                    _wavResaleToken[i].hashId,
                    _wavResaleToken[i].numToken,
                    _wavResaleToken[i].purchaseQuantity,
                    _wavResaleToken[i].priceInEth
                );
            }

            vm.prank(owner);
            uint256 _nonce = wavFortress.getCurrentNonce(owner);
            _packed = abi.encodePacked(buyer_02, _packed, _nonce);

            bytes32 _messageHash = keccak256(_packed);
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, _messageHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchangeBatch(address(wavDiamond)).wavResaleBatch{
                value: 3 ether
            }(buyer_02, _wavResaleToken, _nonce, signature);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer_02
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }
    // Got to solve the "singular or multi signature pregunta"
    // It's just 'bytes memory signature' but I don't know how building the data would work

    function testWavExchangeCVariantBatchHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            CContentTokenStorage.CContentToken[]
                memory _cContentToken = new CContentTokenStorage.CContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // was both '1' just temporarily modified
            uint256[] memory _tierPages = new uint256[](2);
            uint256[] memory _pricePages = new uint256[](2);

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _cContentToken[0] = CContentTokenStorage.CContentToken({
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

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _tierPages[0] = uint256(0x058885580);
            _pricePages[0] = uint256(0x5564);

            // cContentToken[1]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _cContentToken[1] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_01,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

            _collaborator[1] = _collaborator[0];

            _tierPages[1] = uint256(0x058885580);
            _pricePages[1] = uint256(0x5564);

            vm.prank(owner);
            PublishCContentTokenBatch(address(wavDiamond))
                .publishCContentTokenBatch(
                    _creatorToken,
                    _cContentToken,
                    _collaborator,
                    _tierPages,
                    _pricePages
                );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant[]
                memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                    2
                );
            CContentTokenStorage.CContentToken[]
                memory _cContentToken = new CContentTokenStorage.CContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            uint256[] memory _tierPages = new uint256[](2);
            uint256[] memory _pricePages = new uint256[](2);

            _creatorTokenVariant[0] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(2),
                        hashId: bytes32(
                            0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                        )
                    }),
                    baseHashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    variantIndex: uint16(1)
                });

            _cContentToken[0] = CContentTokenStorage.CContentToken({
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

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _tierPages[0] = uint256(0x058885580);
            _pricePages[0] = uint256(0x5564);

            _creatorTokenVariant[1] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(3),
                        hashId: bytes32(
                            0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                        )
                    }),
                    baseHashId: bytes32(
                        0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                    ),
                    variantIndex: uint16(1)
                });

            _cContentToken[1] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_01,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

            _collaborator[1] = _collaborator[0];

            _tierPages[1] = uint256(0x058885580);
            _pricePages[1] = uint256(0x5564);

            vm.prank(owner);
            PublishCVariantBatch(address(wavDiamond)).publishCVariantBatch(
                _creatorTokenVariant,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

            WavSaleToken.WavSale[]
                memory _wavSaleToken = new WavSaleToken.WavSale[](2);
            _wavSaleToken[0] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[0].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            _wavSaleToken[1] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[1].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 _totalWei = 0;

            {
                uint256 feedAnswer = uint256(3000 * 10 ** 8);
                uint256 usdVal = 349; // 3.49$
                uint256 usd8 = usdVal * 1e6;
                uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiZero;

                usdVal = 349;
                usd8 = usdVal * 1e6;
                uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiOne;

                vm.deal(buyer_01, 5 ether);
                vm.prank(owner);
                vm.warp(EX_PURCHASE_STAMP_01);
                WavSaleBatch(address(wavDiamond)).wavSaleBatch{
                    value: _totalWei
                }(buyer_01, _wavSaleToken);
            }
        }
        {
            WavResaleToken.WavResale[]
                memory _wavResaleToken = new WavResaleToken.WavResale[](2);

            _wavResaleToken[0] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            _wavResaleToken[1] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            bytes memory _packed;

            for (uint256 i = 0; i < _wavResaleToken.length; ++i) {
                _packed = abi.encodePacked(
                    _packed,
                    _wavResaleToken[i].seller,
                    _wavResaleToken[i].creatorId,
                    _wavResaleToken[i].hashId,
                    _wavResaleToken[i].numToken,
                    _wavResaleToken[i].purchaseQuantity,
                    _wavResaleToken[i].priceInEth
                );
            }
            vm.prank(owner);
            uint256 _nonce = wavFortress.getCurrentNonce(owner);
            _packed = abi.encodePacked(buyer_02, _packed, _nonce);

            bytes32 _messageHash = keccak256(_packed);
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, _messageHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchangeBatch(address(wavDiamond)).wavResaleBatch{
                value: 3 ether
            }(buyer_02, _wavResaleToken, _nonce, signature);
        }
        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer_02
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    function testWavExchangeSContentTokenBatchHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            // CContentToken[0]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSContentTokenBatch(address(wavDiamond))
                .publishSContentTokenBatch(
                    _creatorToken,
                    _sContentToken,
                    _collaborator
                );

            WavSaleToken.WavSale[]
                memory _wavSaleToken = new WavSaleToken.WavSale[](2);

            _wavSaleToken[0] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken[0].hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            _wavSaleToken[1] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken[1].hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 _totalWei = 0;

            {
                uint256 feedAnswer = uint256(3000 * 10 ** 8);
                uint256 usdVal = 349; // 3.49$
                uint256 usd8 = usdVal * 1e6;
                uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiZero;

                usdVal = 349;
                usd8 = usdVal * 1e6;
                uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiOne;

                vm.deal(buyer_01, 5 ether);
                vm.prank(owner);
                vm.warp(EX_PURCHASE_STAMP_01);
                WavSaleBatch(address(wavDiamond)).wavSaleBatch{
                    value: _totalWei
                }(buyer_01, _wavSaleToken);
            }
        }
        {
            WavResaleToken.WavResale[]
                memory _wavResaleToken = new WavResaleToken.WavResale[](2);

            _wavResaleToken[0] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            _wavResaleToken[1] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            bytes memory _packed;

            for (uint256 i = 0; i < _wavResaleToken.length; ++i) {
                _packed = abi.encodePacked(
                    _packed,
                    _wavResaleToken[i].seller,
                    _wavResaleToken[i].creatorId,
                    _wavResaleToken[i].hashId,
                    _wavResaleToken[i].numToken,
                    _wavResaleToken[i].purchaseQuantity,
                    _wavResaleToken[i].priceInEth
                );
            }
            uint256 _nonce = wavFortress.getCurrentNonce(owner);
            _packed = abi.encodePacked(buyer_02, _packed, _nonce);

            bytes32 _messageHash = keccak256(_packed);
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, _messageHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchangeBatch(address(wavDiamond)).wavResaleBatch{
                value: 3 ether
            }(buyer_02, _wavResaleToken, _nonce, signature);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer_02
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    // forge test --match-test testWavExchangeSVariantBatchHappyPath -vvvv

    function testWavExchangeSVariantBatchHappyPath() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            // CContentToken[0]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSContentTokenBatch(address(wavDiamond))
                .publishSContentTokenBatch(
                    _creatorToken,
                    _sContentToken,
                    _collaborator
                );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant[]
                memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            _creatorTokenVariant[0] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(2),
                        hashId: bytes32(
                            0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                        )
                    }),
                    baseHashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    variantIndex: uint16(1)
                });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _creatorTokenVariant[1] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(3),
                        hashId: bytes32(
                            0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                        )
                    }),
                    baseHashId: bytes32(
                        0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                    ),
                    variantIndex: uint16(1)
                });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
                _creatorTokenVariant,
                _sContentToken,
                _collaborator
            );

            WavSaleToken.WavSale[]
                memory _wavSaleToken = new WavSaleToken.WavSale[](2);

            _wavSaleToken[0] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[0].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            _wavSaleToken[1] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[1].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 _totalWei = 0;

            {
                uint256 feedAnswer = uint256(3000 * 10 ** 8);
                uint256 usdVal = 349; // 3.49$
                uint256 usd8 = usdVal * 1e6;
                uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiZero;

                usdVal = 349;
                usd8 = usdVal * 1e6;
                uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiOne;

                vm.deal(buyer_01, 5 ether);
                vm.prank(owner);
                vm.warp(EX_PURCHASE_STAMP_01);
                WavSaleBatch(address(wavDiamond)).wavSaleBatch{
                    value: _totalWei
                }(buyer_01, _wavSaleToken);
            }
        }
        {
            WavResaleToken.WavResale[]
                memory _wavResaleToken = new WavResaleToken.WavResale[](2);

            _wavResaleToken[0] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            _wavResaleToken[1] = WavResaleToken.WavResale({
                seller: buyer_01,
                creatorId: publisher,
                hashId: bytes32(
                    0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                ),
                numToken: uint16(0),
                purchaseQuantity: uint112(1),
                priceInEth: 1 ether
            });

            bytes memory _packed;

            for (uint256 i = 0; i < _wavResaleToken.length; ++i) {
                _packed = abi.encodePacked(
                    _packed,
                    _wavResaleToken[i].seller,
                    _wavResaleToken[i].creatorId,
                    _wavResaleToken[i].hashId,
                    _wavResaleToken[i].numToken,
                    _wavResaleToken[i].purchaseQuantity,
                    _wavResaleToken[i].priceInEth
                );
            }
            uint256 _nonce = wavFortress.getCurrentNonce(owner);
            _packed = abi.encodePacked(buyer_02, _packed, _nonce);

            bytes32 _messageHash = keccak256(_packed);
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, _messageHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            vm.deal(buyer_02, 5 ether);
            vm.prank(owner);
            vm.warp(EX_RESERVE_STAMP);
            WavExchangeBatch(address(wavDiamond)).wavResaleBatch{
                value: 3 ether
            }(buyer_02, _wavResaleToken, _nonce, signature);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer_02
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    /*
    vm.prank(publisher);
            PublishCVariantBatch(address(wavDiamond)).publishCVariantBatch(
                _creatorTokenVariant,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

    */
}
