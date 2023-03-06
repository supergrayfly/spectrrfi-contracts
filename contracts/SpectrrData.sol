// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

/// @title SpectrrData
/// @author Supergrayfly
/// @notice Defines and initializes the data for the SpectrrCore Contract
contract SpectrrData {
    /// @notice The minimum collateral to debt ratio allowing a liquidation (1.25)
    uint256 public constant MIN_RATIO_LIQUIDATION = 125 * 10 ** 16;

    /// @notice The collateral to debt ratio when the value of the collateral is equal to the value of the debt (1)
    uint256 public constant RATIO_LIQUIDATION_IS_LOSS = 1 * 10 ** 18;

    /// @notice The initial collateral to debt ratio needed to create an offer (1.5)
    uint256 public constant RATIO_COLLATERAL_TO_DEBT = 15 * 10 ** 17;

    uint256 public constant WEI = 10 ** 18;

    /** @dev Number of existing sale offers, initialized as 0 in the beginning,
        and incremented by one at every sale offer creation.
    */
    uint256 public saleOffersCount = 0;

    /** @dev Number of existing buy offers, initialized as 0 in the beginning,
        and incremented by one at every buy offer creation.
    */
    uint256 public buyOffersCount = 0;

    /// @dev Map of offer id (saleOffersCount) and sale offer struct
    mapping(uint256 => SaleOffer) public saleOffers;

    /// @dev Map of offer id (buyOffersCount) and buy offer struct
    mapping(uint256 => BuyOffer) public buyOffers;

    /// @dev Enum set tracking the status of an offer
    enum OfferStatus {
        open,
        accepted,
        closed
    }

    /// @dev Enum set tracking the lock state of an offer
    enum OfferLockState {
        locked,
        unlocked
    }

    /// @dev SaleOffer struct, containing all the data composing a sale offer.
    struct SaleOffer {
        OfferStatus offerStatus;
        OfferLockState offerLockState;
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

    /// @dev BuyOffer struct, containing all the data composing a buy offer.
    struct BuyOffer {
        OfferStatus offerStatus;
        OfferLockState offerLockState;
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

    /// @notice Event emitted when a sale offer is created
    event SaleOfferCreated(
        uint256 offerId,
        uint256 selling,
        uint8 sellingId,
        uint256 sellingFor,
        uint8 sellingForId,
        uint256 exRate,
        uint256 repayInSeconds,
        address seller,
        uint256 timestamp
    );

    /// @notice Event emitted when a sale offer is accepted
    event SaleOfferAccepted(
        uint256 offerId,
        uint256 collateral,
        uint8 collateralId,
        address buyer,
        uint256 timestamp
    );

    /// @notice Event emitted when collateral is added to a sale offer
    event SaleOfferCollateralAdded(uint256 offerId, uint256 amount);

    /// @notice Event emitted when a sale offer is canceled
    event SaleOfferCanceled(uint256 offerId);

    /// @notice Event emitted when a sale offer is liquidated
    event SaleOfferLiquidated(uint256 offerId, address liquidator);

    /// @notice Event emitted when the seller address of a sale offer changes
    event SaleOfferSellerAddressChanged(uint256 offerId, address newAddress);

    /// @notice Event emitted when the buyer address of a sale offer changes
    event SaleOfferBuyerAddressChanged(uint256 offerId, address newAddress);

    /// @notice Event emitted when a sale offer is repaid
    event SaleOfferRepaid(
        uint256 offerId,
        uint256 amount,
        uint8 amountId,
        bool byPart
    );

    /// @notice Event emitted when a sale offer is forfeited
    event SaleOfferForfeited(uint256 offerId);

    /// @notice Event emitted when a buy offer is created
    event BuyOfferCreated(
        uint256 offerId,
        uint256 buying,
        uint8 buyingId,
        uint256 buyingFor,
        uint8 buyingForId,
        uint256 exRate,
        uint8 collateralId,
        uint256 repayInSeconds,
        address buyer,
        uint256 timestamp
    );

    /// @notice Event emitted when a buy offer is accepted
    event BuyOfferAccepted(uint256 offerId, address seller, uint256 timestamp);

    /// @notice Event emitted when collateral is added to a buy offer
    event BuyOfferCollateralAdded(uint256 offerId, uint256 amount);

    /// @notice Event emitted when a buy offer is canceled
    event BuyOfferCanceled(uint256 offerId);

    /// @notice Event emitted when a buy offer is liquidated
    event BuyOfferLiquidated(uint256 offerId, address liquidator);

    /// @notice Event emitted when the seller address of a buy offer changes
    event BuyOfferSellerAddressChanged(uint256 offerId, address newAddress);

    /// @notice Event emitted when the buyer address of a buy offer changes
    event BuyOfferBuyerAddressChanged(uint256 offerId, address newAddress);

    /// @notice Event emitted when a buy offer is repaid
    event BuyOfferRepaid(
        uint256 offerId,
        uint256 amount,
        uint8 amountId,
        bool byPart
    );

    /// @notice Event emitted when a buy offer is forfeited
    event BuyOfferForfeited(uint256 offerId);

    /** @dev Modifier used to protect from reentrancy.
        Called when a function changing the state of a sale offer struct is entered, it prevents changes by anyone aside from the current msg.sender.
        It differs from the nonReentrant modifier, 
        as the latter only restricts the msg.sender from calling other functions in the contract.
    */
    modifier lockSaleOffer(uint256 _offerId) {
        require(
            saleOffers[_offerId].offerLockState != OfferLockState.locked,
            "Sale Offer Locked"
        );

        saleOffers[_offerId].offerLockState = OfferLockState.locked;
        _;
        saleOffers[_offerId].offerLockState = OfferLockState.unlocked;
    }

    /// @dev Same as modifier above, but for buy offers
    modifier lockBuyOffer(uint256 _offerId) {
        require(
            buyOffers[_offerId].offerLockState != OfferLockState.locked,
            "Buy Offer Locked"
        );

        buyOffers[_offerId].offerLockState = OfferLockState.locked;
        _;
        buyOffers[_offerId].offerLockState = OfferLockState.unlocked;
    }
}
