// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.8.7 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SpectrrUtils.sol";

/// @title SpectrrFi
/// @author Supergrayfly
/** @notice This contract is a lending and borrowing like platform;
    'like', because it is not interest based like other existing lending dApps.
    Users can post offers specifying a token they want to sell/buy,
    a collateral token (for buy offers), and a repayment period.
    This contract does not allow selling/buying a token for the same token. 
    Also, the collateral token chosen in a buy offer can not be the same than the repayment token.
    For example, one could make the following buy offer:
        Buy 1 BTC for 69,000$ (assuming a current BTC price of 68,500$), pledge 1.5 times the repayment amount in collateral (here, 1.5 BTC), 
        and specify a repayment period of 69 days. After that, let us say that that someone accepts the offer by sending 1 BTC to the buyer.
        Assuming that the price of BTC reaches 70,000$ when the debt is repaid,
        the buyer would then make a profit of 70,000$ - 69,000$ = 1000$, after selling the 1 BTC bought earlier.
        On the other hand, the seller will receive 69,000$, and would have made a profit of 69,000$ - 68,500$ = 500$.
        It can be noted that in our case, the seller would have made more profit just holding the BTC.
*/
/** @custom:extra This contract was voluntarily made this way in order for it to align with the principles of Islamic finance.
    In the latter, some prohibitions include dealing with interest, 
    activities related to prohibited things (e.g.: gambling & stealing), 
    and selling an asset for the same exact asset plus an extra amount (interest).

    Some Useful links:
    https://www.investopedia.com/articles/07/islamic_investing.asp
    https://www.gfmag.com/topics/blogs/what-products-does-islamic-finance-offer  
*/
contract SpectrrFi is SpectrrUtils, EIP712, ReentrancyGuard {
    /// @dev EIP712 Constructor
    /// @dev EIP712's params are the name and version of the contract
    constructor() EIP712("Spectrr Finance", "ver. 2.0.0") {}

    /// @notice Creates and posts a sale offer
    /// @notice There is a 0.1% fee of the selling amount, paid by the seller to the fee address.
    /// @param _sellingTokenAmount Amount the sender is selling
    /// @param _sellingTokenId Id of the selling token, can not be same than id of sell for token.
    /// @param _exchangeRate Exchange rate between the selling amount sell for amount
    /// @param _sellingForTokenId Id of the token exchanged for, can not be same than id of the selling token.
    /// @param _repayInSeconds Repayment period in unix seconds, a value of 0 will allow an unlimited repayment time .
    /// @return uint256 Id of the offer created
    function createSaleOffer(
        uint256 _sellingTokenAmount,
        uint8 _sellingTokenId,
        uint256 _exchangeRate,
        uint8 _sellingForTokenId,
        uint256 _repayInSeconds,
        uint256 _collateralToDebtRatio,
        uint256 _liquidationRatio
    ) external nonReentrant returns (uint256) {
        checkIsPositive(_sellingTokenAmount);
        checkIsPositive(_exchangeRate);
        checkTokensIdNotSame(_sellingForTokenId, _sellingTokenId);
        checkMinRatio(_collateralToDebtRatio);
        checkMinRatio(_liquidationRatio);
        checkIsLessThan(_liquidationRatio, _collateralToDebtRatio);

        transferSenderToContract(
            msg.sender,
            _sellingTokenAmount,
            _sellingTokenId
        );

        transferFee(
            _sellingTokenAmount,
            _sellingTokenId,
            tokens[_sellingTokenId].dividendContractAddress,
            msg.sender
        );

        uint256 offerId = ++saleOffersCount;
        uint256 sellingTokenAmountWei = amountToWei(
            _sellingTokenAmount,
            _sellingTokenId
        );
        uint256 exchangeRateWei = amountToWei(
            _exchangeRate,
            _sellingForTokenId
        );
        uint256 sellingForTokenAmountWei = (exchangeRateWei *
            sellingTokenAmountWei) / WEI;

        saleOffers[offerId] = SaleOffer(
            OfferStatus.open,
            OfferLockState.unlocked,
            sellingTokenAmountWei,
            sellingForTokenAmountWei,
            0,
            _repayInSeconds,
            0,
            _collateralToDebtRatio,
            _liquidationRatio,
            _sellingTokenId,
            _sellingForTokenId,
            0,
            msg.sender,
            address(0)
        );

        emit SaleOfferCreated(
            offerId,
            sellingTokenAmountWei,
            _sellingTokenId,
            sellingForTokenAmountWei,
            _sellingForTokenId,
            exchangeRateWei,
            _repayInSeconds,
            msg.sender
        );

        return offerId;
    }

    /// @notice Accepts a sale offer by transferring the required collateral from the buyer to the contract
    /// @notice There is a 0.1% fee of the collateral amount, paid by the buyer to the fee address.
    /// @param _offerId Id of the sale offer to accept
    /** @param _collateralTokenId Id of the token to be pledged as collateral,
        cannot be same than id of selling token.
    */
    function acceptSaleOffer(
        uint256 _offerId,
        uint8 _collateralTokenId
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];

        checkOfferIsOpen(offer.offerStatus);
        checkAddressNotSender(saleOffers[_offerId].buyer);
        checkTokensIdNotSame(_collateralTokenId, offer.sellingId);

        uint256 collateralTokenAmount = getCollateral(
            offer.sellingFor,
            offer.sellingForId,
            _collateralTokenId,
            offer.collateralToDebtRatio
        );

        transferAcceptSale(
            msg.sender,
            tokens[_collateralTokenId].dividendContractAddress,
            collateralTokenAmount,
            _collateralTokenId,
            offer.selling,
            offer.sellingId
        );

        offer.timeAccepted = block.timestamp;
        offer.offerStatus = OfferStatus.accepted;
        offer.collateral = collateralTokenAmount;
        offer.collateralId = _collateralTokenId;
        saleOffers[_offerId].seller = msg.sender;

        emit SaleOfferAccepted(
            _offerId,
            amountToWei(collateralTokenAmount, _collateralTokenId),
            _collateralTokenId,
            msg.sender,
            block.timestamp
        );
    }

    /// @notice Cancels a sale offer, given that it is not accepted yet
    /// @param _offerId Id of the sale offer to cancel
    function cancelSaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];

        checkOfferIsOpen(offer.offerStatus);
        checkAddressSender(saleOffers[_offerId].buyer);

        transferContractToSender(msg.sender, offer.selling, offer.sellingId);

        offer.offerStatus = OfferStatus.closed;

        emit SaleOfferCanceled(_offerId);
    }

    /// @notice Adds collateral to a sale offer
    /// @dev Can only be called by the buyer of the sale offer
    /// @param _offerId Id of the sale offer to add collateral to
    /// @param _amountToAdd Amount of collateral to add
    function addCollateralSaleOffer(
        uint256 _offerId,
        uint256 _amountToAdd
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];

        checkIsPositive(_amountToAdd);
        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(saleOffers[_offerId].seller);

        transferSenderToContract(msg.sender, _amountToAdd, offer.collateralId);

        offer.collateral += amountToWei(_amountToAdd, offer.collateralId);

        emit SaleOfferCollateralAdded(_offerId, _amountToAdd);
    }

    /// @notice Fully repays the debt of a sale offer
    /// @param _offerId Id of the sale offer to repay
    function repaySaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];

        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(saleOffers[_offerId].seller);

        repay(
            offer.sellingFor,
            offer.sellingForId,
            offer.collateral,
            offer.collateralId,
            saleOffers[_offerId].buyer,
            saleOffers[_offerId].seller
        );

        offer.offerStatus = OfferStatus.closed;

        emit SaleOfferRepaid(
            _offerId,
            offer.sellingFor,
            offer.sellingForId,
            false
        );
    }

    /// @notice Partially repays the debt of a sale offer
    /// @param _offerId Id of the sale offer to partially repay
    /// @param _amountToRepay Amount to partially repay
    function repaySaleOfferPart(
        uint256 _offerId,
        uint256 _amountToRepay
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];
        uint256 amountToRepayWei = amountToWei(
            _amountToRepay,
            offer.sellingForId
        );

        checkIsPositive(amountToRepayWei);
        checkIsLessThan(amountToRepayWei, offer.sellingFor);
        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(saleOffers[_offerId].seller);

        transferBuyerToSeller(
            msg.sender,
            saleOffers[_offerId].buyer,
            _amountToRepay,
            offer.sellingForId
        );

        offer.sellingFor -= amountToRepayWei;

        emit SaleOfferRepaid(
            _offerId,
            amountToRepayWei,
            offer.sellingForId,
            true
        );
    }

    /// @notice Liquidates a sale offer by repaying the debt, and then receiving the pledged collateral.
    /// @notice An offer can be liquidated if and only if the collateral to debt ratio falls below the offer.liquidationRatio value previously defined (1.8).
    /** @custom:warning Liquidating an offer may incur losses.
        For instance, say that the $ value of the collateral drops below the $ value of the debt,
        if the liquidator proceeds with the liquidation, he/she will have lost a negative amount of: collateral (in $) - debt (in $).
        It is therefore recommended to verify beforehand if the transaction is profitable or not. 
        This can be done using the isLiquidationLoss function, or any other external method.
    */
    /// @param _offerId Id of the sale offer to liquidate
    function liquidateSaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];

        checkOfferIsAccepted(offer.offerStatus);

        require(
            canLiquidate(
                offer.sellingFor,
                offer.sellingForId,
                offer.collateral,
                offer.collateralId,
                offer.liquidationRatio
            ) || canLiquidateTimeOver(offer.timeAccepted, offer.repayInSeconds),
            "Can not be liquidated...yet"
        );

        if (msg.sender == saleOffers[_offerId].buyer) {
            liquidateTokensBySeller(
                offer.sellingFor,
                offer.sellingForId,
                offer.collateral,
                offer.collateralId,
                saleOffers[_offerId].seller,
                saleOffers[_offerId].buyer,
                RATIO_LIQUIDATION_IS_LOSS
            );
        } else {
            liquidateTokens(
                offer.sellingFor,
                offer.sellingForId,
                offer.collateral,
                offer.collateralId,
                saleOffers[_offerId].buyer,
                saleOffers[_offerId].seller,
                msg.sender,
                RATIO_LIQUIDATION_IS_LOSS
            );
        }

        offer.offerStatus = OfferStatus.closed;

        emit SaleOfferLiquidated(_offerId, msg.sender);
    }

    /// @notice Forfeits a sale offer
    /// @dev Only callable by the buyer
    /// @dev Transaction is reverted if it incurs a loss to the seller
    /// @param _offerId Id of the sale offer to forfeit
    function forfeitSaleOffer(
        uint256 _offerId
    ) external nonReentrant lockSaleOffer(_offerId) {
        SaleOffer storage offer = saleOffers[_offerId];

        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(saleOffers[_offerId].seller);

        liquidateTokensByBuyer(
            offer.sellingFor,
            offer.sellingForId,
            offer.collateral,
            offer.collateralId,
            saleOffers[_offerId].seller,
            saleOffers[_offerId].buyer,
            RATIO_LIQUIDATION_IS_LOSS
        );

        offer.offerStatus = OfferStatus.closed;

        emit SaleOfferForfeited(_offerId);
    }

    /// @notice Creates and posts a buy offer
    /// @notice There is a 0.1% fee of the buying amount, paid by the buyer to the fee address.
    /// @param _buyingTokenAmount Amount to buy
    /// @param _buyingTokenId Id of the buying token
    /// @param _exchangeRate Exchange rate between buying amount and buy for amount
    /** @param _buyingForTokenId Id of the repayment token,
        can not be same than id of token buying.
    */
    /** @param _collateralTokenId Id of the collateral token,
        cannot be same than id of buying token.
    */
    /** @param _repayInSeconds Repayment timeframe in unix seconds,
        a value of 0 will allow an unlimited repayment time .
    */
    function createBuyOffer(
        uint256 _buyingTokenAmount,
        uint8 _buyingTokenId,
        uint256 _exchangeRate,
        uint8 _buyingForTokenId,
        uint8 _collateralTokenId,
        uint256 _repayInSeconds,
        uint256 _collateralToDebtRatio,
        uint256 _liquidationRatio
    ) external nonReentrant returns (uint256) {
        checkIsPositive(_buyingTokenAmount);
        checkIsPositive(_exchangeRate);
        checkTokensIdNotSame(_buyingTokenId, _buyingForTokenId);
        checkTokensIdNotSame(_collateralTokenId, _buyingTokenId);
        checkMinRatio(_collateralToDebtRatio);
        checkMinRatio(_liquidationRatio);
        checkIsLessThan(_liquidationRatio, _collateralToDebtRatio);

        uint256[2] memory values = [
            amountToWei(_exchangeRate, _buyingForTokenId),
            amountToWei(_buyingTokenAmount, _buyingTokenId)
        ];

        uint256 collateralTokenAmountWei = getCollateral(
            (values[0] * values[1]) / WEI,
            _buyingForTokenId,
            _collateralTokenId,
            _collateralToDebtRatio
        );

        transferSenderToContract(
            msg.sender,
            amountFromWei(collateralTokenAmountWei, _collateralTokenId),
            _collateralTokenId
        );

        transferFee(
            amountFromWei(collateralTokenAmountWei, _collateralTokenId),
            _collateralTokenId,
            tokens[_collateralTokenId].dividendContractAddress,
            msg.sender
        );

        uint256 offerId = ++buyOffersCount;

        buyOffers[offerId] = BuyOffer(
            OfferStatus.open,
            OfferLockState.unlocked,
            values[1],
            (values[0] * values[1]) / WEI,
            collateralTokenAmountWei,
            _repayInSeconds,
            0,
            _collateralToDebtRatio,
            _liquidationRatio,
            _buyingTokenId,
            _buyingForTokenId,
            _collateralTokenId,
            address(0),
            msg.sender
        );

        emit BuyOfferCreated(
            offerId,
            values[1],
            _buyingTokenId,
            (values[0] * values[1]) / WEI,
            _buyingForTokenId,
            values[0],
            _collateralTokenId,
            _repayInSeconds,
            msg.sender
        );

        return offerId;
    }

    /// @notice Accepts a buy offer by transferring the amount buying from the seller to the buyer
    /// @notice There is a 0.1% fee of the buying amount, paid by the seller.
    /// @param _offerId Id of the buy offer to accept
    function acceptBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];
        uint256 buyingAmountFromWei = amountFromWei(
            offer.buying,
            offer.buyingId
        );

        checkOfferIsOpen(offer.offerStatus);
        checkAddressNotSender(buyOffers[_offerId].seller);

        transferBuyerToSeller(
            msg.sender,
            buyOffers[_offerId].seller,
            buyingAmountFromWei,
            offer.buyingId
        );

        transferFee(
            buyingAmountFromWei,
            offer.buyingId,
            tokens[offer.buyingId].dividendContractAddress,
            msg.sender
        );

        offer.timeAccepted = block.timestamp;
        offer.offerStatus = OfferStatus.accepted;
        buyOffers[_offerId].buyer = msg.sender;

        emit BuyOfferAccepted(_offerId, msg.sender, block.timestamp);
    }

    /// @notice Cancels a buy offer, given that it not accepted yet
    /// @param _offerId Id of the buy offer to cancel
    function cancelBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];

        checkOfferIsOpen(offer.offerStatus);
        checkAddressSender(buyOffers[_offerId].seller);

        transferContractToSender(
            msg.sender,
            offer.collateral,
            offer.collateralId
        );

        offer.offerStatus = OfferStatus.closed;

        emit BuyOfferCanceled(_offerId);
    }

    /// @notice Adds collateral to a buy offer
    /// @dev Can only be called by the buyer of the buy offer
    /// @param _offerId Id of the buy offer to add collateral to
    /// @param _amountToAdd The amount of collateral to add
    function addCollateralBuyOffer(
        uint256 _offerId,
        uint256 _amountToAdd
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];

        checkIsPositive(_amountToAdd);
        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(buyOffers[_offerId].seller);

        transferSenderToContract(msg.sender, _amountToAdd, offer.collateralId);

        offer.collateral += amountToWei(_amountToAdd, offer.collateralId);

        emit BuyOfferCollateralAdded(_offerId, _amountToAdd);
    }

    /// @notice Fully repays the debt of the buy offer
    /// @param _offerId Id of the buy offer to repay
    function repayBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];

        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(buyOffers[_offerId].seller);

        repay(
            offer.buyingFor,
            offer.buyingForId,
            offer.collateral,
            offer.collateralId,
            buyOffers[_offerId].buyer,
            buyOffers[_offerId].seller
        );

        offer.offerStatus = OfferStatus.closed;

        emit BuyOfferRepaid(
            _offerId,
            offer.buyingFor,
            offer.buyingForId,
            false
        );
    }

    /// @notice Partially repays the debt of a buy offer
    /// @param _offerId Id of the buy offer to partially repay
    /// @param _amountToRepay Amount to partially repay
    function repayBuyOfferPart(
        uint256 _offerId,
        uint256 _amountToRepay
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];
        uint256 amountToRepayWei = amountToWei(_amountToRepay, offer.buyingId);

        checkIsPositive(_amountToRepay);
        checkIsLessThan(amountToRepayWei, offer.buyingFor);
        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(buyOffers[_offerId].seller);

        transferBuyerToSeller(
            msg.sender,
            buyOffers[_offerId].buyer,
            _amountToRepay,
            offer.buyingForId
        );

        offer.buyingFor -= amountToRepayWei;

        emit BuyOfferRepaid(
            _offerId,
            amountToRepayWei,
            offer.buyingForId,
            true
        );
    }

    /// @notice Liquidates a buy offer, by repaying the debt, and then receiving the pledged collateral.
    /// @notice An offer can be liquidated if and only if the collateral to debt ratio falls below the offer.liquidationRatio value previously defined.
    /** @custom:warning Liquidating an offer may incur losses.
        For instance, say that the $ value of the collateral drops below the $ value of the debt,
        if the liquidator proceeds with the liquidation, he/she will have lost a negative amount of collateral (in $) - debt (in $).
        It is therefore recommended to verify beforehand if the transaction is profitable or not. 
        This can be done using the isLiquidationLoss function, or any other external method.
    */
    /// @param _offerId Id of the buy offer to liquidate
    function liquidateBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];

        checkOfferIsAccepted(offer.offerStatus);

        require(
            canLiquidate(
                offer.buyingFor,
                offer.buyingForId,
                offer.collateral,
                offer.collateralId,
                offer.liquidationRatio
            ) || canLiquidateTimeOver(offer.timeAccepted, offer.repayInSeconds),
            "Can not be liquidated...yet"
        );

        if (msg.sender == buyOffers[_offerId].buyer) {
            liquidateTokensBySeller(
                offer.buyingFor,
                offer.buyingForId,
                offer.collateral,
                offer.collateralId,
                buyOffers[_offerId].seller,
                buyOffers[_offerId].buyer,
                RATIO_LIQUIDATION_IS_LOSS
            );
        } else {
            liquidateTokens(
                offer.buyingFor,
                offer.buyingForId,
                offer.collateral,
                offer.collateralId,
                buyOffers[_offerId].buyer,
                buyOffers[_offerId].seller,
                msg.sender,
                RATIO_LIQUIDATION_IS_LOSS
            );
        }

        offer.offerStatus = OfferStatus.closed;

        emit BuyOfferLiquidated(_offerId, msg.sender);
    }

    /// @notice Forfeits a buy offer
    /// @dev Only callable by the buyer
    /// @dev Transaction is reverted if it incurs a loss to the seller
    /// @param _offerId Id of the buy offer to forfeit
    function forfeitBuyOffer(
        uint256 _offerId
    ) external nonReentrant lockBuyOffer(_offerId) {
        BuyOffer storage offer = buyOffers[_offerId];

        checkOfferIsAccepted(offer.offerStatus);
        checkAddressSender(buyOffers[_offerId].seller);

        if (
            !canLiquidate(
                offer.buyingFor,
                offer.buyingForId,
                offer.collateral,
                offer.collateralId,
                offer.liquidationRatio
            )
        ) {
            liquidateTokensByBuyer(
                offer.buyingFor,
                offer.buyingForId,
                offer.collateral,
                offer.collateralId,
                buyOffers[_offerId].seller,
                buyOffers[_offerId].buyer,
                RATIO_LIQUIDATION_IS_LOSS
            );
        } else {
            revert("Sender can be liquidated");
        }

        offer.offerStatus = OfferStatus.closed;

        emit BuyOfferForfeited(_offerId);
    }

    /// @notice Changes the seller or buyer's address of an offer
    /** @dev It should be noted that a contract address could be entered in the _newAddr field.
        However, doing so would not affect the contract's mechanism in a bad way.
        The only consequence would be that the msg.sender will relinquish control of the funds placed in the contract.
    */
    /// @param _offerId Id of the offer we want to change addresses
    /// @param _newAddress New address to replace the old one with
    /// @param _addressType Type of address: 0 for seller address, and 1 for buyer address.
    function changeAddressSale(
        uint256 _offerId,
        address _newAddress,
        uint8 _addressType
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsNotClosed(saleOffers[_offerId].offerStatus);

        if (_addressType == 0) {
            require(
                saleOffers[_offerId].buyer == msg.sender,
                "Sender is not seller"
            );
            require(
                saleOffers[_offerId].seller != _newAddress,
                "Address is buyer"
            );
            require(
                saleOffers[_offerId].buyer != _newAddress,
                "Address is seller"
            );
            checkAddressNotZero(_newAddress);

            saleOffers[_offerId].buyer = _newAddress;

            emit SaleOfferSellerAddressChanged(_offerId, _newAddress);
        } else if (_addressType == 1) {
            require(
                saleOffers[_offerId].seller == msg.sender,
                "Sender is not buyer"
            );
            require(
                saleOffers[_offerId].buyer != _newAddress,
                "Address is seller"
            );
            require(
                saleOffers[_offerId].seller != _newAddress,
                "Address is buyer"
            );
            checkAddressNotZero(_newAddress);

            saleOffers[_offerId].seller = _newAddress;

            emit SaleOfferBuyerAddressChanged(_offerId, _newAddress);
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
    /// @param _newAddress New address to replace the old one with
    /// @param _addressType Type of address: 0 for seller address, and 1 for buyer address.
    function changeAddressBuy(
        uint256 _offerId,
        address _newAddress,
        uint8 _addressType
    ) external nonReentrant lockSaleOffer(_offerId) {
        checkOfferIsNotClosed(buyOffers[_offerId].offerStatus);

        if (_addressType == 0) {
            require(
                buyOffers[_offerId].buyer == msg.sender,
                "Sender is not seller"
            );
            require(
                buyOffers[_offerId].seller != _newAddress,
                "Address is buyer"
            );
            require(
                buyOffers[_offerId].buyer != _newAddress,
                "Address is seller"
            );
            checkAddressNotZero(_newAddress);

            buyOffers[_offerId].buyer = _newAddress;

            emit BuyOfferSellerAddressChanged(_offerId, _newAddress);
        } else if (_addressType == 1) {
            require(
                buyOffers[_offerId].seller == msg.sender,
                "Sender is not buyer"
            );
            require(
                buyOffers[_offerId].buyer != _newAddress,
                "Address is seller"
            );
            require(
                buyOffers[_offerId].seller != _newAddress,
                "Address is buyer"
            );
            checkAddressNotZero(_newAddress);

            buyOffers[_offerId].seller = _newAddress;

            emit BuyOfferBuyerAddressChanged(_offerId, _newAddress);
        } else {
            revert("Invalid Address Type");
        }
    }

    /// @notice Gets data of a sale offer from its Id (e.g. amount selling, seller address...)
    function getSaleOfferFromId(
        uint256 _offerId
    ) external view returns (SaleOffer memory) {
        return saleOffers[_offerId];
    }

    /// @notice Gets data of a buy offer from its Id (e.g. amount selling, seller address...)
    function getBuyOfferFromId(
        uint256 _offerId
    ) external view returns (BuyOffer memory) {
        return buyOffers[_offerId];
    }
}
