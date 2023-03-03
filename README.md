# Spectrr Finance Solidity Smart Contracts

Interest-Free Lending and Borrowing like Decentralised Application.

## Motivation

- Provide an alternative to interest based lending and borrowing DApps
- Buy Bugatti

## Overview

The Spectrr Finance Smart Contracts enable people to sell and buy crypto assets, and then repay them at a later time.
The protocol is based on Cost Plus Financing or *Murabaha* (in arabic), which is widely used in Islamic banks to finance its customers([1](https://www.investopedia.com/articles/07/islamic_investing.asp), [2](https://www.gfmag.com/topics/blogs/what-products-does-islamic-finance-offer)) 
To have a glimpse of how Spectrr Finance works, consider the following sale offer (Let us assume a Bitcoin price of 21,000 $):

- Bob - the seller - wants to sell 0.5 Bitcoin at a rate of 22,000 USDC/BTC, or 0.5 BTC for 11,000 USDC. 
Also, he indicates a repayment period of 7 days.
- Alice - the buyer - is interested in Bob's offer. So, she accepts Bob's offer by posting a collateral of 1.5 times the amount she's buying, or 11,000 * 1.5 = 16,500 USDC (could be any other token but BTC), and receives Bob's 0.5 BTC.
- Now, we can have the following three scenarios:
	1. Before the repayment limit (7 days), Alice repays the 11,000 USDC debt and receives back her 16,500 USDC collateral.
	2. Alice fails to repay her debt before 7 days. Bob can get the collateral tokens posted by Alice up to the value of the debt. The rest will be sent back to Alice. If the value of the collateral is below the debt value, Bob will receive all of the collateral. Also, it should be mentionned that people aside from the seller can also liquidate a buyer. However, they have to first repay the debt of the buyer to the seller, and then they will receive the posted collateral.
	3. Before 7 days, Alice decides to forfeit the offer. By doing that, she will send to Bob collateral up to the value of her debt, and then receive back the rest if any.
- In our scenario, if Alice repays her debt *or* is liquidated in time, Bob would make a profit of 22,000 * 0.5 - 21,000 * 0.5 = 500 $. 
Otherwise, Bob will be losing the following amount:
loss = collateral value - debt value 
- Meanwhile, the profit of Alice depends on what she did with the 0.5 BTC she bought from Bob.

The same mechanism also applies when someone wants to buy tokens and repay another token after some time (buy offer).

For a more detailed and technical explanation of the Smart Contracts, you can view the documentation present in the 'docs' folder of this repository.

## Design Choices

- Lending and borrowing mechanism with no interest, 
profit is made by selling or buying an asset for a different asset at a value higher than the market.
	- You cannot sell/buy a token in exchange of the same token
	- Your collateral token cannot be the same as the token you are selling/buying.
- Lending and borrowing process is offer based. Meaning that users post sale and buy offers, 
which other users can then accept (peer-to-peer, permissionless).
- Contract is not upgradable (no protocol rule changes).
- No governace token (not necessary for contract functionning).
- Prices are taken from Chainlink Oracles.
- 0.1% fee is taken when offers are created and accepted 

## Supported Networks

- Mainnet: Fantom Opera (available at spectrr.eth)
- Testnet: Fantom Testnet (also available at spectrr.eth)

## Installation

To get this repository on your machine:
```
> git clone https://gitlab.com/spectrrfi/contracts
> cd contracts/
> npm install --save-dev
```

To deploy the contracts:
```
// deploying to fantom blockchain:
> npm run deploy
// deploying to mumbai blockchain:
> npm run deployTest
```

## Disclaimer

- "SOFTWARE PROVIDED AS IS", No Warranty or Liability Whatsoever.
- Trading Cryptocurrencies is Very Risky.

# Contributing

Feel free to contribute in any way to this project.
Pull requests, comments, and emails are all appreciated.

# Contact

- email: supergrayfly@proton.me
- gpg public key: https://gitlab.com/supergrayfly.gpg

## License

BSD-3-Clause
