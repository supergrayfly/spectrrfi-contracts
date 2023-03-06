// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "./SpectrrPrices.sol";
import "./SpectrrData.sol";
import "./SpectrrManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SpectrrUtils
/// @author Supergrayfly
/// @notice This contract handles 'secondary' functions, such as transferring tokens and calculating collateral tokens.
contract SpectrrUtils is SpectrrPrices, SpectrrData, SpectrrManager {
    /// @notice Gets the current block timestamp
    /// @return uint256 The current block timestamp
    function getBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /// @notice Gets the interface of a token based on its id
    /// @param _tokenId Id of the ERC20 token we want the interface
    /// @return IERC20 The ERC20 Interface of the token
    function getITokenFromId(uint8 _tokenId) public view returns (IERC20) {
        checkTokenIdInRange(_tokenId);
        return IERC20(tokens[_tokenId].addr);
    }

    /// @notice Gets the number of decimals of an ERC20 token
    /// @param _tokenId Id of the ERC20 token
    /// @return uint8 The number of decimals
    function getTokenDecimalsFromId(
        uint8 _tokenId
    ) public view returns (uint8) {
        checkTokenIdInRange(_tokenId);
        return tokens[_tokenId].decimals;
    }

    /// @notice Converts an amount to wei, based on the decimals the amount has
    /// @param _amount The amount to convert
    /// @param _amountTokenId Id of the amount we want to convert
    /// @return uint256 The converted amount in wei
    function amountToWei(
        uint256 _amount,
        uint8 _amountTokenId
    ) public view returns (uint256) {
        return _amount * 10 ** (18 - getTokenDecimalsFromId(_amountTokenId));
    }

    /// @notice Converts an amount from wei, based on the decimals the amount has
    /// @param _amount The amount to convert
    /// @param _amountTokenId Id of the amount we want to convert
    /// @return uint256 The converted amount
    function amountFromWei(
        uint256 _amount,
        uint8 _amountTokenId
    ) public view returns (uint256) {
        return _amount / 10 ** (18 - getTokenDecimalsFromId(_amountTokenId));
    }

    /// @notice Gets the price of a token from Chainlink
    /// @param _tokenId Id of the token we want the price
    /// @return uint256 The price of the token
    function tokenIdToPrice(uint8 _tokenId) public view returns (uint256) {
        checkTokenIdInRange(_tokenId);
        return
            uint256(
                getChainlinkPrice(tokens[_tokenId].chainlinkOracleAddress)
            ) * 10 ** (18 - tokens[_tokenId].decimals);
    }

    /// @notice Calculates the liquidation price of the collateral token
    /// @return liquidationPrice Price of the collateral token at which a liquidation will be possible
    function getLiquidationPriceCollateral(
        uint256 _collateralTokenAmountWei,
        uint256 _amountForTokenWei,
        uint8 _amountForTokenId,
        uint256 _liquidationLimit
    ) public view returns (uint256) {
        checkTokenIdInRange(_amountForTokenId);
        return
            (_liquidationLimit *
                _amountForTokenWei *
                tokenIdToPrice(_amountForTokenId)) /
            (_collateralTokenAmountWei * WEI);
    }

    /// @notice Calculates the liquidation price of the debt token
    /// @return liquidationPrice Price of the debt token at which a liquidation will be possible
    function getLiquidationPriceAmountFor(
        uint256 _collateralTokenAmountWei,
        uint256 _amountForTokenWei,
        uint8 _collateralTokenId,
        uint256 _liquidationLimit
    ) public view returns (uint256) {
        checkTokenIdInRange(_collateralTokenId);
        return
            (_collateralTokenAmountWei *
                tokenIdToPrice(_collateralTokenId) *
                WEI) / (_liquidationLimit * _amountForTokenWei);
    }

    /// @notice Transfers tokens from the sender to this contract
    /// @dev Only callable internally by this contract
    function transferSenderToContract(
        address _sender,
        uint256 _amountToken,
        uint8 _amountTokenId
    ) internal {
        getITokenFromId(_amountTokenId).transferFrom(
            _sender,
            address(this),
            _amountToken
        );
    }

    /// @notice Transfers tokens from this contract to the sender of the tx
    /// @dev Only callable internally by this contract
    function transferContractToSender(
        address _sender,
        uint256 _amountToken,
        uint8 _amountTokenId
    ) internal {
        getITokenFromId(_amountTokenId).transfer(
            _sender,
            amountFromWei(_amountToken, _amountTokenId)
        );
    }

    /// @notice Handles the transfer of the collateral, fee, and amount bought
    /// @dev Only callable internally by this contract
    /// @param _sender Address sending the tokens
    /// @param _collateralTokenAmount Collateral amount to transfer from the sender
    /// @param _collateralTokenId Id of the collateral token
    /// @param _amountToken Amount bought by the sender
    /// @param _amountTokenId Id of the bought token
    function transferAcceptSale(
        address _sender,
        uint256 _collateralTokenAmount,
        uint8 _collateralTokenId,
        uint256 _amountToken,
        uint8 _amountTokenId
    ) internal {
        uint256 collateralTokenAmountFromWei = amountFromWei(
            _collateralTokenAmount,
            _collateralTokenId
        );

        getITokenFromId(_collateralTokenId).transferFrom(
            _sender,
            address(this),
            collateralTokenAmountFromWei
        );
        transferFee(collateralTokenAmountFromWei, _collateralTokenId, _sender);
        transferContractToSender(
            _sender,
            amountFromWei(_amountToken, _amountTokenId),
            _amountTokenId
        );
    }

    /// @notice Transfers token from the buyer to the seller of an offer
    /// @dev Only callable internally by this contract
    /// @param _sender Address sending the tokens
    /// @param _receiver Address receiving the tokens
    /// @param _amountToken Amount to send
    /// @param _amountTokenId Id of the amount to send
    function transferBuyerToSeller(
        address _sender,
        address _receiver,
        uint256 _amountToken,
        uint8 _amountTokenId
    ) internal {
        getITokenFromId(_amountTokenId).transferFrom(
            _sender,
            _receiver,
            _amountToken
        );
    }

    /// @notice Calculates the collateral needed to create a buy offer or accept a sale offer
    /// @param _amountTokenWei Amount on which the collateral will be calculated
    /// @param _amountTokenId Id of the amount
    /// @param _collateralTokenId Id of the collateral
    /// @param _collateralTokenAmountWeiToDebtRatio Collateral to debt ratio, used to calculate the collateral amount.
    /// @return collateral Computed collateral amount
    function getCollateral(
        uint256 _amountTokenWei,
        uint8 _amountTokenId,
        uint8 _collateralTokenId,
        uint256 _collateralTokenAmountWeiToDebtRatio
    ) public view returns (uint256) {
        return
            (((_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                tokenIdToPrice(_collateralTokenId)) *
                _collateralTokenAmountWeiToDebtRatio) / WEI;
    }

    /// @notice Calculates the ratio of the collateral over the debt
    /// @param _amountTokenWei Amount of debt
    /// @param _collateralTokenAmountWei Collateral amount
    /// @param _amountTokenId Id of the debt amount
    /// @param _collateralTokenId Id of the collateral
    /// @return ratio Calculated ratio
    function getRatio(
        uint256 _amountTokenWei,
        uint256 _collateralTokenAmountWei,
        uint8 _amountTokenId,
        uint8 _collateralTokenId
    ) public view returns (uint256) {
        if (_amountTokenWei == 0 || _collateralTokenAmountWei == 0) {
            return 0;
        } else {
            return
                (_collateralTokenAmountWei *
                    tokenIdToPrice(_collateralTokenId) *
                    WEI) / (_amountTokenWei * tokenIdToPrice(_amountTokenId));
        }
    }

    /// @notice Determines if the collateral to debt ratio has reached the liquidation limit
    /// @param _amountTokenWei Amount of debt
    /// @param _amountTokenId Id of the debt amount
    /// @param _collateralTokenAmountWei Collateral amount
    /// @param _collateralTokenId Id of the collateral
    /// @param _liquidationLimitRatio Ratio at which liquidation will be possible
    /// @return bool If the offer can be liquidated or not
    function canLiquidate(
        uint256 _amountTokenWei,
        uint8 _amountTokenId,
        uint256 _collateralTokenAmountWei,
        uint8 _collateralTokenId,
        uint256 _liquidationLimitRatio
    ) public view returns (bool) {
        if (
            getRatio(
                _amountTokenWei,
                _collateralTokenAmountWei,
                _amountTokenId,
                _collateralTokenId
            ) <=
            _liquidationLimitRatio &&
            _amountTokenWei > 0 &&
            _collateralTokenAmountWei > 0
        ) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice Determines if the repayment period has passed
    /// @param _timeAccepted Time at which the offer was accepted
    /// @param _repayInSeconds Repayment period of the offer
    /// @return bool If the offer can be liquidated or not
    function canLiquidateTimeOver(
        uint256 _timeAccepted,
        uint256 _repayInSeconds
    ) public view returns (bool) {
        if (_repayInSeconds == 0 || _timeAccepted == 0) {
            return false;
        } else {
            if (block.timestamp > (_timeAccepted + _repayInSeconds)) {
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
    /// @param _amountTokenWei Amount of debt
    /// @param _amountTokenId Id of the debt amount
    /// @param _collateralTokenAmountWei Amount of collateral
    /// @param _collateralTokenId Id of the collateral
    /// @param _seller Address of the offer's seller
    /// @param _buyer Address of the offer's buyer
    /// @param _sender Address of the liquidator
    /// @param _liquidationLossRatio Ratio at which a liquidation will incur a loss (i.e., the collateral value is below the debt)
    function liquidateTokens(
        uint256 _amountTokenWei,
        uint8 _amountTokenId,
        uint256 _collateralTokenAmountWei,
        uint8 _collateralTokenId,
        address _seller,
        address _buyer,
        address _sender,
        uint256 _liquidationLossRatio
    ) internal {
        IERC20 collateralToken = getITokenFromId(_collateralTokenId);

        if (
            getRatio(
                _amountTokenWei,
                _collateralTokenAmountWei,
                _amountTokenId,
                _collateralTokenId
            ) >= _liquidationLossRatio
        ) {
            uint256 toTransfer = _collateralTokenAmountWei -
                (_collateralTokenAmountWei -
                    ((_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                        tokenIdToPrice(_collateralTokenId)));

            getITokenFromId(_amountTokenId).transferFrom(
                _sender,
                _seller,
                amountFromWei(_amountTokenWei, _amountTokenId)
            );
            collateralToken.transfer(
                _sender,
                amountFromWei(toTransfer, _collateralTokenId)
            );
            collateralToken.transfer(
                _buyer,
                amountFromWei(
                    (_collateralTokenAmountWei -
                        ((_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                            tokenIdToPrice(_collateralTokenId))),
                    _amountTokenId
                )
            );
        } else {
            getITokenFromId(_amountTokenId).transferFrom(
                _sender,
                _seller,
                amountFromWei(_amountTokenWei, _amountTokenId)
            );
            collateralToken.transfer(
                _sender,
                amountFromWei(_collateralTokenAmountWei, _collateralTokenId)
            );
        }
    }

    /// @notice Liquidates an offer when the liquidator is the seller
    /** @dev Only callable internally by this contract.
        When the debt to collateral ratio is above 1, the value of the collateral equal to the debt is sent to the seller, and the rest is sent back to the buyer.
        Otherwise, the whole collateral amount is sent to the seller.    
    */
    /// @param _amountTokenWei Amount of debt
    /// @param _amountTokenId Id of the debt amount
    /// @param _collateralTokenAmountWei Amount of collateral
    /// @param _collateralTokenId Id of the collateral
    /// @param _buyer Address of the buyer
    /// @param _seller Address of the seller
    /// @param _liquidationLossRatio Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value)
    function liquidateTokensBySeller(
        uint256 _amountTokenWei,
        uint8 _amountTokenId,
        uint256 _collateralTokenAmountWei,
        uint8 _collateralTokenId,
        address _buyer,
        address _seller,
        uint256 _liquidationLossRatio
    ) internal {
        IERC20 collateralToken = getITokenFromId(_collateralTokenId);

        uint256 ratio = getRatio(
            _amountTokenWei,
            _collateralTokenAmountWei,
            _amountTokenId,
            _collateralTokenId
        );

        if (ratio > _liquidationLossRatio) {
            uint256 toTransfer = _collateralTokenAmountWei -
                (_collateralTokenAmountWei -
                    (_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                    tokenIdToPrice(_collateralTokenId));

            collateralToken.transfer(
                _seller,
                amountFromWei(toTransfer, _collateralTokenId)
            );
            collateralToken.transfer(
                _buyer,
                amountFromWei(
                    _collateralTokenAmountWei -
                        ((_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                            tokenIdToPrice(_collateralTokenId)),
                    _collateralTokenId
                )
            );
        } else if (ratio <= _liquidationLossRatio) {
            collateralToken.transfer(
                _seller,
                amountFromWei(_collateralTokenAmountWei, _collateralTokenId)
            );
        } else {
            revert("Can not be liquidated...yet");
        }
    }

    /// @notice Liquidates an offer when the liquidator is the buyer
    /// @dev Only callable internally by this contract, reverts if it incurs a loss to the seller.
    /// @param _amountTokenWei Amount of debt
    /// @param _amountTokenId Id of the debt amount
    /// @param _collateralTokenAmountWei Amount of collateral
    /// @param _collateralTokenId Id of the collateral
    /// @param _buyer Address of the buyer
    /// @param _seller Address of the seller
    /// @param _liquidationLossRatio Collateral to debt ratio at which a liquidation will incur a loss (i.e., when the collateral value is below the debt value)
    function liquidateTokensByBuyer(
        uint256 _amountTokenWei,
        uint8 _amountTokenId,
        uint256 _collateralTokenAmountWei,
        uint8 _collateralTokenId,
        address _buyer,
        address _seller,
        uint256 _liquidationLossRatio
    ) internal {
        IERC20 collateralToken = getITokenFromId(_collateralTokenId);

        uint256 ratio = getRatio(
            _amountTokenWei,
            _collateralTokenAmountWei,
            _amountTokenId,
            _collateralTokenId
        );

        if (ratio > _liquidationLossRatio) {
            uint256 toTransfer = _collateralTokenAmountWei -
                (_collateralTokenAmountWei -
                    (_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                    tokenIdToPrice(_collateralTokenId));

            collateralToken.transfer(
                _seller,
                amountFromWei(toTransfer, _collateralTokenId)
            );
            collateralToken.transfer(
                _buyer,
                amountFromWei(
                    _collateralTokenAmountWei -
                        ((_amountTokenWei * tokenIdToPrice(_amountTokenId)) /
                            tokenIdToPrice(_collateralTokenId)),
                    _collateralTokenId
                )
            );
        } else if (ratio == _liquidationLossRatio) {
            collateralToken.transfer(
                msg.sender,
                amountFromWei(_collateralTokenAmountWei, _collateralTokenId)
            );
        } else {
            revert("Liquidation loss to seller");
        }
    }

    /// @notice Repays a debt, and transfers back the collateral.
    /// @dev Only callable internally by this contract
    /// @param _amountToRepay Amount to repay
    /// @param _amountToRepayId Id of the amount to repay
    /// @param _collateralTokenAmountWei Amount of collateral
    /// @param _collateralTokenId Id of the collateral
    /// @param _seller Address of the seller
    /// @param _buyer Address of the buyer
    function repay(
        uint256 _amountToRepay,
        uint8 _amountToRepayId,
        uint256 _collateralTokenAmountWei,
        uint8 _collateralTokenId,
        address _seller,
        address _buyer
    ) internal {
        getITokenFromId(_amountToRepayId).transferFrom(
            _buyer,
            _seller,
            amountFromWei(_amountToRepay, _amountToRepayId)
        );
        getITokenFromId(_collateralTokenId).transfer(
            _buyer,
            amountFromWei(_collateralTokenAmountWei, _collateralTokenId)
        );
    }

    /// @notice Transfers the fee from the sender to the fee address
    /// @dev Only callable internally by this contract
    /// @param _amountToken Amount of which 0.1% will be taken
    /// @param _amountTokenId Id of the amount
    /// @param _sender Address of the sender
    function transferFee(
        uint256 _amountToken,
        uint8 _amountTokenId,
        address _sender
    ) internal {
        getITokenFromId(_amountTokenId).transferFrom(
            _sender,
            feeAddress,
            (_amountToken / FEE_PERCENT)
        );
    }

    /// @notice Checks if token Id is a tradable token
    /// @param _id Id of the token
    function checkTokenIdInRange(uint8 _id) internal view {
        require(_id > 0 && _id <= tokenCount, "Invalid Id");
    }

    /// @notice Checks if address is zero address
    /// @param _address Address to check
    function checkAddressNotZero(address _address) internal pure {
        require(_address != address(0), "Address is Zero");
    }

    /// @notice Checks if address matches with sender of transaction, reverts if true
    /// @param _address Address to compare with msg.sender
    function checkAddressNotSender(address _address) internal view {
        require(_address != msg.sender, "Unvalid Sender");
    }

    /// @notice Checks if address matches with sender of transaction, reverts if false
    /// @param _address Address to compare with msg.snder
    function checkAddressSender(address _address) internal view {
        require(_address == msg.sender, "Unvalid Sender");
    }

    /// @notice Checks if amount is positive, reverts if false
    /// @param _amountTokenWei Amount to check
    function checkIsPositive(uint256 _amountTokenWei) internal pure {
        require(_amountTokenWei > 0, "Amount is negative");
    }

    /// @notice Checks if id of two tokens are the same, reverts if true
    /// @param _id Id of first token
    /// @param id_ id of second token
    function checkTokensIdNotSame(uint8 _id, uint8 id_) internal pure {
        require(_id != id_, "Cannot be same token Id");
    }

    /// @notice Checks if offer is open (i.e. not accepted or closed), reverts if false
    /// @param _offerStatus Current state of the offer
    function checkOfferIsOpen(OfferStatus _offerStatus) internal pure {
        require(_offerStatus != OfferStatus.accepted, "Offer is accepted");
        require(_offerStatus != OfferStatus.closed, "Offer is closed");
    }

    /// @notice Checks if offer is accepted (i.e. not open or closed), reverts if false
    /// @param _offerStatus Current state of the offer
    function checkOfferIsAccepted(OfferStatus _offerStatus) internal pure {
        require(_offerStatus != OfferStatus.closed, "Offer is closed");
        require(_offerStatus != OfferStatus.open, "Offer is open");
    }

    /// @notice Checks if offer is closed (i.e. not open or closed), reverts if false
    /// @param _offerStatus Current state of the offer
    function checkOfferIsClosed(OfferStatus _offerStatus) internal pure {
        require(_offerStatus != OfferStatus.accepted, "Offer is accepted");
        require(_offerStatus != OfferStatus.open, "Offer is open");
    }

    /// @notice Checks if offer is closed (i.e. not open or closed), reverts if false
    /// @param _offerStatus Current state of the offer
    function checkOfferIsNotClosed(OfferStatus _offerStatus) internal pure {
        require(_offerStatus != OfferStatus.closed, "Offer is closed");
    }

    /// @notice Checks if amount sent is bigger than debt, reverts if true
    /// @param _amountTokenWei The amount to send
    /// @param _debt The debt owed
    function checkIsLessThan(
        uint256 _amountTokenWei,
        uint256 _debt
    ) internal pure {
        require(_amountTokenWei < _debt, "Amount greater than debt");
    }
}
