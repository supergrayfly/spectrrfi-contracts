# Spectrr Finance Solidity Smart Contracts

Interest-Free Lending and Borrowing Like Decentralised Application.

# Motivation

- Provide an alternative to interest based lending and borrowing DApps
- Buy Bugatti

# Design Choices

- Lending and borrowing with no interest, 
profit is made by selling or buying an asset for a different asset at a value higher than the market
- Lending and borrowing process is offer based. Meaning that users post sale and buy offers, 
which other users can then accept (peer-to-peer, permissionless).
- Contract is not upgradable (no rule changes).
- There is no governace token (not necessary for contract functionning).
- Prices are taken from Chainlink.
- 0.1% fee is taken when offers are accepted 
(paid by buyer in case of sale offer,
paid by seller in case of buy offer).

# Supported Networks

- Mainnet: Fantom Opera (available at spectrr.eth)
- Testnet: Polygon Mumbai (available at test.spectrr.eth)
(Because The Graph hosted service does not directly support Fantom testnet [indexing](https://thegraph.com/docs/en/deploying/deploying-a-subgraph-to-hosted/])

# Installation

To get this repository on your machine:
```
> git clone https://gitlab.com/spectrrfi/contracts
> cd contracts/
> npm install --save-dev
```

To deploy the contracts:
```
> npm run deploy
// deploy to specific chain (check the file 'hardhat.config.js' for available chain options)
> npm run deploy --network fantom_mainnet
```

# Disclaimer

- "PROVIDED AS IS", No Warranty or Liability Whatsoever.
- Trading Cryptocurrencies is Very Risky.

# Contributing

Feel free to contribute in any way to this project.
Pull requests, comments, and emails are all appreciated.

# Contact

email: supergrayfly@proton.me

# License

BSD-3-Clause
