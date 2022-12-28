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
function createSaleOffer(uint256 _selling, uint8 _sellingId, uint256 _exRate, uint8 _sellForId, uint256 _repayInSec) external returns (uint256)
```

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 Id of the offer created |

### acceptSaleOffer

```solidity
function acceptSaleOffer(uint256 _offerId, uint8 _collateralId) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 |  |
| _collateralId | uint8 | Id of the token to be pledged as collateral,         cannot be same than id of selling token. |

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
function addCollateralSaleOffer(uint256 _offerId, uint256 _amount) external
```

Adds collateral to a sale offer

_Can only be called by the buyer of the sale offer_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to add collateral to |
| _amount | uint256 | Amount of collateral to add |

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
function repaySaleOfferPart(uint256 _offerId, uint256 _amount) external
```

Partially repays the debt of a sale offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the sale offer to partially repay |
| _amount | uint256 | Amount to partially repay |

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
function createBuyOffer(uint256 _buying, uint8 _buyingId, uint256 _exRate, uint8 _buyForId, uint8 _collateralId, uint256 _repayInSec) external returns (uint256)
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _buying | uint256 |  |
| _buyingId | uint8 |  |
| _exRate | uint256 |  |
| _buyForId | uint8 |  |
| _collateralId | uint8 |  |
| _repayInSec | uint256 | Repayment timeframe in unix seconds,         a value of 0 will allow an unlimited repayment time . |

### acceptBuyOffer

```solidity
function acceptBuyOffer(uint256 _offerId) external
```

Accepts a buy offer by transferring the amount buying from the seller to the buyer
There is a 0.5% fee of the buying amount, paid by the seller.

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
function addCollateralBuyOffer(uint256 _offerId, uint256 _amount) external
```

Adds collateral to a buy offer

_Can only be called by the buyer of the buy offer_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to add collateral to |
| _amount | uint256 | The amount of collateral to add |

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
function repayBuyOfferPart(uint256 _offerId, uint256 _amount) external
```

Partially repays the debt of a buy offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the buy offer to partially repay |
| _amount | uint256 | Amount to partially repay |

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

### changeAddrSale

```solidity
function changeAddrSale(uint256 _offerId, address _newAddr, uint8 _addrType) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to change addresses |
| _newAddr | address | New address to replace the old one with |
| _addrType | uint8 | Type of address: 0 for seller address, and 1 for buyer address. |

### changeAddrBuy

```solidity
function changeAddrBuy(uint256 _offerId, address _newAddr, uint8 _addrType) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to change addresses |
| _newAddr | address | New address to replace the old one with |
| _addrType | uint8 | Type of address: 0 for seller address, and 1 for buyer address. |

### getRatioInfo

```solidity
function getRatioInfo(uint256 _offerId, uint8 _offerType) external view returns (uint256, uint256, uint8, uint8, address)
```

Gets the collateral to debt ratio, debt amount, debt amount id, collateral id, and buyer's address of an offer.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want to get info on |
| _offerType | uint8 | Type of offer: 1 for sale offer and 2 for buy offer. |

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
| _offerType | uint8 | Type of offer: 1 for sale offer and 2 for buy offer. |

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
| _offerType | uint8 | Type of offer: 1 for sale offer and 2 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the liquidation will incur a loss or not |

### getLiquidationPriceCollateral

```solidity
function getLiquidationPriceCollateral(uint256 _offerId, uint8 _offerType) external view returns (uint256)
```

Gets the liquidation price of the collateral token

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want the liquidation price |
| _offerType | uint8 | Type of offer: 1 for sale offer and 2 for buy offer. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The liquidation price of the collateral token |

### getLiquidationPriceAmountFor

```solidity
function getLiquidationPriceAmountFor(uint256 _offerId, uint8 _offerType) external view returns (uint256)
```

Gets the liquidation price of the debt token

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerId | uint256 | Id of the offer we want the liquidation price |
| _offerType | uint8 | Type of offer: 1 for sale offer and 2 for buy offer. |

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

The minimum collateral to debt ratio allowing a liquidation

### RATIO_LIQUIDATION_LOSS

```solidity
uint256 RATIO_LIQUIDATION_LOSS
```

The collateral to debt ratio when the value of the collateral is equal to the value of the debt.

### RATIO_COLLATERAL_TO_DEBT

```solidity
uint256 RATIO_COLLATERAL_TO_DEBT
```

The initial collateral to debt ratio needed to create an offer.

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

### OfferState

```solidity
enum OfferState {
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
  enum SpectrrData.OfferState offerState;
  enum SpectrrData.OfferLockState offerLockState;
  uint256 offerId;
  uint256 selling;
  uint256 sellFor;
  uint256 collateral;
  uint256 repayInSec;
  uint256 timeAccepted;
  uint8 sellingId;
  uint8 sellForId;
  uint8 collateralId;
  address seller;
  address buyer;
}
```

### BuyOffer

```solidity
struct BuyOffer {
  enum SpectrrData.OfferState offerState;
  enum SpectrrData.OfferLockState offerLockState;
  uint256 offerId;
  uint256 buying;
  uint256 buyFor;
  uint256 collateral;
  uint256 repayInSec;
  uint256 timeAccepted;
  uint8 buyingId;
  uint8 buyForId;
  uint8 collateralId;
  address buyer;
  address seller;
}
```

### SaleOfferCreated

```solidity
event SaleOfferCreated(uint256 offerId, uint256 selling, uint8 sellingId, uint256 sellFor, uint8 sellForId, uint256 exRate, uint256 repayInSec, address seller, uint256 timestamp)
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
event BuyOfferCreated(uint256 offerId, uint256 buying, uint8 buyingId, uint256 buyFor, uint8 buyForId, uint256 exRate, uint8 collateralId, uint256 repayInSec, address buyer, uint256 timestamp)
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
        Called when a function changing the state of a sale offer struct is entered,
        it prevents changes made to the struct by anyone aside from the current msg.sender.
        It differs from the nonReentrant modifier, 
        as the latter restricts only the msg.sender from calling other functions in the contract._

### lockBuyOffer

```solidity
modifier lockBuyOffer(uint256 _offerId)
```

_Same as modifier above, but for buy offers_

## SpectrrPrices

Fetches the prices of various currency pairs

### MAX_RESPONSE_TIME

```solidity
uint256 MAX_RESPONSE_TIME
```

The maximum timeframe in seconds, at which the price request must be fulfilled.

### getChainlinkPrice

```solidity
function getChainlinkPrice(address _chainlinkAddr) public view returns (int256)
```

### checkPrice

```solidity
function checkPrice(int256 _price, uint256 _startedAt, uint256 _timestamp) internal pure
```

Checks if the price is valid

_It firsts ensures that the price is positive, and then if the request was fulfilled in the required time frame._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _price | int256 | Price of the token |
| _startedAt | uint256 | Time at which the request was initiated |
| _timestamp | uint256 | Time at which the request was fulfilled |

## SpectrrUtils

This contract handles 'secondary' functions, such as transferring tokens and calculating collateral.

### feeAddr

```solidity
address feeAddr
```

address where transaction fees will be sent

### FEE_PERCENT

```solidity
uint16 FEE_PERCENT
```

Fee corresponding to 0.5% (amount * (100 / 0.5) = 200),
				taken from every accept sale/buy offer transaction.
        In the case of a sale offer it is paid by the buyer.
        In the case of a buy offer it is paid by the seller.

### tokenCount

```solidity
uint8 tokenCount
```

The number of tokens tradable by this contract

_Used as a counter for the tokens mapping_

### tokens

```solidity
mapping(uint8 => struct SpectrrUtils.Token) tokens
```

_Map of the number of tokens and Token struct_

### Token

```solidity
struct Token {
  uint8 tokenId;
  uint8 priceDecimals;
  string tokenName;
  contract IERC20 Itoken;
  address tokenAddr;
  address chainlinkAddr;
}
```

### NewToken

```solidity
event NewToken(uint8 tokenId, string name, address tokenAddr, address chainlinkAddr)
```

Event emitted when a new token is added

### FeeAddrChanged

```solidity
event FeeAddrChanged(address newAddr, uint256 timestamp)
```

Event emitted when the fee address is changed

### getBlockTimestamp

```solidity
function getBlockTimestamp() external view returns (uint256)
```

Gets the current block timestamp

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 The current block timestamp |

### addToken

```solidity
function addToken(string _tokenName, address _tokenAddr, address _chainlinkAddr, uint8 _priceDecimals) external
```

Adds a token to the array of tokens tradable by this contract

_Only callable by owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenName | string | Name of the token to add in the following format: "btc" |
| _tokenAddr | address | Address of the token |
| _chainlinkAddr | address | Address of the chainlink contract used to take the price from |
| _priceDecimals | uint8 | Number of decimals the chainlink price has |

### getToken

```solidity
function getToken(uint8 _tokenId) public view returns (contract IERC20)
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

### idToPrice

```solidity
function idToPrice(uint8 _tokenId) public view returns (uint256)
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

### transferSenderToContract

```solidity
function transferSenderToContract(address _sender, uint256 _amount, uint8 _amountId) internal
```

Transfers tokens from the sender to this contract

_Only callable internally by this contract_

### transferContractToSender

```solidity
function transferContractToSender(address _sender, uint256 _amount, uint8 _amountId) internal
```

Transfers tokens from this contract to the sender of the tx

_Only callable internally by this contract_

### changeFeeAddr

```solidity
function changeFeeAddr(address _newFeeAddr) external
```

Changes the fee address

_Only callable by the current owner_

### getLiquidationPriceCollateral

```solidity
function getLiquidationPriceCollateral(uint256 _collateral, uint256 _amountFor, uint8 _amountForId, uint256 _liquidationLimit) public view returns (uint256)
```

Calculates the liquidation price of the collateral token

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | liquidationPrice Price of the collateral token at which a liquidation will be possible |

### getLiquidationPriceAmountFor

```solidity
function getLiquidationPriceAmountFor(uint256 _collateral, uint256 _amountFor, uint8 _collateralId, uint256 _liquidationLimit) public view returns (uint256)
```

Calculates the liquidation price of the debt token

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | liquidationPrice Price of the debt token at which a liquidation will be possible |

### transferAcceptSale

```solidity
function transferAcceptSale(address _sender, uint256 _collateral, uint8 _collateralId, uint256 _amount, uint8 _amountId) internal
```

Handles the transfer of the collateral, fee, and amount bought

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _sender | address | Address sending the tokens |
| _collateral | uint256 | Collateral amount to transfer from the sender |
| _collateralId | uint8 | Id of the collateral token |
| _amount | uint256 | Amount bought by the sender |
| _amountId | uint8 | Id of the bought token |

### transferBuyerToSeller

```solidity
function transferBuyerToSeller(address _sender, address _receiver, uint256 _amount, uint8 _amountId) internal
```

Transfers token from the buyer to the seller of an offer
@ Only callable internally by this contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _sender | address | Address sending the tokens |
| _receiver | address | Address receiving the tokens |
| _amount | uint256 | Amount to send |
| _amountId | uint8 | Id of the amount to send |

### getCollateral

```solidity
function getCollateral(uint256 _amount, uint8 _amountId, uint8 _collateralId, uint256 _collateralToDebtRatio) public view returns (uint256)
```

Calculates the collateral needed to create a buy offer or accept a sale offer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount on which the collateral will be calculated |
| _amountId | uint8 | Id of the amount |
| _collateralId | uint8 | Id of the collateral |
| _collateralToDebtRatio | uint256 | Collateral to debt ratio, used to calculate the collateral amount. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | collateral Computed collateral amount |

### getRatio

```solidity
function getRatio(uint256 _amount, uint256 _collateral, uint8 _amountId, uint8 _collateralId) public view returns (uint256)
```

Calculates the ratio of the collateral over the debt

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount of debt |
| _collateral | uint256 | Collateral amount |
| _amountId | uint8 | Id of the debt amount |
| _collateralId | uint8 | Id of the collateral |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | ratio Calculated ratio |

### canLiquidate

```solidity
function canLiquidate(uint256 _amount, uint8 _amountId, uint256 _collateral, uint8 _collateralId, uint256 _liquidationLimitRatio) public view returns (bool)
```

Determines if the collateral to debt ratio has reached the liquidation limit

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount of debt |
| _amountId | uint8 | Id of the debt amount |
| _collateral | uint256 | Collateral amount |
| _collateralId | uint8 | Id of the collateral |
| _liquidationLimitRatio | uint256 | Ratio at which liquidation will be possible |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the offer can be liquidated or not |

### canLiquidateTimeOver

```solidity
function canLiquidateTimeOver(uint256 _timeAccepted, uint256 _repayInSec) public view returns (bool)
```

Determines if the repayment period has passed

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _timeAccepted | uint256 | Time at which the offer was accepted |
| _repayInSec | uint256 | Repayment period of the offer |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool If the offer can be liquidated or not |

### liquidateAssets

```solidity
function liquidateAssets(uint256 _amount, uint8 _amountId, uint256 _collateral, uint8 _collateralId, address _seller, address _buyer, address _sender, uint256 _liquidationLossRatio) internal
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount of debt |
| _amountId | uint8 | Id of the debt amount |
| _collateral | uint256 | Amount of collateral |
| _collateralId | uint8 | Id of the collateral |
| _seller | address | Address of the offer's seller |
| _buyer | address | Address of the offer's buyer |
| _sender | address | Address of the liquidator |
| _liquidationLossRatio | uint256 | Ratio at which a liquidation will incur a loss (i.e., the collateral value is below the debt) |

### liquidateAssetsBySeller

```solidity
function liquidateAssetsBySeller(uint256 _amount, uint8 _amountId, uint256 _collateral, uint8 _collateralId, address _buyer, address _seller, uint256 _liquidationLossRatio) internal
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount of debt |
| _amountId | uint8 | Id of the debt amount |
| _collateral | uint256 | Amount of collateral |
| _collateralId | uint8 | Id of the collateral |
| _buyer | address | Address of the buyer |
| _seller | address | Address of the seller |
| _liquidationLossRatio | uint256 | Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value) |

### liquidateAssetsByBuyer

```solidity
function liquidateAssetsByBuyer(uint256 _amount, uint8 _amountId, uint256 _collateral, uint8 _collateralId, address _buyer, address _seller, uint256 _liquidationLossRatio) internal
```

Liquidates an offer when the liquidator is the buyer

_Only callable internally by this contract, reverts if it incurs a loss to the seller._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount of debt |
| _amountId | uint8 | Id of the debt amount |
| _collateral | uint256 | Amount of collateral |
| _collateralId | uint8 | Id of the collateral |
| _buyer | address | Address of the buyer |
| _seller | address | Address of the seller |
| _liquidationLossRatio | uint256 | Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value) |

### repay

```solidity
function repay(uint256 _toRepay, uint8 _toRepayId, uint256 _collateral, uint8 _collateralId, address _seller, address _buyer) internal
```

Repays a debt, and transfers back the collateral.

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _toRepay | uint256 | Amount to repay |
| _toRepayId | uint8 | Id of the amount to repay |
| _collateral | uint256 | Amount of collateral |
| _collateralId | uint8 | Id of the collateral |
| _seller | address | Address of the seller |
| _buyer | address | Address of the buyer |

### transferFee

```solidity
function transferFee(uint256 _amount, uint8 _amountId, address _sender) internal
```

Transfers the fee from the sender to the fee address

_Only callable internally by this contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount on which 0.5% will be taken |
| _amountId | uint8 | Id of the amount |
| _sender | address | Address of the sender |

### checkIsPositive

```solidity
function checkIsPositive(uint256 _amount) internal pure
```

Checks if amount is positive, reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Amount to check |

### checkTokenId

```solidity
function checkTokenId(uint256 _id) internal view
```

Checks if id is in the range of tradable tokens

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint256 | Id of the token |

### checkIsSameId

```solidity
function checkIsSameId(uint8 _id, uint8 __id) internal pure
```

Checks if id of two tokens are the same, reverts if true

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint8 | Id of first token |
| __id | uint8 | id of second token |

### checkOfferIsOpen

```solidity
function checkOfferIsOpen(enum SpectrrData.OfferState _offerState) internal pure
```

Checks if offer is open (i.e. not accepted or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerState | enum SpectrrData.OfferState | Current state of the offer |

### checkOfferIsAccepted

```solidity
function checkOfferIsAccepted(enum SpectrrData.OfferState _offerState) internal pure
```

Checks if offer is accepted (i.e. not open or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerState | enum SpectrrData.OfferState | Current state of the offer |

### checkOfferIsClosed

```solidity
function checkOfferIsClosed(enum SpectrrData.OfferState _offerState) internal pure
```

Checks if offer is closed (i.e. not open or closed), reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _offerState | enum SpectrrData.OfferState | Current state of the offer |

### checkNotSender

```solidity
function checkNotSender(address _addr) internal view
```

Checks if address matches with sender of transaction, reverts if true

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _addr | address | Address to compare with msg.sender |

### checkSender

```solidity
function checkSender(address _addr) internal view
```

Checks if address matches with sender of transaction, reverts if false

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _addr | address | Address to compare with msg.snder |

### checkIsLessThan

```solidity
function checkIsLessThan(uint256 _amount, uint256 _debt) internal pure
```

Checks if amount sent is bigger than debt, reverts if true

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | The amount to sender |
| _debt | uint256 | The debt owed |

