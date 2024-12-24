# 3Wav

## Overview
3Wav is an innovative blockchain-based platform and service, looking to revolutionize the publication, distribution, sale and ownership of audio-based digital media, forever.
Through an interconnected series of advanced cross-communicating smart contracts, integrated on a formidable Kotlin base, 3Wav aims to create an automated, streamlined, simplified, highly-accessible, user-friendly experience.


## Mission Statement
We seek to empower the artist and creator. Long gone are the days of mega-corporations, streaming giants, and label executives unfairly exploiting the creative. With 3Wav, ownership of digital audio-based media firmly returns to where it always belonged: the creator and community.
 
## Objectives
- **Crypto Simplified**
- **Universal Distribution Solution**

## Features

### Dynamic Supply Management
We empower the creator with content tokenization, full ownership, and customization of ditributed release.
3Wav content management options include:
- **Fixed Supply**: Non-autonomous release. Manual distribution remains available at any time.
- **Timed Distribution**: Increases content-token supply autonomously at artist-defined intervals.
- **Limited Release** Content-token sale with defined start and end period. 
- **Pre-Release**: Option of limited-time pre-sale possibly bundled with bonus content.
- **WavReserve**: Special content reserve offering alternative distribution possiblities.


### Automated Payment Distribution
Web3Wav ensures transparent automated distribution of payments to artists, collaborators, and the service itself. 
This feature includes:
- **Collaborator Splits**: Automatically distributes earnings based on predefined splits.
- **Withdrawal Functions**: Allows artists to withdraw their earnings securely.

### Pricing and Sales
Web3Wav offers flexible pricing and sales options:
- **Individual Sale**: Artists can sell tracks selectively or as singular collections.
- **Dynamic Pricing**: Supports different price tiers (accessible, standard, designer).
- **Rarity Sale**: Obtainment of special editions or bonus content through pre-defined artist odds.
- **Resale Functionality**: Allows users to resell purchased content within a SINGLE on-chain transaction.

## Technical Overview

### Contracts

**WavToken**
Handles publication, customization, and distribution of audio-based digital content. It acts as an open-ended template, allowing for NFT-style variations, dynamic supply management, pre-release options, and more.

**WavStore**
Facilitates the sale and resale of WavTokens. It handles purchase transactions, updates earnings, and ensures secure access to purchased content.

**WavAccess**
Manages ownership and access rights. It registers artist accounts, approves artists, and tracks ownership of music tokens.

**WavFeed**
Provides price conversion and transfer helper functions. It integrates with Chainlink's price feed to convert ETH to USD and vice versa.

**WavFortress**
Ensures security through ECDSA functionality, protecting transactions and user data.

**WavRoot**
Serves as the foundational contract that other contracts inherit from. It includes base data structures and mappings used across the platform. Upon refactor, will likely serve as the system's proxy.

**WavDBC**
WIP: Unique one of a kind mathematical blockchain algorithm (incomplete). Created by Matthew Joseph Lout II, coined 'DBC' (Dynamic Bit Compaction).
-   Takes user input, interprets applicable data, preforms dynamic dispatch to appropriate function calculator, applies unique bit identifier to each value, 
compacts all data into lengthy unsigned interger, before returning value.
-   Assigns creator-defined values (rarity percentages, sale-states) to content tokens of the creator's selection. 
-   These values are associated to the bit identifiers attributed to the unsigned interger. A single numerical bitmap is created, ordered sequentially,     
following the defined content-token track-list. 
-   This can represent various content properties and sale-states, all compacted into two numerical values within a single instance.


### Future Plans
- **Proxy Pattern Refactor**: Before initial testnet deployment the project will be refactored within the upgradable Diamond Proxy Pattern.
- **Additional Features**: Continuous improvement and addition of new features based on user feedback and market trends.
- **Mainnet Deployment**: After thorough testing on the Polygon zkEVM testnet, Web3Wav will be deployed on the Polygon zkEVM mainnet.

## Getting Started

### Prerequisites
- **Foundry Framework**: Ensure you have Foundry installed.
- **WSL Ubuntu**: Set up WSL Ubuntu for a Linux-like environment.
- **MetaMask Wallet**: Install MetaMask for interacting with the DApp. Future plans include offering optional proprietary wallet solutions and support for Lout Coin (LOUT).
