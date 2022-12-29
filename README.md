# Spectrr Finance Solidity Smart Contracts

Interest-Free Lending and Borrowing Decentralised Application.

# Design Choices

- Lending and borrowing with no interest, 
profit is made by selling or buying an asset for a different asset at a vlue higher than the market
- Lending and borrowing process is offer based. Meaning that users post sale and buy offers, 
which other users can then accept.
- Contract is not upgradable.
- There is no governace token.

# Supported Networks

- Mainnet: Fantom Opera
- Testnet: Polygon Mumbai 
(Because The Graph hosted service does not directly support Fantom testnet indexing)

# Testing

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

# Miscellaneous

- Prices taken from Chainlink
- 0.1% fee taken when offers are accepted.

# Contributing

Feel free to contribute in any way to this project.
Pull requests, comments, and emails are all appreciated.

# Contact

email: supergrayfly@proton.me

# License

BSD-3-Clause
