# 3Wav

## Overview
3Wav is a blockchain-based service built to revolutionize the tokenization of digital content. Through an interconnected series of upgradable smart contracts, 3Wav enables the customization, publication, distribution, and sale of "Content Tokens."

## Sepolia Deployment
This system is fully deployed and verified on the Sepolia testnet. All interactions route through the diamond proxy:
- **WavDiamond (Diamond Proxy)** `0x3F0602E724eAe035a3BaC1FE3853Bcdb3B608aF7`
- Complete publish -> purchase -> ownership workflows have been executed successfully on-chain.

## What's New
v0.1.1 - Pending
Patch enhancing data validation of publication properties. Will include an additional test file verifying quality implementation.

## Content Tokens

### SContentToken 
Customizable tokenized asset sold as singular entity. This Content Token type does not allow for separate sale of specified numToken indexes and only includes collection-specific properties.

### CContentToken
Customizable collectively sold tokenized asset with independent token indexes sold separately. This Content type shares all the properties of a SContentToken, plus additional properties, to support separate-sale mechanics (multiple price tiers, supply tiers, etc.).

### Variants
Unique derivative of a base Content Token. Variants may be published alongside the base Content or later in a separate publish context. Variants inherit the same structural properties as their base type (SContentToken, CContentToken) alongside a stored association and variant index identifier.

## Features

### Publication
- **Publisher Workflow**
    1. Choose between publication of a 'SContentToken' or 'CContentToken'.
    2. Define properties and supply values (encoded via DBC).
    3. Call the on-chain publication function; inputs are validated, encoded, and stored on-chain.

- **On-chain enforcements**
    - Release windows ('startRelease', 'endRelease', 'preRelease') and 'pausedAt' state are enforced by contract logic.
    - Purchases are only allowed when the current timestamp satisfies release rules.

### Sale Types
- **WavSale (single, batch)**
    Standard sale method used when 'startRelease' is active. Purchases are valued in USD (stored) and paid with ETH using Chainlink ETH/USD feed conversion. Profits are split automatically.
    
- **PreReleaseSale (single, batch)**
    This sale type utilizes the allocated PreRelease supply during an active pre-release window. PreRelease ends when 'startRelease' begins or when the allocated pre-release supply is fully exhausted.

- **WavExchange (single, batch)**
    Peer-to-peer trading functionality intended to integrate with off-chain marketplace UI. Off-chain USD listings are signed and verified on-chain (ECDSA). When a buyer accepts a listing ownership transfers and ETH is distributed (seller, service wallet, publisher). A front-end is required to fully realize the UX and off-chain listing lifecycle. 

- **ReserveExchange (single, batch)**
    Publisher-driven free Content Token transfers from defined 'WavReserve' allocation (ex. event giveaways). Not payable. 

### Gas & Storage Optimizations (DBC)
- **DBC (Dynamic Bit Compaction)**: Custom encoding scheme that packs multiple numeric sub-properties into single EVM storage words (ex. uint112, uint224) to minimize storage slots and gas consumption
- Encoded values are decoded at runtime for logic and re-encoded and updated.
- Example result: CContentToken stores a combined total of 25 sub-properties in **3 EVM storage slots** using compact encodings.

## Field Summaries

### Content Token: Collection Properties
- **numToken**
    Total number of token indexes in a collection. 'numToken[0]' references the entire collection.
- **priceUsdVal**
    10-digit integer representing the USD price of a collection. Can represent a maximum value of $9,999,999.99.
- **supplyVal**
    33-digit encoded integer containing 'totalSupply', 'initialSupply', 'wavReserve', and 'preSupply'.
- **releaseVal**
    19-digit encoded integer containing 'startRelease', 'endRelease', 'preRelease', and 'pausedAt'.

### Content Token: Separate-Sale Properties
- **sPriceUsdVal**
    30-digit encoded integer containing 'standardPriceVal', 'accessiblePriceVal', 'exclusivePriceVal', and 'zeroVal' separate-sale USD price values.
- **sSupplyVal**
    63-digit encoded integer containing three 10-digit separate-sale totalSupply and initialSupply values, as well as a 'zeroVal' property.
- **sReserveVal**
    39-digit encoded integer containing three 6-digit separate-sale wavReserve and preRelease allocation values, as well as a 'zeroVal' property.

### Creator Token
- **creatorId**
    Address of a publisher stored in relation to a Content Token.
- **contentId**
    Numerical index that is incremented alongside ownership and publications.
- **hashId**
    Identifier of a Content Token generated from the keccak256 hash of a combination of unique property data.

## Architecture & System Design

### Modular & Upgradable Design
- **Diamond Proxy Pattern (EIP-2535)** using **Diamond Storage variation**
-   Enables a granular, upgradable system where facets can be added, replaced, or removed without redeploying a monolithic contract.
-   Storage is organized across several storage libraries rather than one app storage struct to keep storage organized and maintainable.

### Integrations
- **Chainlink AggregatorV3Interface**
    ETH:USD price feed for USD-denominated values paid in Ethereum.
- **OpenZeppelin ECDSA**
    Signature verification for off-chain signed listings providing an additional layer of security.

## Repository Structure

### /lib
External dependencies managed by Foundry.
- **chainlink-brownie-contracts** - used for AggregatorV3Interface
- **forge-std** - Foundry standard library
- **openzeppelin-contracts** - used for ECDSA utilities

### /script
Deployment scripts for system facets and the full Diamond
- **Diamond__ProxyFacets/** - singular deploy scripts for proxy facet components
- **Publish/** - singular deploy scripts related to publication functionality
- **Sale/** - singular deploy scripts related to sale functionality
- **System/** - singular deploy scripts for system facets
- **MasterDeployScript.s.sol** - Primary deployment script for full system deployment

### /src
Core smart contract source code
- **3WAVi__Helpers/** - internal logic only helper libraries
    - **DBC/** - encode/decode helpers
    - **FacetHelpers/** - library helper logic for facets
        - **PublishContentProperties/** - library logic handling the publication of content property data
        - **SupplyHelpers/** - supply helper logic for facets
            - **DebitSupply/** - handles supply deductions during sale and exchange processes
            - **PublishSupply/** - handles the writing of supply data during the publication process
            - **ValidateSupply/** - handles supply and sale-related validation processes
    - **ReturnMapping/** - library storage getter logic
- **3WAVi__ORIGINS/** - the first generation of 3Wav facet implementation
    - **Publish/** - content publication facets
    - **Sale/** - facets related to the sale of content
        - **State/** - facets related to the modification of content sale states
- **Diamond__Libraries/** - diamond implementation libraries
- **Diamond__ProxyFacets/** - diamond implementation facets
- **Diamond__Storage/** - diamond storage pattern storage containers
    - **ActiveAddresses/** - storage of active recognized addresses
    - **ContentToken/** - content-specific definitions and mapping storage
        - **Optionals/** - optional content-specific functionality storage
        - **SaleTemporaries/** - structs defined temporarily in memory that are passed into functions to reduce stack load
    - **CreatorToken/** - creator token definitions and mapping storage
    - **ECDSA/** - persistent storage for ECDSA-related data
- **Interfaces/** diamond implementation interfaces

### /test
Foundry test suite
- **Mock/** - mock contracts
- **Sale/** - tests for publication, sale flows, ownership of sales, and expected system behavior
    - **State/** - tests and assertions related to a wide-range of specialized sale states
- **CollaboratorAssertions.t.sol** - collaborator-related tests

## Future Plans
- **Front-End UI** 
    Integrate a front-end UI to fully realize 'WavExchange' and create a user-friendly self-encompassing ecosystem.
- **Collaborator & WavReserve Expansions**
    Build upon the collaborator royalty system, and create sub-reserve functionality for WavReserve.
- **Continued Extensive Testing**
    A further exhaustive test suite including in-depth integration and invariant testing.

## About The Author
- **Solo-Effort**
    Every line of code in this repository was written by Matthew Joseph Lout II. This project is the result of over a year of focused development and four years of Solidity experience.
- **Intention**
    This project has been built to address real market utility. It reflects a genuine passion and long-term commitment. Furthermore, it demonstrates an ability to conceptualize and creatively apply blockchain knowledge to build advanced smart contract systems.