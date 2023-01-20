// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SpectrrUtils.sol";

/// @title SpectrrCore
/// @author Supergrayfly
/** @notice This contract is a lending and borrowing like platform;
    'like', because it is not interest based like other existing lending dApps.
    Users can post offers specifying a token they want to sell/buy,
    a collateral token (for buy offers), and a repayment period.
    This contract does not allow selling/buying a token for the same token. 
    Also, the collateral token chosen in a buy offer can not be the same than the repayment token.
    For example, one could make the following buy offer:
        Buy 1 BTC for 69,000$ (assuming a current BTC price of 68,500$), pledge 1.8 times the repayment amount in collateral (here, 1.8 BTC), 
        and specify a repayment period of 69 days. After that, let us say that that someone accepts the offer by sending 1 BTC to the buyer.
        Assuming that the price of BTC reaches 70,000$ when the debt is repaid,
        the buyer would then make a profit of 70,000$ - 69,000$ = 1000$, after selling the 1 BTC bought earlier.
        On the other hand, the seller will receive 69,000$, and would have made a profit of 69,000$ - 68,500$ = 500$.
        It can be noted that in our case, the seller would have made more profit holding the BTC.
*/
/** @custom:extra The contract was voluntarily made this way in order for it to align with the principles of Islamic finance.
    In the latter, some prohibitions include dealing with interest, 
    activities related to prohibited things (interest, gambling, stealing), 
    and selling an asset for the same exact asset plus an extra amount (interest).

    Some Useful links:
    https://www.investopedia.com/articles/07/islamic_investing.asp
    https://www.gfmag.com/topics/blogs/what-products-does-islamic-finance-offer  
*/
contract SpectrrCore is SpectrrUtils, EIP712, ReentrancyGuard {
    /// @dev EIP712 Constructor
    /// @dev EIP712's params are the name and version of the contract
    constructor() EIP712("Spectrr Finance", "ver. 0.0.1") {}

    /// @notice Creates and posts a sale offer
    /// @param _selling Amount the sender is selling
    /// @param _sellingId Id of the selling token, can not be same than id of sell for token.
    /// @param _exRate Exchange rate between the selling amount sell for amount
    /// @param _sellForId Id of the token exchanged for, can not be same than id of the selling token.
    /** @param _repayInSec Repayment period in unix seconds,
        a value of 0 will allow an unlimited repayment time .
    */
    /// @return uint256 Id of the offer created
    function createSaleOffer(
        uint256 _selling,
        uint8 _sellingId,
        uint256 _exRate,
        uint8 _sellForId,
        uint256 _repayInSec
    ) external nonReentrant returns (uint256) {
        checkIsPositive(_selling);
        checkIsPositive(_exRate);
        checkTokenId(_sellingId);
        checkTokenId(_sellForId);
        checkIsSameId(_sellForId, _sellingId);

        transferSenderToContract(msg.sender, _selling, _sellingId);

        uint256 id = ++saleOffersCount;
        uint256 sellFor = (_exRate * _selling) / 10 ** 18;

        SaleOffer memory offer = SaleOffer(
            OfferState.open,
            OfferLockState.unlocked,
            id,
            _selling,
            sellFor,
            0,
            _repayInSec,
            0,
            _sellingId,
            _sellForId,
            0,
            msg.sender,
            address(0)
        );

        saleOffers[id] = offer;

        emit SaleOfferCreated(
            id,
            _selling,
            _sellingId,
            sellFor,
            _sellForId,
            _exRate,
            _repayInSec,
            msg.sender,
            block.timestamp
        );

        return id;
    }

    /// @notice Accepts a sale offer by transferring the required collateral from the buyer to the contract
    /// @notice There is a 0.1% fee of the selling amount, paid by the buyer to the fee address.
    /// @param _offerId Id of the sale offer to accept
    /** @param _collateralId Id of the token to be pledged as collateral,
        cannot be same than id of selling token.
    */
    function acceptSaleOffer(
        uint256 _offerId,
        uint8 _collateralId
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsOpen(saleOffers[_offerId].offerState);
        checkNotSender(saleOffers[_offerId].seller);
        checkIsSameId(_collateralId, saleOffers[_offerId].sellingId);

        uint256 collateral = getCollateral(
            saleOffers[_offerId].sellFor,
            saleOffers[_offerId].sellForId,
            _collateralId,
            RATIO_COLLATERAL_TO_DEBT
        );

        transferAcceptSale(
            msg.sender,
            collateral,
            _collateralId,
            saleOffers[_offerId].selling,
            saleOffers[_offerId].sellingId
        );

        saleOffers[_offerId].timeAccepted = block.timestamp;
        saleOffers[_offerId].offerState = OfferState.accepted;
        saleOffers[_offerId].collateral = collateral;
        saleOffers[_offerId].collateralId = _collateralId;
        saleOffers[_offerId].buyer = msg.sender;

        emit SaleOfferAccepted(
            _offerId,
            collateral,
            _collateralId,
            msg.sender,
            block.timestamp
        );
    }

    /// @notice Cancels a sale offer, given that it is not accepted yet
    /// @param _offerId Id of the sale offer to cancel
    function cancelSaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsOpen(saleOffers[_offerId].offerState);
        checkSender(saleOffers[_offerId].seller);

        transferContractToSender(
            msg.sender,
            saleOffers[_offerId].selling,
            saleOffers[_offerId].sellingId
        );

        saleOffers[_offerId].offerState = OfferState.closed;

        emit SaleOfferCanceled(_offerId, block.timestamp);
    }

    /// @notice Adds collateral to a sale offer
    /// @dev Can only be called by the buyer of the sale offer
    /// @param _offerId Id of the sale offer to add collateral to
    /// @param _amount Amount of collateral to add
    function addCollateralSaleOffer(
        uint256 _offerId,
        uint256 _amount
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkIsPositive(_amount);
        checkOfferIsAccepted(saleOffers[_offerId].offerState);
        checkSender(saleOffers[_offerId].buyer);

        uint8 collateralId = saleOffers[_offerId].collateralId;

        transferSenderToContract(msg.sender, _amount, collateralId);

        saleOffers[_offerId].collateral += _amount;

        emit SaleOfferCollateralAdded(
            _offerId,
            _amount,
            collateralId,
            block.timestamp
        );
    }

    /// @notice Fully repays the debt of a sale offer
    /// @param _offerId Id of the sale offer to repay
    function repaySaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsAccepted(saleOffers[_offerId].offerState);

        address buyer = saleOffers[_offerId].buyer;

        checkSender(buyer);

        address seller = saleOffers[_offerId].seller;
        uint256 toRepay = saleOffers[_offerId].sellFor;
        uint256 collateral = saleOffers[_offerId].collateral;
        uint8 toRepayId = saleOffers[_offerId].sellForId;
        uint8 collateralId = saleOffers[_offerId].collateralId;

        repay(toRepay, toRepayId, collateral, collateralId, seller, buyer);

        saleOffers[_offerId].offerState = OfferState.closed;

        emit SaleOfferRepaid(
            _offerId,
            toRepay,
            toRepayId,
            false,
            block.timestamp
        );
    }

    /// @notice Partially repays the debt of a sale offer
    /// @param _offerId Id of the sale offer to partially repay
    /// @param _amount Amount to partially repay
    function repaySaleOfferPart(
        uint256 _offerId,
        uint256 _amount
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkIsPositive(_amount);
        checkIsLessThan(_amount, saleOffers[_offerId].sellFor);
        checkOfferIsAccepted(saleOffers[_offerId].offerState);
        checkSender(saleOffers[_offerId].buyer);

        uint256 toRepay = _amount;
        uint8 toRepayId = saleOffers[_offerId].sellForId;
        address seller = saleOffers[_offerId].seller;

        transferBuyerToSeller(msg.sender, seller, toRepay, toRepayId);

        saleOffers[_offerId].sellFor -= toRepay;

        emit SaleOfferRepaid(
            _offerId,
            toRepay,
            toRepayId,
            true,
            block.timestamp
        );
    }

    /// @notice Liquidates a sale offer by repaying the debt, and then receiving the pledged collateral.
    /// @notice An offer can be liquidated if and only if the collateral to debt ratio falls below the MIN_RATIO_LIQUIDATION value previously defined (1.8).
    /** @custom:warning Liquidating an offer may incur losses.
        For instance, say that the $ value of the collateral drops below the $ value of the debt,
        if the liquidator proceeds with the liquidation, he/she will have lost a negative amount of: collateral (in $) - debt (in $).
        It is therefore recommended to verify beforehand if the transaction is profitable or not. 
        This can be done using the isLiquidationLoss function, or anny other external method.
    */
    /// @param _offerId Id of the sale offer to liquidate
    function liquidateSaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsAccepted(saleOffers[_offerId].offerState);

        uint256 amount = saleOffers[_offerId].sellFor;
        uint256 collateral = saleOffers[_offerId].collateral;
        uint8 amountId = saleOffers[_offerId].sellForId;
        uint8 collateralId = saleOffers[_offerId].collateralId;
        address seller = saleOffers[_offerId].seller;
        address buyer = saleOffers[_offerId].buyer;

        require(
            canLiquidate(
                amount,
                amountId,
                collateral,
                collateralId,
                MIN_RATIO_LIQUIDATION
            ) ||
                canLiquidateTimeOver(
                    saleOffers[_offerId].timeAccepted,
                    saleOffers[_offerId].repayInSec
                ),
            "Can not be liquidated...yet"
        );

        if (msg.sender == seller) {
            liquidateAssetsBySeller(
                amount,
                amountId,
                collateral,
                collateralId,
                buyer,
                seller,
                RATIO_LIQUIDATION_IS_LOSS
            );
        } else {
            liquidateAssets(
                amount,
                amountId,
                collateral,
                collateralId,
                seller,
                buyer,
                msg.sender,
                RATIO_LIQUIDATION_IS_LOSS
            );
        }

        saleOffers[_offerId].offerState = OfferState.closed;

        emit SaleOfferLiquidated(_offerId, msg.sender, block.timestamp);
    }

    /// @notice Forfeits a sale offer
    /// @dev Only callable by the buyer
    /// @dev Transaction is reverted if it incurs a loss to the seller
    /// @param _offerId Id of the sale offer to forfeit
    function forfeitSaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsAccepted(saleOffers[_offerId].offerState);

        address buyer = saleOffers[_offerId].buyer;

        checkSender(buyer);

        uint256 amount = saleOffers[_offerId].sellFor;
        uint256 collateral = saleOffers[_offerId].collateral;
        uint8 amountId = saleOffers[_offerId].sellForId;
        uint8 collateralId = saleOffers[_offerId].collateralId;
        address seller = saleOffers[_offerId].seller;

        liquidateAssetsByBuyer(
            amount,
            amountId,
            collateral,
            collateralId,
            buyer,
            seller,
            RATIO_LIQUIDATION_IS_LOSS
        );

        saleOffers[_offerId].offerState = OfferState.closed;

        emit SaleOfferForfeited(_offerId, block.timestamp);
    }

    /// @notice Creates and posts a buy offer
    /// @param _buying Amount to buy
    /// @param _buyingId Id of the buying token
    /// @param _exRate Exchange rate between buying amount and buy for amount
    /** @param _buyForId Id of the repayment token,
        can not be same than id of token buying.
    */
    /** @param _collateralId Id of the collateral token,
        cannot be same than id of buying token.
    */
    /** @param _repayInSec Repayment timeframe in unix seconds,
        a value of 0 will allow an unlimited repayment time .
    */
    function createBuyOffer(
        uint256 _buying,
        uint8 _buyingId,
        uint256 _exRate,
        uint8 _buyForId,
        uint8 _collateralId,
        uint256 _repayInSec
    ) external nonReentrant returns (uint256) {
        checkIsPositive(_buying);
        checkIsPositive(_exRate);
        checkTokenId(_buyingId);
        checkTokenId(_buyForId);
        checkIsSameId(_buyingId, _buyForId);
        checkIsSameId(_collateralId, _buyingId);

        uint256 buyFor = (_exRate * _buying) / 10 ** 18;
        uint256 collateral = getCollateral(
            buyFor,
            _buyForId,
            _collateralId,
            RATIO_COLLATERAL_TO_DEBT
        );

        transferSenderToContract(msg.sender, collateral, _collateralId);

        uint256 id = ++buyOffersCount;

        BuyOffer memory offer = BuyOffer(
            OfferState.open,
            OfferLockState.unlocked,
            id,
            _buying,
            buyFor,
            collateral,
            _repayInSec,
            0,
            _buyingId,
            _buyForId,
            _collateralId,
            msg.sender,
            address(0)
        );

        buyOffers[id] = offer;

        emit BuyOfferCreated(
            id,
            _buying,
            _buyingId,
            buyOffers[id].buyFor,
            _buyForId,
            _exRate,
            _collateralId,
            _repayInSec,
            msg.sender,
            block.timestamp
        );

        return id;
    }

    /// @notice Accepts a buy offer by transferring the amount buying from the seller to the buyer
    /// @notice There is a 0.1% fee of the buying amount, paid by the seller.
    /// @param _offerId Id of the buy offer to accept
    function acceptBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkOfferIsOpen(buyOffers[_offerId].offerState);
        checkNotSender(buyOffers[_offerId].buyer);

        transferBuyerToSeller(
            msg.sender,
            buyOffers[_offerId].buyer,
            buyOffers[_offerId].buying,
            buyOffers[_offerId].buyingId
        );

        transferFee(
            buyOffers[_offerId].buying,
            buyOffers[_offerId].buyingId,
            msg.sender
        );

        buyOffers[_offerId].timeAccepted = block.timestamp;
        buyOffers[_offerId].offerState = OfferState.accepted;
        buyOffers[_offerId].seller = msg.sender;

        emit BuyOfferAccepted(_offerId, msg.sender, block.timestamp);
    }

    /// @notice Cancels a buy offer, given that it not accepted yet
    /// @param _offerId Id of the buy offer to cancel
    function cancelBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkOfferIsOpen(buyOffers[_offerId].offerState);
        checkSender(buyOffers[_offerId].buyer);

        transferContractToSender(
            msg.sender,
            buyOffers[_offerId].collateral,
            buyOffers[_offerId].collateralId
        );

        buyOffers[_offerId].offerState = OfferState.closed;

        emit BuyOfferCanceled(_offerId, block.timestamp);
    }

    /// @notice Adds collateral to a buy offer
    /// @dev Can only be called by the buyer of the buy offer
    /// @param _offerId Id of the buy offer to add collateral to
    /// @param _amount The amount of collateral to add
    function addCollateralBuyOffer(
        uint256 _offerId,
        uint256 _amount
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkIsPositive(_amount);
        checkOfferIsAccepted(buyOffers[_offerId].offerState);
        checkSender(buyOffers[_offerId].buyer);

        uint8 collateralId = buyOffers[_offerId].collateralId;

        transferSenderToContract(msg.sender, _amount, collateralId);

        buyOffers[_offerId].collateral += _amount;

        emit BuyOfferCollateralAdded(
            _offerId,
            _amount,
            collateralId,
            block.timestamp
        );
    }

    /// @notice Fully repays the debt of the buy offer
    /// @param _offerId Id of the buy offer to repay
    function repayBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkOfferIsAccepted(buyOffers[_offerId].offerState);

        address buyer = buyOffers[_offerId].buyer;

        checkSender(buyer);

        address seller = buyOffers[_offerId].seller;
        uint256 toRepay = buyOffers[_offerId].buyFor;
        uint256 collateral = buyOffers[_offerId].collateral;
        uint8 toRepayId = buyOffers[_offerId].buyForId;
        uint8 collateralId = buyOffers[_offerId].collateralId;

        repay(toRepay, toRepayId, collateral, collateralId, seller, buyer);

        buyOffers[_offerId].offerState = OfferState.closed;

        emit BuyOfferRepaid(
            _offerId,
            toRepay,
            toRepayId,
            false,
            block.timestamp
        );
    }

    /// @notice Partially repays the debt of a buy offer
    /// @param _offerId Id of the buy offer to partially repay
    /// @param _amount Amount to partially repay
    function repayBuyOfferPart(
        uint256 _offerId,
        uint256 _amount
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkIsPositive(_amount);
        checkIsLessThan(_amount, buyOffers[_offerId].buyFor);
        checkOfferIsAccepted(buyOffers[_offerId].offerState);
        checkSender(buyOffers[_offerId].buyer);

        uint256 toRepay = _amount;
        uint8 toRepayId = buyOffers[_offerId].buyForId;
        address seller = buyOffers[_offerId].seller;

        transferBuyerToSeller(msg.sender, seller, toRepay, toRepayId);

        buyOffers[_offerId].buyFor -= toRepay;

        emit BuyOfferRepaid(
            _offerId,
            toRepay,
            toRepayId,
            true,
            block.timestamp
        );
    }

    /// @notice Liquidates a buy offer, by repaying the debt, and then receiving the pledged collateral.
    /// @notice An offer can be liquidated if and only if the collateral to debt ratio falls below the MIN_RATIO_LIQUIDATION value previously defined.
    /** @custom:warning Liquidating an offer may incur losses.
        For instance, say that the $ value of the collateral drops below the $ value of the debt,
        if the liquidator proceeds with the liquidation, he/she will have lost a negative amount of collateral (in $) - debt (in $).
        It is therefore recommended to verify beforehand if the transaction is profitable or not. 
        This can be done using the isLiquidationLoss function, or anny other external method.
    */
    /// @param _offerId Id of the buy offer to liquidate
    function liquidateBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkOfferIsAccepted(buyOffers[_offerId].offerState);

        uint256 amount = buyOffers[_offerId].buyFor;
        uint256 collateral = buyOffers[_offerId].collateral;
        uint8 amountId = buyOffers[_offerId].buyForId;
        uint8 collateralId = buyOffers[_offerId].collateralId;
        address seller = buyOffers[_offerId].seller;
        address buyer = buyOffers[_offerId].buyer;

        require(
            canLiquidate(
                amount,
                amountId,
                collateral,
                collateralId,
                MIN_RATIO_LIQUIDATION
            ) ||
                canLiquidateTimeOver(
                    buyOffers[_offerId].timeAccepted,
                    buyOffers[_offerId].repayInSec
                ),
            "Can not be liquidated...yet"
        );

        if (msg.sender == seller) {
            liquidateAssetsBySeller(
                amount,
                amountId,
                collateral,
                collateralId,
                buyer,
                seller,
                RATIO_LIQUIDATION_IS_LOSS
            );
        } else {
            liquidateAssets(
                amount,
                amountId,
                collateral,
                collateralId,
                seller,
                buyer,
                msg.sender,
                RATIO_LIQUIDATION_IS_LOSS
            );
        }

        buyOffers[_offerId].offerState = OfferState.closed;

        emit BuyOfferLiquidated(_offerId, msg.sender, block.timestamp);
    }

    /// @notice Forfeits a buy offer
    /// @dev Only callable by the buyer
    /// @dev Transaction is reverted if it incurs a loss to the seller
    /// @param _offerId Id of the buy offer to forfeit
    function forfeitBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        checkOfferIsAccepted(buyOffers[_offerId].offerState);
        checkNotSender(buyOffers[_offerId].buyer);

        uint256 amount = buyOffers[_offerId].buyFor;
        uint256 collateral = buyOffers[_offerId].collateral;
        uint8 amountId = buyOffers[_offerId].buyForId;
        uint8 collateralId = buyOffers[_offerId].collateralId;
        address seller = buyOffers[_offerId].seller;
        address buyer = buyOffers[_offerId].buyer;

        if (
            !canLiquidate(
                amount,
                amountId,
                collateral,
                collateralId,
                MIN_RATIO_LIQUIDATION
            )
        ) {
            liquidateAssetsByBuyer(
                amount,
                amountId,
                collateral,
                collateralId,
                buyer,
                seller,
                RATIO_LIQUIDATION_IS_LOSS
            );
        } else {
            revert("Sender can be liquidated");
        }

        buyOffers[_offerId].offerState = OfferState.closed;

        emit BuyOfferForfeited(_offerId, block.timestamp);
    }

    /// @notice Changes the seller or buyer's address of an offer
    /** @dev It should be noted that a contract address could be entered in the _newAddr field.
        However, doing so would not affect the contract's mechanism in a bad way.
        The only consequence would be that the msg.sender will relinquish control of the funds placed in the contract.
    */
    /// @param _offerId Id of the offer we want to change addresses
    /// @param _newAddr New address to replace the old one with
    /// @param _addrType Type of address: 0 for seller address, and 1 for buyer address.
    function changeAddrSale(
        uint256 _offerId,
        address _newAddr,
        uint8 _addrType
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsAccepted(saleOffers[_offerId].offerState);
        checkOfferIsOpen(saleOffers[_offerId].offerState);

        if (_addrType == 0) {
            require(
                saleOffers[_offerId].seller == msg.sender,
                "Sender is not seller"
            );
            require(_newAddr != address(0), "Address is null address");
            saleOffers[_offerId].seller = _newAddr;
        } else if (_addrType == 1) {
            require(
                saleOffers[_offerId].buyer == msg.sender,
                "Sender is not buyer"
            );
            require(_newAddr != address(0), "Address is null address");
            saleOffers[_offerId].buyer = _newAddr;
        } else {
            revert("Invalid Address Type");
        }
    }

    /// @notice Changes the seller or buyer's address of an offer
    /** @dev It should be noted that a contract address could be entered in the _newAddr field.
        However, doing so would not affect the contract's mechanism in a bad way.
        The only consequence would be that the msg.sender will relinquish control
        of the funds placed in the contract to the other contract address.
    */
    /// @param _offerId Id of the offer we want to change addresses
    /// @param _newAddr New address to replace the old one with
    /// @param _addrType Type of address: 0 for seller address, and 1 for buyer address.
    function changeAddrBuy(
        uint256 _offerId,
        address _newAddr,
        uint8 _addrType
    ) external nonReentrant lockSaleOffer(_offerId) {
        if (_addrType == 1) {
            require(
                buyOffers[_offerId].seller == msg.sender,
                "Sender is not seller"
            );
            require(_newAddr != address(0), "Address is null address");
            buyOffers[_offerId].seller = _newAddr;
        } else if (_addrType == 2) {
            require(
                buyOffers[_offerId].buyer == msg.sender,
                "Sender is not buyer"
            );
            require(_newAddr != address(0), "Address is null address");
            buyOffers[_offerId].buyer = _newAddr;
        } else {
            revert("Invalid Address Type");
        }
    }

    /// @notice Gets the collateral to debt ratio, debt amount, debt amount id, collateral id, and buyer's address of an offer.
    /// @param _offerId Id of the offer we want to get info on
    /// @param _offerType Type of offer: 1 for sale offer and 2 for buy offer.
    /// @return uint256 Collateral to debt ratio
    /// @return uint256 Debt amount
    /// @return uint8 Id of the debt token
    /// @return uint8 Id of the collateral
    /// @return address Address of the buyer
    function getRatioInfo(
        uint256 _offerId,
        uint8 _offerType
    )
        external
        view
        returns (
            uint256, // ratio
            uint256, // debt
            uint8, // debt Id
            uint8, // collateral id
            address // address buyer
        )
    {
        if (_offerType == 1) {
            return (
                getRatio(
                    saleOffers[_offerId].sellFor,
                    saleOffers[_offerId].collateral,
                    saleOffers[_offerId].sellForId,
                    saleOffers[_offerId].collateralId
                ),
                saleOffers[_offerId].sellFor,
                saleOffers[_offerId].sellForId,
                saleOffers[_offerId].collateralId,
                saleOffers[_offerId].buyer
            );
        } else if (_offerType == 2) {
            return (
                getRatio(
                    buyOffers[_offerId].buyFor,
                    buyOffers[_offerId].collateral,
                    buyOffers[_offerId].buyForId,
                    buyOffers[_offerId].collateralId
                ),
                buyOffers[_offerId].buyFor,
                buyOffers[_offerId].buyForId,
                buyOffers[_offerId].collateralId,
                buyOffers[_offerId].buyer
            );
        } else {
            revert("Invalid offer type");
        }
    }

    /// @notice Checks if an offer can be liquidated
    /// @param _offerId Id of the offer we want to check
    /// @param _offerType Type of offer: 1 for sale offer and 2 for buy offer.
    /// @return bool If the offer can be liquidated or not
    function canLiquidate(
        uint256 _offerId,
        uint8 _offerType
    ) external view returns (bool) {
        if (_offerType == 1) {
            if (
                canLiquidate(
                    saleOffers[_offerId].sellFor,
                    saleOffers[_offerId].sellForId,
                    saleOffers[_offerId].collateral,
                    saleOffers[_offerId].collateralId,
                    MIN_RATIO_LIQUIDATION
                ) ||
                canLiquidateTimeOver(
                    saleOffers[_offerId].timeAccepted,
                    saleOffers[_offerId].repayInSec
                )
            ) {
                return true;
            } else {
                return false;
            }
        } else if (_offerType == 2) {
            if (
                canLiquidate(
                    buyOffers[_offerId].buyFor,
                    buyOffers[_offerId].buyForId,
                    buyOffers[_offerId].collateral,
                    buyOffers[_offerId].collateralId,
                    MIN_RATIO_LIQUIDATION
                ) ||
                canLiquidateTimeOver(
                    buyOffers[_offerId].timeAccepted,
                    buyOffers[_offerId].repayInSec
                )
            ) {
                return true;
            } else {
                return false;
            }
        } else {
            revert("Invalid offer type");
        }
    }

    /// @notice Determines if a liquidation will incur a loss
    /// @param _offerId Id of the offer we want to check
    /// @param _offerType Type of offer: 1 for sale offer and 2 for buy offer.
    /// @return bool If the liquidation will incur a loss or not
    function isLiquidationLoss(
        uint256 _offerId,
        uint8 _offerType
    ) external view returns (bool) {
        if (
            _offerType == 1 &&
            saleOffers[_offerId].offerState == OfferState.accepted
        ) {
            if (
                getRatio(
                    saleOffers[_offerId].sellFor,
                    saleOffers[_offerId].collateral,
                    saleOffers[_offerId].sellForId,
                    saleOffers[_offerId].collateralId
                ) >= RATIO_LIQUIDATION_IS_LOSS
            ) {
                return false;
            } else {
                return true;
            }
        } else if (
            _offerType == 2 &&
            buyOffers[_offerId].offerState == OfferState.accepted
        ) {
            if (
                getRatio(
                    buyOffers[_offerId].buyFor,
                    buyOffers[_offerId].collateral,
                    buyOffers[_offerId].buyForId,
                    buyOffers[_offerId].collateralId
                ) >= RATIO_LIQUIDATION_IS_LOSS
            ) {
                return false;
            } else {
                return true;
            }
        } else {
            revert("Invalid offer type");
        }
    }

    /// @notice Gets the liquidation price of the collateral token
    /// @param _offerId Id of the offer we want the liquidation price
    /// @param _offerType Type of offer: 1 for sale offer and 2 for buy offer.
    /// @return uint256 The liquidation price of the collateral token
    function getLiquidationPriceCollateral(
        uint256 _offerId,
        uint8 _offerType
    ) external view returns (uint256) {
        if (_offerType == 1) {
            uint256 price = getLiquidationPriceCollateral(
                saleOffers[_offerId].collateral,
                saleOffers[_offerId].sellFor,
                saleOffers[_offerId].sellForId,
                MIN_RATIO_LIQUIDATION
            );

            return price;
        } else if (_offerType == 2) {
            uint256 price = getLiquidationPriceCollateral(
                buyOffers[_offerId].collateral,
                buyOffers[_offerId].buyFor,
                buyOffers[_offerId].buyForId,
                MIN_RATIO_LIQUIDATION
            );

            return price;
        } else {
            revert("Invalid offer type");
        }
    }

    /// @notice Gets the liquidation price of the debt token
    /// @param _offerId Id of the offer we want the liquidation price
    /// @param _offerType Type of offer: 1 for sale offer and 2 for buy offer.
    /// @return uint256 The liquidation price of the debt token
    function getLiquidationPriceAmountFor(
        uint256 _offerId,
        uint8 _offerType
    ) external view returns (uint256) {
        if (_offerType == 1) {
            uint256 price = getLiquidationPriceAmountFor(
                saleOffers[_offerId].collateral,
                saleOffers[_offerId].sellFor,
                saleOffers[_offerId].collateralId,
                MIN_RATIO_LIQUIDATION
            );

            return price;
        } else if (_offerType == 2) {
            uint256 price = getLiquidationPriceAmountFor(
                buyOffers[_offerId].collateral,
                buyOffers[_offerId].buyFor,
                buyOffers[_offerId].collateralId,
                MIN_RATIO_LIQUIDATION
            );

            return price;
        } else {
            revert("Invalid offer type");
        }
    }
}
