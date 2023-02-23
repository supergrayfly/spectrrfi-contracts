# Solidity API

## SpectrrCore

### constructor

```solidity
constructor() public
```

_EIP712 Constructor
EIP712's params are the name and version of the contract_

### createSaleOffer

```solidity
function createSaleOffer(uint256 _sellingTokenAmountWei, uint8 _sellingTokenId, uint256 _exchangeRateWei, uint8 _sellingForTokenId, uint256 _repayInSeconds) external returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 Id of the offer created |

### acceptSaleOffer

```solidity
function acceptSaleOffer(uint256 _offerId, uint8 _collateralTokenId) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 |  |
| _collateralTokenId | uint8 | Id of the token to be pledged as collateral,         cannot be same than id of selling token. |

### cancelSaleOffer

```solidity
function cancelSaleOffer(uint256 _offerId) external
```

Cancels a sale offer, given that it is not accepted yet

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to cancel |

### addCollateralSaleOffer

```solidity
function addCollateralSaleOffer(uint256 _offerId, uint256 _amountToAdd) external
```

Adds collateral to a sale offer

_Can only be called by the buyer of the sale offer_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to add collateral to |
| _amountToAdd | uint256 | Amount of collateral to add |

### repaySaleOffer

```solidity
function repaySaleOffer(uint256 _offerId) external
```

Fully repays the debt of a sale offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to repay |

### repaySaleOfferPart

```solidity
function repaySaleOfferPart(uint256 _offerId, uint256 _amountToRepay) external
```

Partially repays the debt of a sale offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to partially repay |
| _amountToRepay | uint256 | Amount to partially repay |

### liquidateSaleOffer

```solidity
function liquidateSaleOffer(uint256 _offerId) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to liquidate |

### forfeitSaleOffer

```solidity
function forfeitSaleOffer(uint256 _offerId) external
```

Forfeits a sale offer

_Only callable by the buyer
Transaction is reverted if it incurs a loss to the seller_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to forfeit |

### createBuyOffer

```solidity
function createBuyOffer(uint256 _buyingTokenAmountWei, uint8 _buyingTokenId, uint256 _exchangeRateWei, uint8 _buyingForTokenId, uint8 _collateralTokenId, uint256 _repayInSeconds) external returns (uint256)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _buyingTokenAmountWei | uint256 |  |
| _buyingTokenId | uint8 |  |
| _exchangeRateWei | uint256 |  |
| _buyingForTokenId | uint8 |  |
| _collateralTokenId | uint8 |  |
| _repayInSeconds | uint256 | Repayment timeframe in unix seconds,         a value of 0 will allow an unlimited repayment time . |

### acceptBuyOffer

```solidity
function acceptBuyOffer(uint256 _offerId) external
```

Accepts a buy offer by transferring the amount buying from the seller to the buyer
There is a 0.1% fee of the buying amount, paid by the seller.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to accept |

### cancelBuyOffer

```solidity
function cancelBuyOffer(uint256 _offerId) external
```

Cancels a buy offer, given that it not accepted yet

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to cancel |

### addCollateralBuyOffer

```solidity
function addCollateralBuyOffer(uint256 _offerId, uint256 _amountToAdd) external
```

Adds collateral to a buy offer

_Can only be called by the buyer of the buy offer_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to add collateral to |
| _amountToAdd | uint256 | The amount of collateral to add |

### repayBuyOffer

```solidity
function repayBuyOffer(uint256 _offerId) external
```

Fully repays the debt of the buy offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to repay |

### repayBuyOfferPart

```solidity
function repayBuyOfferPart(uint256 _offerId, uint256 _amountToRepay) external
```

Partially repays the debt of a buy offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to partially repay |
| _amountToRepay | uint256 | Amount to partially repay |

### liquidateBuyOffer

```solidity
function liquidateBuyOffer(uint256 _offerId) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to liquidate |

### forfeitBuyOffer

```solidity
function forfeitBuyOffer(uint256 _offerId) external
```

Forfeits a buy offer

_Only callable by the buyer
Transaction is reverted if it incurs a loss to the seller_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to forfeit |

### changeAddressSale

```solidity
function changeAddressSale(uint256 _offerId, address _newAddress, uint8 _addressType) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to change addresses |
| _newAddress | address | New address to replace the old one with |
| _addressType | uint8 | Type of address: 0 for seller address, and 1 for buyer address. |

### changeAddressBuy

```solidity
function changeAddressBuy(uint256 _offerId, address _newAddress, uint8 _addressType) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to change addresses |
| _newAddress | address | New address to replace the old one with |
| _addressType | uint8 | Type of address: 0 for seller address, and 1 for buyer address. |

### getRatioInfo

```solidity
function getRatioInfo(uint256 _offerId, uint8 _offerType) external view returns (uint256, uint256, uint8, uint8, address)
```

Gets the collateral to debt ratio, debt amount, debt amount id, collateral id, and buyer's address of an offer.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to get info on |
| _offerType | uint8 | Type of offer: 0 for sale offer and 1 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 Collateral to debt ratio |
| [1] | uint256 | uint256 Debt amount |
| [2] | uint8 | uint8 Id of the debt token |
| [3] | uint8 | uint8 Id of the collateral |
| [4] | address | address Address of the buyer |

### canLiquidate

```solidity
function canLiquidate(uint256 _offerId, uint8 _offerType) external view returns (bool)
```

Checks if an offer can be liquidated

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to check |
| _offerType | uint8 | Type of offer: 0 for sale offer and 1 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the offer can be liquidated or not |

### isLiquidationLoss

```solidity
function isLiquidationLoss(uint256 _offerId, uint8 _offerType) external view returns (bool)
```

Determines if a liquidation will incur a loss

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to check |
| _offerType | uint8 | Type of offer: 0 for sale offer and 1 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the liquidation will incur a loss or not |

### getLiquidationPriceCollateral

```solidity
function getLiquidationPriceCollateral(uint256 _offerId, uint8 _offerType) external view returns (uint256)
```

Gets the price of the collateral token at which the offer will be liquidable

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want the liquidation price |
| _offerType | uint8 | Type of offer: 0 for sale offer and 1 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The liquidation price of the collateral token |

### getLiquidationPriceAmountFor

```solidity
function getLiquidationPriceAmountFor(uint256 _offerId, uint8 _offerType) external view returns (uint256)
```

Gets the price of the debt token at which the offer will be liquidable

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want the liquidation price |
| _offerType | uint8 | Type of offer: 0 for sale offer and 1 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The liquidation price of the debt token |

## SpectrrData

Defines and initializes the data for the SpectrrCore Contract

### MIN_RATIO_LIQUIDATION

```solidity
uint256 MIN_RATIO_LIQUIDATION
```

The minimum collateral to debt ratio allowing a liquidation (1.25%)

### RATIO_LIQUIDATION_IS_LOSS

```solidity
uint256 RATIO_LIQUIDATION_IS_LOSS
```

The collateral to debt ratio when the value of the collateral is equal to the value of the debt (1%)

### RATIO_COLLATERAL_TO_DEBT

```solidity
uint256 RATIO_COLLATERAL_TO_DEBT
```

The initial collateral to debt ratio needed to create an offer (1.5%)

### saleOffersCount

```solidity
uint256 saleOffersCount
```

_Number of existing sale offers, initialized as 0 in the beggining,
        and incremented by one at every sale offer creation._

### buyOffersCount

```solidity
uint256 buyOffersCount
```

_Number of existing buy offers, initialized as 0 in the beggining,
        and incremented by one at every buy offer creation._

### saleOffers

```solidity
mapping(uint256 => struct SpectrrData.SaleOffer) saleOffers
```

_Map of offer id (saleOffersCount) and sale offer struct_

### buyOffers

```solidity
mapping(uint256 => struct SpectrrData.BuyOffer) buyOffers
```

_Map of offer id (buyOffersCount) and buy offer struct_

### OfferStatus

```solidity
enum OfferStatus {
  open,
  accepted,
  closed
}
```

### OfferLockState

```solidity
enum OfferLockState {
  locked,
  unlocked
}
```

### SaleOffer

```solidity
struct SaleOffer {
  enum SpectrrData.OfferStatus offerStatus;
  enum SpectrrData.OfferLockState offerLockState;
  uint256 offerId;
  uint256 selling;
  uint256 sellingFor;
  uint256 collateral;
  uint256 repayInSeconds;
  uint256 timeAccepted;
  uint8 sellingId;
  uint8 sellingForId;
  uint8 collateralId;
  address seller;
  address buyer;
}
```

### BuyOffer

```solidity
struct BuyOffer {
  enum SpectrrData.OfferStatus offerStatus;
  enum SpectrrData.OfferLockState offerLockState;
  uint256 offerId;
  uint256 buying;
  uint256 buyingFor;
  uint256 collateral;
  uint256 repayInSeconds;
  uint256 timeAccepted;
  uint8 buyingId;
  uint8 buyingForId;
  uint8 collateralId;
  address buyer;
  address seller;
}
```

### SaleOfferCreated

```solidity
event SaleOfferCreated(uint256 offerId, uint256 selling, uint8 sellingId, uint256 sellingFor, uint8 sellingForId, uint256 exRate, uint256 repayInSeconds, address seller, uint256 timestamp)
```

Event emitted when a sale offer is created

### SaleOfferAccepted

```solidity
event SaleOfferAccepted(uint256 offerId, uint256 collateral, uint8 collateralId, address buyer, uint256 timestamp)
```

Event emitted when a sale offer is accepted

### SaleOfferCollateralAdded

```solidity
event SaleOfferCollateralAdded(uint256 offerId, uint256 amount, uint256 amountId, uint256 timestamp)
```

Event emitted when collateral is added to a sale offer

### SaleOfferCanceled

```solidity
event SaleOfferCanceled(uint256 offerId, uint256 timestamp)
```

Event emitted when a sale offer is canceled

### SaleOfferLiquidated

```solidity
event SaleOfferLiquidated(uint256 offerId, address liquidator, uint256 timestamp)
```

Event emitted when a sale offer is liquidated

### SaleOfferSellerAddressChanged

```solidity
event SaleOfferSellerAddressChanged(uint256 offerId, address newAddress)
```

Event emitted when the seller address of a sale offer changes

### SaleOfferBuyerAddressChanged

```solidity
event SaleOfferBuyerAddressChanged(uint256 offerId, address newAddress)
```

Event emitted when the buyer address of a sale offer changes

### SaleOfferRepaid

```solidity
event SaleOfferRepaid(uint256 offerId, uint256 amount, uint8 amountId, bool byPart, uint256 timestamp)
```

Event emitted when a sale offer is repaid

### SaleOfferForfeited

```solidity
event SaleOfferForfeited(uint256 offerId, uint256 timestamp)
```

Event emitted when a sale offer is forfeited

### BuyOfferCreated

```solidity
event BuyOfferCreated(uint256 offerId, uint256 buying, uint8 buyingId, uint256 buyingFor, uint8 buyingForId, uint256 exRate, uint8 collateralId, uint256 repayInSeconds, address buyer, uint256 timestamp)
```

Event emitted when a buy offer is created

### BuyOfferAccepted

```solidity
event BuyOfferAccepted(uint256 offerId, address seller, uint256 timestamp)
```

Event emitted when a buy offer is accepted

### BuyOfferCollateralAdded

```solidity
event BuyOfferCollateralAdded(uint256 offerId, uint256 amount, uint8 amountId, uint256 timestamp)
```

Event emitted when collateral is added to a buy offer

### BuyOfferCanceled

```solidity
event BuyOfferCanceled(uint256 offerId, uint256 timestamp)
```

Event emitted when a buy offer is canceled

### BuyOfferLiquidated

```solidity
event BuyOfferLiquidated(uint256 offerId, address liquidator, uint256 timestamp)
```

Event emitted when a buy offer is liquidated

### BuyOfferSellerAddressChanged

```solidity
event BuyOfferSellerAddressChanged(uint256 offerId, address newAddress)
```

Event emitted when the seller address of a buy offer changes

### BuyOfferBuyerAddressChanged

```solidity
event BuyOfferBuyerAddressChanged(uint256 offerId, address newAddress)
```

Event emitted when the buyer address of a buy offer changes

### BuyOfferRepaid

```solidity
event BuyOfferRepaid(uint256 offerId, uint256 amount, uint8 amountId, bool byPart, uint256 timestamp)
```

Event emitted when a buy offer is repaid

### BuyOfferForfeited

```solidity
event BuyOfferForfeited(uint256 offerId, uint256 timestamp)
```

Event emitted when a buy offer is forfeited

### lockSaleOffer

```solidity
modifier lockSaleOffer(uint256 _offerId)
```

_Modifier used to protect from reentrancy.
        Called when a function changing the state of a sale offer struct is entered, it prevents changes by anyone aside from the current msg.sender.
        It differs from the nonReentrant modifier, 
        as the latter only restricts the msg.sender from calling other functions in the contract._

### lockBuyOffer

```solidity
modifier lockBuyOffer(uint256 _offerId)
```

_Same as modifier above, but for buy offers_

## SpectrrManager

This contract handles functions that can only be called by the dev address (e.g.: Adding new tradable tokens).

### feeAddress

```solidity
address feeAddress
```

address where transaction fees will be sent

### FEE_PERCENT

```solidity
uint16 FEE_PERCENT
```

Fee corresponding to 0.1% (amount * (100 / 0.1) = 1000,
				taken when an offer is created and accepted.

### tokenCount

```solidity
uint8 tokenCount
```

The number of tokens tradable by this contract

_Used as a counter for the tokens mapping_

### tokens

```solidity
mapping(uint8 => struct SpectrrManager.Token) tokens
```

_Map of the number of tokens and Token struct_

### Token

```solidity
struct Token {
  uint8 tokenId;
  uint8 decimals;
  string tokenName;
  address tokenAddress;
  address chainlinkOracleAddress;
  contract IERC20 Itoken;
}
```

### NewTokenAdded

```solidity
event NewTokenAdded(uint8 tokenId, string tokenName, address tokenAddress, address chainlinkOracleAddress)
```

Event emitted when a new token is added

### FeeAddressChanged

```solidity
event FeeAddressChanged(address newAddress)
```

Event emitted when the fee address is changed

### addToken

```solidity
function addToken(string _tokenName, address _tokenAddress, address _chainlinkOracleAddress, uint8 _decimals) external
```

Adds a token to the array of tokens tradable by this contract

_Only callable by owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenName | string | Name of the token to add in the following format: "btc" |
| _tokenAddress | address | Address of the token |
| _chainlinkOracleAddress | address | Address of the chainlink contract used to take the price from |
| _decimals | uint8 | Number of decimals the chainlink price has |

### changeFeeAddress

```solidity
function changeFeeAddress(address _newFeeAddress) external
```

Changes the fee address

_Only callable by the current owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newFeeAddress | address | The new fee address |

## SpectrrPrices

Fetches the prices of various currency pairs from Chainlink price feed oracles

### getChainlinkPrice

```solidity
function getChainlinkPrice(address _chainlinkOracleAddress) public view returns (int256)
```

## SpectrrUtils

This contract handles 'secondary' functions, such as transferring tokens and calculating collateral tokens.

### getBlockTimestamp

```solidity
function getBlockTimestamp() external view returns (uint256)
```

Gets the current block timestamp

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The current block timestamp |

### getITokenFromId

```solidity
function getITokenFromId(uint8 _tokenId) public view returns (contract IERC20)
```

Gets the interface of a token based on its id

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint8 | Id of the token we want the interface |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract IERC20 | IERC20 The Interface of the token |

### tokenIdToPrice

```solidity
function tokenIdToPrice(uint8 _tokenId) public view returns (uint256)
```

Gets the price of a token from Chainlink

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint8 | Id of the token we want the price |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The price of the token |

### getLiquidationPriceCollateral

```solidity
function getLiquidationPriceCollateral(uint256 _collateralTokenAmountWei, uint256 _amountForTokenWei, uint8 _amountForTokenId, uint256 _liquidationLimit) public view returns (uint256)
```

Calculates the liquidation price of the collateral token

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | liquidationPrice Price of the collateral token at which a liquidation will be possible |

### getLiquidationPriceAmountFor

```solidity
function getLiquidationPriceAmountFor(uint256 _collateralTokenAmountWei, uint256 _amountForTokenWei, uint8 _collateralTokenId, uint256 _liquidationLimit) public view returns (uint256)
```

Calculates the liquidation price of the debt token

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | liquidationPrice Price of the debt token at which a liquidation will be possible |

### transferSenderToContract

```solidity
function transferSenderToContract(address _sender, uint256 _amountTokenWei, uint8 _amountTokenId) internal
```

Transfers tokens from the sender to this contract

_Only callable internally by this contract_

### transferContractToSender

```solidity
function transferContractToSender(address _sender, uint256 _amountTokenWei, uint8 _amountTokenId) internal
```

Transfers tokens from this contract to the sender of the tx

_Only callable internally by this contract_

### transferAcceptSale

```solidity
function transferAcceptSale(address _sender, uint256 _collateralTokenAmountWei, uint8 _collateralTokenId, uint256 _amountTokenWei, uint8 _amountTokenId) internal
```

Handles the transfer of the collateral, fee, and amount bought

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _sender | address | Address sending the tokens |
| _collateralTokenAmountWei | uint256 | Collateral amount to transfer from the sender |
| _collateralTokenId | uint8 | Id of the collateral token |
| _amountTokenWei | uint256 | Amount bought by the sender |
| _amountTokenId | uint8 | Id of the bought token |

### transferBuyerToSeller

```solidity
function transferBuyerToSeller(address _sender, address _receiver, uint256 _amountTokenWei, uint8 _amountTokenId) internal
```

Transfers token from the buyer to the seller of an offer

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _sender | address | Address sending the tokens |
| _receiver | address | Address receiving the tokens |
| _amountTokenWei | uint256 | Amount to send |
| _amountTokenId | uint8 | Id of the amount to send |

### getCollateral

```solidity
function getCollateral(uint256 _amountTokenWei, uint8 _amountTokenId, uint8 _collateralTokenId, uint256 _collateralTokenAmountWeiToDebtRatio) public view returns (uint256)
```

Calculates the collateral needed to create a buy offer or accept a sale offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount on which the collateral will be calculated |
| _amountTokenId | uint8 | Id of the amount |
| _collateralTokenId | uint8 | Id of the collateral |
| _collateralTokenAmountWeiToDebtRatio | uint256 | Collateral to debt ratio, used to calculate the collateral amount. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | collateral Computed collateral amount |

### getRatio

```solidity
function getRatio(uint256 _amountTokenWei, uint256 _collateralTokenAmountWei, uint8 _amountTokenId, uint8 _collateralTokenId) public view returns (uint256)
```

Calculates the ratio of the collateral over the debt

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount of debt |
| _collateralTokenAmountWei | uint256 | Collateral amount |
| _amountTokenId | uint8 | Id of the debt amount |
| _collateralTokenId | uint8 | Id of the collateral |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | ratio Calculated ratio |

### canLiquidate

```solidity
function canLiquidate(uint256 _amountTokenWei, uint8 _amountTokenId, uint256 _collateralTokenAmountWei, uint8 _collateralTokenId, uint256 _liquidationLimitRatio) public view returns (bool)
```

Determines if the collateral to debt ratio has reached the liquidation limit

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount of debt |
| _amountTokenId | uint8 | Id of the debt amount |
| _collateralTokenAmountWei | uint256 | Collateral amount |
| _collateralTokenId | uint8 | Id of the collateral |
| _liquidationLimitRatio | uint256 | Ratio at which liquidation will be possible |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the offer can be liquidated or not |

### canLiquidateTimeOver

```solidity
function canLiquidateTimeOver(uint256 _timeAccepted, uint256 _repayInSeconds) public view returns (bool)
```

Determines if the repayment period has passed

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _timeAccepted | uint256 | Time at which the offer was accepted |
| _repayInSeconds | uint256 | Repayment period of the offer |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the offer can be liquidated or not |

### liquidateTokens

```solidity
function liquidateTokens(uint256 _amountTokenWei, uint8 _amountTokenId, uint256 _collateralTokenAmountWei, uint8 _collateralTokenId, address _seller, address _buyer, address _sender, uint256 _liquidationLossRatio) internal
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount of debt |
| _amountTokenId | uint8 | Id of the debt amount |
| _collateralTokenAmountWei | uint256 | Amount of collateral |
| _collateralTokenId | uint8 | Id of the collateral |
| _seller | address | Address of the offer's seller |
| _buyer | address | Address of the offer's buyer |
| _sender | address | Address of the liquidator |
| _liquidationLossRatio | uint256 | Ratio at which a liquidation will incur a loss (i.e., the collateral value is below the debt) |

### liquidateTokensBySeller

```solidity
function liquidateTokensBySeller(uint256 _amountTokenWei, uint8 _amountTokenId, uint256 _collateralTokenAmountWei, uint8 _collateralTokenId, address _buyer, address _seller, uint256 _liquidationLossRatio) internal
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount of debt |
| _amountTokenId | uint8 | Id of the debt amount |
| _collateralTokenAmountWei | uint256 | Amount of collateral |
| _collateralTokenId | uint8 | Id of the collateral |
| _buyer | address | Address of the buyer |
| _seller | address | Address of the seller |
| _liquidationLossRatio | uint256 | Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value) |

### liquidateTokensByBuyer

```solidity
function liquidateTokensByBuyer(uint256 _amountTokenWei, uint8 _amountTokenId, uint256 _collateralTokenAmountWei, uint8 _collateralTokenId, address _buyer, address _seller, uint256 _liquidationLossRatio) internal
```

Liquidates an offer when the liquidator is the buyer

_Only callable internally by this contract, reverts if it incurs a loss to the seller._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount of debt |
| _amountTokenId | uint8 | Id of the debt amount |
| _collateralTokenAmountWei | uint256 | Amount of collateral |
| _collateralTokenId | uint8 | Id of the collateral |
| _buyer | address | Address of the buyer |
| _seller | address | Address of the seller |
| _liquidationLossRatio | uint256 | Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value) |

### repay

```solidity
function repay(uint256 _amountToRepay, uint8 _amountToRepayId, uint256 _collateralTokenAmountWei, uint8 _collateralTokenId, address _seller, address _buyer) internal
```

Repays a debt, and transfers back the collateral.

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountToRepay | uint256 | Amount to repay |
| _amountToRepayId | uint8 | Id of the amount to repay |
| _collateralTokenAmountWei | uint256 | Amount of collateral |
| _collateralTokenId | uint8 | Id of the collateral |
| _seller | address | Address of the seller |
| _buyer | address | Address of the buyer |

### transferFee

```solidity
function transferFee(uint256 _amountTokenWei, uint8 _amountTokenId, address _sender) internal
```

Transfers the fee from the sender to the fee address

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount on which 0.1% will be taken |
| _amountTokenId | uint8 | Id of the amount |
| _sender | address | Address of the sender |

### checkTokenIdInRange

```solidity
function checkTokenIdInRange(uint8 _id) internal view
```

Checks if token Id is a tradable token

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint8 | Id of the token |

### checkAddressNotSender

```solidity
function checkAddressNotSender(address _address) internal view
```

Checks if address matches with sender of transaction, reverts if true

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | Address to compare with msg.sender |

### checkAddressSender

```solidity
function checkAddressSender(address _address) internal view
```

Checks if address matches with sender of transaction, reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | Address to compare with msg.snder |

### checkIsPositive

```solidity
function checkIsPositive(uint256 _amountTokenWei) internal pure
```

Checks if amount is positive, reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | Amount to check |

### checkTokensIdNotSame

```solidity
function checkTokensIdNotSame(uint8 _id, uint8 id_) internal pure
```

Checks if id of two tokens are the same, reverts if true

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint8 | Id of first token |
| id_ | uint8 | id of second token |

### checkOfferIsOpen

```solidity
function checkOfferIsOpen(enum SpectrrData.OfferStatus _offerStatus) internal pure
```

Checks if offer is open (i.e. not accepted or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerStatus | enum SpectrrData.OfferStatus | Current state of the offer |

### checkOfferIsAccepted

```solidity
function checkOfferIsAccepted(enum SpectrrData.OfferStatus _offerStatus) internal pure
```

Checks if offer is accepted (i.e. not open or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerStatus | enum SpectrrData.OfferStatus | Current state of the offer |

### checkOfferIsClosed

```solidity
function checkOfferIsClosed(enum SpectrrData.OfferStatus _offerStatus) internal pure
```

Checks if offer is closed (i.e. not open or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerStatus | enum SpectrrData.OfferStatus | Current state of the offer |

### checkOfferIsNotClosed

```solidity
function checkOfferIsNotClosed(enum SpectrrData.OfferStatus _offerStatus) internal pure
```

Checks if offer is closed (i.e. not open or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerStatus | enum SpectrrData.OfferStatus | Current state of the offer |

### checkIsLessThan

```solidity
function checkIsLessThan(uint256 _amountTokenWei, uint256 _debt) internal pure
```

Checks if amount sent is bigger than debt, reverts if true

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amountTokenWei | uint256 | The amount to send |
| _debt | uint256 | The debt owed |

## SpectrrPaymentSplitter

This contract receives and distributes the fees genrated by Spectrr Finance to different receivers.

### constructor

```solidity
constructor() public
```

