# Web3Wav

## Overview
Web3Wav is an innovative blockchain based platform and service, looking to revolutionize the publication, distribution, sale and ownership of audio-based digital media, forever.
Through an interconnected series of advanced cross-communicating smart contracts, Web3Wav aims to create an automated, streamlined, simplified, efficient, and secure, user-friendly experience, accessible even to those possessing miniscule Web3 ‘technical know-how’ . 


## Mission Statement
We seek to empower the artist and creator. Long gone are the days of unchallenged exploitative dominance mega-corporations, streaming giants, and label executives exert upon the creative. With Web3Wav, ownership of digital audio-based media firmly returns to where it always belonged: the creator and the community.

## Objectives
- **Crypto Simplified**: We believe Web3 has yet to reach critical mass. Through our integrated user-friendly interface, automation, and simplified design philosophy, we're building an unparalleled foundation of accessibility to reach this event horizon.
- **Personalized Second to None**: Understanding that each artist's personal goals vary greatly, Web3Wav is designed to be 'one size fits all'. Engineered with maximum modularity, it is entirely open-ended in design to accommodate any artist's individualistic needs.

## Features

### Dynamic Supply Management
Web3Wav includes a dynamic supply management system that allows artists to control the release and distribution of their content more effectively. Features include:
- **Fixed Supply**: No additional autonomous release. Manual distribution however, is available at any time.
- **Timed Release**: Releases additional supply at specific intervals.
- **Pre-Release**: Option for early purchase period of unreleased content.

### Automated Payment Distribution
Web3Wav ensures transparent and efficient distribution of payments to artists, collaborators, and the platform. This feature includes:
- **Collaborator Splits**: Automatically distributes earnings based on predefined splits.
- **Withdrawal Functions**: Allows artists to withdraw their earnings securely.

### Pricing and Sales
Web3Wav offers flexible pricing and sales options:
- **Individual Sale**: Artists can sell individual songs or entire collections.
- **Dynamic Pricing**: Supports different price tiers (accessible, standard, designer).
- **Resale Functionality**: Allows users to resell purchased content securely within a SINGLE transaction.

### Artist and Fan Engagement
Web3Wav promotes engagement between artists and fans through various features:
- **Artist Reserve**: Artists can reserve a portion of their content for personal distribution.
- **Fan Rewards**: Additional reserves for rewarding loyal fans.

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

### Future Plans
- **Mainnet Deployment**: After thorough testing on the Polygon zkEVM testnet, Web3Wav will be deployed on the Polygon zkEVM mainnet.
- **Additional Features**: Continuous improvement and addition of new features based on user feedback and market trends.
- **Proxy Pattern Refactor**: Refactoring the project into an upgradable, entirely flexible proxy pattern solution, potentially using the diamond proxy.

## Getting Started

### Prerequisites
- **Foundry Framework**: Ensure you have Foundry installed.
- **WSL Ubuntu**: Set up WSL Ubuntu for a Linux-like environment.
- **MetaMask Wallet**: Install MetaMask for interacting with the DApp. Future plans include offering optional proprietary wallet solutions and support for Lout Coin (LOUT).
