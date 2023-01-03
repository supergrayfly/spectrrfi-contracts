// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "./SpectrrPrices.sol";
import "./SpectrrData.sol";
import "./SpectrrManager.sol";

/// @title SpectrrUtils
/// @author Superfly
/// @notice This contract handles 'secondary' functions, such as transferring tokens and calculating collateral.
contract SpectrrUtils is SpectrrPrices, SpectrrData, SpectrrManager {
    /// @notice Gets the current block timestamp
    /// @return uint256 The current block timestamp
    function getBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /// @notice Gets the interface of a token based on its id
    /// @param _tokenId Id of the token we want the interface
    /// @return IERC20 The Interface of the token
    function getToken(uint8 _tokenId) public view returns (IERC20) {
        require(_tokenId <= tokenCount && _tokenId > 0, "Token id not valid");

        return tokens[_tokenId].Itoken;
    }

    /// @notice Gets the price of a token from Chainlink
    /// @param _tokenId Id of the token we want the price
    /// @return uint256 The price of the token
    function idToPrice(uint8 _tokenId) public view returns (uint256) {
        require(_tokenId <= tokenCount && _tokenId > 0, "Token id not valid");

        uint256 price = uint256(
            getChainlinkPrice(tokens[_tokenId].chainlinkAddr)
        );

        return price * 10 ** (18 - tokens[_tokenId].priceDecimals);
    }

    /// @notice Transfers tokens from the sender to this contract
    /// @dev Only callable internally by this contract
    function transferSenderToContract(
        address _sender,
        uint256 _amount,
        uint8 _amountId
    ) internal {
        IERC20 token = getToken(_amountId);
        token.transferFrom(_sender, address(this), _amount);
    }

    /// @notice Transfers tokens from this contract to the sender of the tx
    /// @dev Only callable internally by this contract
    function transferContractToSender(
        address _sender,
        uint256 _amount,
        uint8 _amountId
    ) internal {
        IERC20 token = getToken(_amountId);
        token.transfer(_sender, _amount);
    }

    /// @notice Calculates the liquidation price of the collateral token
    /// @return liquidationPrice Price of the collateral token at which a liquidation will be possible
    function getLiquidationPriceCollateral(
        uint256 _collateral,
        uint256 _amountFor,
        uint8 _amountForId,
        uint256 _liquidationLimit
    ) public view returns (uint256) {
        uint256 liquidationPrice = (_liquidationLimit *
            _amountFor *
            idToPrice(_amountForId)) / (_collateral * 10 ** 18);

        return liquidationPrice;
    }

    /// @notice Calculates the liquidation price of the debt token
    /// @return liquidationPrice Price of the debt token at which a liquidation will be possible
    function getLiquidationPriceAmountFor(
        uint256 _collateral,
        uint256 _amountFor,
        uint8 _collateralId,
        uint256 _liquidationLimit
    ) public view returns (uint256) {
        uint256 liquidationPrice = (_collateral *
            idToPrice(_collateralId) *
            10 ** 18) / (_liquidationLimit * _amountFor);

        return liquidationPrice;
    }

    /// @notice Handles the transfer of the collateral, fee, and amount bought
    /// @dev Only callable internally by this contract
    /// @param _sender Address sending the tokens
    /// @param _collateral Collateral amount to transfer from the sender
    /// @param _collateralId Id of the collateral token
    /// @param _amount Amount bought by the sender
    /// @param _amountId Id of the bought token
    function transferAcceptSale(
        address _sender,
        uint256 _collateral,
        uint8 _collateralId,
        uint256 _amount,
        uint8 _amountId
    ) internal {
        IERC20 token = getToken(_collateralId);

        token.transferFrom(_sender, address(this), _collateral);
        transferFee(_amount, _amountId, _sender);
        transferContractToSender(_sender, _amount, _amountId);
    }

    /// @notice Transfers token from the buyer to the seller of an offer
    /// @ Only callable internally by this contract
    /// @param _sender Address sending the tokens
    /// @param _receiver Address receiving the tokens
    /// @param _amount Amount to send
    /// @param _amountId Id of the amount to send
    function transferBuyerToSeller(
        address _sender,
        address _receiver,
        uint256 _amount,
        uint8 _amountId
    ) internal {
        IERC20 token = getToken(_amountId);
        token.transferFrom(_sender, _receiver, _amount);
    }

    /// @notice Calculates the collateral needed to create a buy offer or accept a sale offer
    /// @param _amount Amount on which the collateral will be calculated
    /// @param _amountId Id of the amount
    /// @param _collateralId Id of the collateral
    /// @param _collateralToDebtRatio Collateral to debt ratio, used to calculate the collateral amount.
    /// @return collateral Computed collateral amount
    function getCollateral(
        uint256 _amount,
        uint8 _amountId,
        uint8 _collateralId,
        uint256 _collateralToDebtRatio
    ) public view returns (uint256) {
        uint256 collateral = (((_amount * idToPrice(_amountId)) /
            idToPrice(_collateralId)) * _collateralToDebtRatio) / 10 ** 18;
        return collateral;
    }

    /// @notice Calculates the ratio of the collateral over the debt
    /// @param _amount Amount of debt
    /// @param _collateral Collateral amount
    /// @param _amountId Id of the debt amount
    /// @param _collateralId Id of the collateral
    /// @return ratio Calculated ratio
    function getRatio(
        uint256 _amount,
        uint256 _collateral,
        uint8 _amountId,
        uint8 _collateralId
    ) public view returns (uint256) {
        if (_amount == 0 || _collateral == 0) {
            return 0;
        } else {
            uint256 ratio = (_collateral *
                idToPrice(_collateralId) *
                10 ** 18) / (_amount * idToPrice(_amountId));
            return ratio;
        }
    }

    /// @notice Determines if the collateral to debt ratio has reached the liquidation limit
    /// @param _amount Amount of debt
    /// @param _amountId Id of the debt amount
    /// @param _collateral Collateral amount
    /// @param _collateralId Id of the collateral
    /// @param _liquidationLimitRatio Ratio at which liquidation will be possible
    /// @return bool If the offer can be liquidated or not
    function canLiquidate(
        uint256 _amount,
        uint8 _amountId,
        uint256 _collateral,
        uint8 _collateralId,
        uint256 _liquidationLimitRatio
    ) public view returns (bool) {
        if (
            getRatio(_amount, _collateral, _amountId, _collateralId) <=
            _liquidationLimitRatio &&
            _amount > 0 &&
            _collateral > 0
        ) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice Determines if the repayment period has passed
    /// @param _timeAccepted Time at which the offer was accepted
    /// @param _repayInSec Repayment period of the offer
    /// @return bool If the offer can be liquidated or not
    function canLiquidateTimeOver(
        uint256 _timeAccepted,
        uint256 _repayInSec
    ) public view returns (bool) {
        if (_repayInSec == 0 || _timeAccepted == 0) {
            return false;
        } else {
            if (block.timestamp > (_timeAccepted + _repayInSec)) {
                return true;
            } else {
                return false;
            }
        }
    }

    /// @notice Liquidates an offer by repaying the debt, and then receiving a collateral amount equal to the debt amount.
    /** @dev Only callable internally by this contract.
        When the debt to collateral ratio is above 1, the value of the collateral equal to the debt is sent to the liquidator, and the rest is sent back to the buyer.
        Otherwise, the whole collateral amount is sent to the liquidator.    
    */
    /// @param _amount Amount of debt
    /// @param _amountId Id of the debt amount
    /// @param _collateral Amount of collateral
    /// @param _collateralId Id of the collateral
    /// @param _seller Address of the offer's seller
    /// @param _buyer Address of the offer's buyer
    /// @param _sender Address of the liquidator
    /// @param _liquidationLossRatio Ratio at which a liquidation will incur a loss (i.e., the collateral value is below the debt)
    function liquidateAssets(
        uint256 _amount,
        uint8 _amountId,
        uint256 _collateral,
        uint8 _collateralId,
        address _seller,
        address _buyer,
        address _sender,
        uint256 _liquidationLossRatio
    ) internal {
        IERC20 amountToken = getToken(_amountId);
        IERC20 collateralToken = getToken(_collateralId);

        if (
            getRatio(_amount, _collateral, _amountId, _collateralId) >=
            _liquidationLossRatio
        ) {
            uint256 toTransfer = _collateral -
                (_collateral -
                    ((_amount * idToPrice(_amountId)) /
                        idToPrice(_collateralId)));

            amountToken.transferFrom(_sender, _seller, _amount);
            collateralToken.transfer(_sender, toTransfer);
            collateralToken.transfer(
                _buyer,
                (_collateral -
                    ((_amount * idToPrice(_amountId)) /
                        idToPrice(_collateralId)))
            );
        } else {
            amountToken.transferFrom(_sender, _seller, _amount);
            collateralToken.transfer(_sender, _collateral);
        }
    }

    /// @notice Liquidates an offer when the liquidator is the seller
    /** @dev Only callable internally by this contract.
        When the debt to collateral ratio is above 1, the value of the collateral equal to the debt is sent to the seller, and the rest is sent back to the buyer.
        Otherwise, the whole collateral amount is sent to the seller.    
    */
    /// @param _amount Amount of debt
    /// @param _amountId Id of the debt amount
    /// @param _collateral Amount of collateral
    /// @param _collateralId Id of the collateral
    /// @param _buyer Address of the buyer
    /// @param _seller Address of the seller
    /// @param _liquidationLossRatio Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value)
    function liquidateAssetsBySeller(
        uint256 _amount,
        uint8 _amountId,
        uint256 _collateral,
        uint8 _collateralId,
        address _buyer,
        address _seller,
        uint256 _liquidationLossRatio
    ) internal {
        IERC20 collateralToken = getToken(_collateralId);

        uint256 ratio = getRatio(
            _amount,
            _collateral,
            _amountId,
            _collateralId
        );

        if (ratio > _liquidationLossRatio) {
            uint256 toTransfer = _collateral -
                (_collateral -
                    (_amount * idToPrice(_amountId)) /
                    idToPrice(_collateralId));

            collateralToken.transfer(_seller, toTransfer);
            collateralToken.transfer(
                _buyer,
                (_collateral -
                    ((_amount * idToPrice(_amountId)) /
                        idToPrice(_collateralId)))
            );
        } else if (ratio <= _liquidationLossRatio) {
            collateralToken.transfer(_seller, _collateral);
        } else {
            revert("Can not be liquidated...yet");
        }
    }

    /// @notice Liquidates an offer when the liquidator is the buyer
    /// @dev Only callable internally by this contract, reverts if it incurs a loss to the seller.
    /// @param _amount Amount of debt
    /// @param _amountId Id of the debt amount
    /// @param _collateral Amount of collateral
    /// @param _collateralId Id of the collateral
    /// @param _buyer Address of the buyer
    /// @param _seller Address of the seller
    /// @param _liquidationLossRatio Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value)
    function liquidateAssetsByBuyer(
        uint256 _amount,
        uint8 _amountId,
        uint256 _collateral,
        uint8 _collateralId,
        address _buyer,
        address _seller,
        uint256 _liquidationLossRatio
    ) internal {
        IERC20 collateralToken = getToken(_collateralId);

        uint256 ratio = getRatio(
            _amount,
            _collateral,
            _amountId,
            _collateralId
        );

        if (ratio > _liquidationLossRatio) {
            uint256 toTransfer = _collateral -
                (_collateral -
                    (_amount * idToPrice(_amountId)) /
                    idToPrice(_collateralId));

            collateralToken.transfer(_seller, toTransfer);
            collateralToken.transfer(
                _buyer,
                (_collateral -
                    ((_amount * idToPrice(_amountId)) /
                        idToPrice(_collateralId)))
            );
        } else if (ratio == _liquidationLossRatio) {
            collateralToken.transfer(msg.sender, _collateral);
        } else {
            revert("Offer will incur loss to seller");
        }
    }

    /// @notice Repays a debt, and transfers back the collateral.
    /// @dev Only callable internally by this contract
    /// @param _toRepay Amount to repay
    /// @param _toRepayId Id of the amount to repay
    /// @param _collateral Amount of collateral
    /// @param _collateralId Id of the collateral
    /// @param _seller Address of the seller
    /// @param _buyer Address of the buyer
    function repay(
        uint256 _toRepay,
        uint8 _toRepayId,
        uint256 _collateral,
        uint8 _collateralId,
        address _seller,
        address _buyer
    ) internal {
        IERC20 repayToken = getToken(_toRepayId);
        IERC20 collateralToken = getToken(_collateralId);

        repayToken.transferFrom(_buyer, _seller, _toRepay);
        collateralToken.transfer(_buyer, _collateral);
    }

    /// @notice Transfers the fee from the sender to the fee address
    /// @dev Only callable internally by this contract
    /// @param _amount Amount on which 0.5% will be taken
    /// @param _amountId Id of the amount
    /// @param _sender Address of the sender
    function transferFee(
        uint256 _amount,
        uint8 _amountId,
        address _sender
    ) internal {
        IERC20 token = getToken(_amountId);
        token.transferFrom(_sender, feeAddr, (_amount / FEE_PERCENT));
    }

    /// @notice Checks if amount is positive, reverts if false
    /// @param _amount Amount to check
    function checkIsPositive(uint256 _amount) internal pure {
        require(_amount > 0, "Amount must be positive");
    }

    /// @notice Checks if id is in the range of tradable tokens
    /// @param _id Id of the token
    function checkTokenId(uint _id) internal view {
        require(_id > 0 && _id <= tokenCount, "Invalid Id");
    }

    /// @notice Checks if id of two tokens are the same, reverts if true
    /// @param _id Id of first token
    /// @param __id id of second token
    function checkIsSameId(uint8 _id, uint8 __id) internal pure {
        require(_id != __id, "Id's are the same");
    }

    /// @notice Checks if offer is open (i.e. not accepted or closed), reverts if false
    /// @param _offerState Current state of the offer
    function checkOfferIsOpen(OfferState _offerState) internal pure {
        require(_offerState != OfferState.accepted, "Offer is accepted");
        require(_offerState != OfferState.closed, "Offer is closed");
    }

    /// @notice Checks if offer is accepted (i.e. not open or closed), reverts if false
    /// @param _offerState Current state of the offer
    function checkOfferIsAccepted(OfferState _offerState) internal pure {
        require(_offerState != OfferState.closed, "Offer is closed");
        require(_offerState != OfferState.open, "Offer is open");
    }

    /// @notice Checks if offer is closed (i.e. not open or closed), reverts if false
    /// @param _offerState Current state of the offer
    function checkOfferIsClosed(OfferState _offerState) internal pure {
        require(_offerState != OfferState.accepted, "Offer is accepted");
        require(_offerState != OfferState.open, "Offer is open");
    }

    /// @notice Checks if address matches with sender of transaction, reverts if true
    /// @param _addr Address to compare with msg.sender
    function checkNotSender(address _addr) internal view {
        require(_addr != msg.sender, "Unvalid Sender");
    }

    /// @notice Checks if address matches with sender of transaction, reverts if false
    /// @param _addr Address to compare with msg.snder
    function checkSender(address _addr) internal view {
        require(_addr == msg.sender, "Unvalid Sender");
    }

    /// @notice Checks if amount sent is bigger than debt, reverts if true
    /// @param _amount The amount to sender
    /// @param _debt The debt owed
    function checkIsLessThan(uint256 _amount, uint256 _debt) internal pure {
        require(_amount < _debt, "Amount greater than debt");
    }
}
