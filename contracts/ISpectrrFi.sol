// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

interface ISpectrrFi {
    function createSaleOffer(
        uint256 sellingTokenAmount,
        uint8 sellingTokenId,
        uint256 exchangeRate,
        uint8 sellingForTokenId,
        uint256 repayInSeconds,
        uint256 collateralToDebtRatio,
        uint256 liquidationRatio
    ) external returns (uint256);

    function acceptSaleOffer(uint256 offerId, uint8 collateralTokenId) external;

    function cancelSaleOffer(uint256 offerId) external;

    function addCollateralSaleOffer(
        uint256 offerId,
        uint256 amountToAdd
    ) external;

    function repaySaleOffer(uint256 offerId) external;

    function repaySaleOfferPart(
        uint256 offerId,
        uint256 amountToRepay
    ) external;

    function liquidateSaleOffer(uint256 offerId) external;

    function forfeitSaleOffer(uint256 offerId) external;

    function changeAddressSale(
        uint256 offerId,
        address newAddress,
        uint8 addressType
    ) external;

    function createBuyOffer(
        uint256 buyingTokenAmount,
        uint8 buyingTokenId,
        uint256 exchangeRate,
        uint8 buyingForTokenId,
        uint8 collateralTokenId,
        uint256 repayInSeconds,
        uint256 collateralToDebtRatio,
        uint256 liquidationRatio
    ) external;

    function acceptBuyOffer(uint256 offerId) external;

    function cancelBuyOffer(uint256 offerId) external;

    function addCollateralBuyOffer(
        uint256 offerId,
        uint256 amountToAdd
    ) external;

    function repayBuyOffer(uint256 offerId) external;

    function repayBuyOfferPart(uint256 offerId, uint256 amountToRepay) external;

    function liquidateBuyOffer(uint256 offerId) external;

    function forfeitBuyOffer(uint256 offerId) external;

    function changeAddressBuy(
        uint256 offerId,
        address newAddress,
        uint8 addressType
    ) external;
}
