// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

/// @title SpectrrData
/// @author Superfly
/// @notice Defines and initializes the data for the SpectrrCore Contract
contract SpectrrData {
    /// @notice The minimum collateral to debt ratio allowing a liquidation
    uint256 public constant MIN_RATIO_LIQUIDATION = 13 * 10 ** 17;

    /// @notice The collateral to debt ratio when the value of the collateral is equal to the value of the debt.
    uint256 public constant RATIO_LIQUIDATION_IS_LOSS = 1 * 10 ** 18;

    /// @notice The initial collateral to debt ratio needed to create an offer.
    uint256 public constant RATIO_COLLATERAL_TO_DEBT = 18 * 10 ** 17;

    /** @dev Number of existing sale offers, initialized as 0 in the beggining,
        and incremented by one at every sale offer creation.
    */
    uint256 public saleOffersCount = 0;

    /** @dev Number of existing buy offers, initialized as 0 in the beggining,
        and incremented by one at every buy offer creation.
    */
    uint256 public buyOffersCount = 0;

    /// @dev Map of offer id (saleOffersCount) and sale offer struct
    mapping(uint256 => SaleOffer) public saleOffers;

    /// @dev Map of offer id (buyOffersCount) and buy offer struct
    mapping(uint256 => BuyOffer) public buyOffers;

    /// @dev Enum set tracking the state of an offer
    enum OfferState {
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
        OfferState offerState; //0
        OfferLockState offerLockState; //1
        uint256 offerId; //2
        uint256 selling; //3
        uint256 sellFor; //4
        uint256 collateral; //5
        uint256 repayInSec; //6
        uint256 timeAccepted; //7
        uint8 sellingId; //8
        uint8 sellForId; //9
        uint8 collateralId; //10
        address seller; //11
        address buyer; //12
    }

    /// @dev BuyOffer struct, containing all the data composing a buy offer.
    struct BuyOffer {
        OfferState offerState;
        OfferLockState offerLockState;
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

    /// @notice Event emitted when a sale offer is created
    event SaleOfferCreated(
        uint256 offerId,
        uint256 selling,
        uint8 sellingId,
        uint256 sellFor,
        uint8 sellForId,
        uint256 exRate,
        uint256 repayInSec,
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
    event SaleOfferCollateralAdded(
        uint256 offerId,
        uint256 amount,
        uint256 amountId,
        uint256 timestamp
    );

    /// @notice Event emitted when a sale offer is canceled
    event SaleOfferCanceled(uint256 offerId, uint256 timestamp);

    /// @notice Event emitted when a sale offer is liquidated
    event SaleOfferLiquidated(
        uint256 offerId,
        address liquidator,
        uint256 timestamp
    );

    /// @notice Event emitted when a sale offer is repaid
    event SaleOfferRepaid(
        uint256 offerId,
        uint256 amount,
        uint8 amountId,
        bool byPart,
        uint256 timestamp
    );

    /// @notice Event emitted when a sale offer is forfeited
    event SaleOfferForfeited(uint256 offerId, uint256 timestamp);

    /// @notice Event emitted when a buy offer is created
    event BuyOfferCreated(
        uint256 offerId,
        uint256 buying,
        uint8 buyingId,
        uint256 buyFor,
        uint8 buyForId,
        uint256 exRate,
        uint8 collateralId,
        uint256 repayInSec,
        address buyer,
        uint256 timestamp
    );

    /// @notice Event emitted when a buy offer is accepted
    event BuyOfferAccepted(uint256 offerId, address seller, uint256 timestamp);

    /// @notice Event emitted when collateral is added to a buy offer
    event BuyOfferCollateralAdded(
        uint256 offerId,
        uint256 amount,
        uint8 amountId,
        uint256 timestamp
    );

    /// @notice Event emitted when a buy offer is canceled
    event BuyOfferCanceled(uint256 offerId, uint256 timestamp);

    /// @notice Event emitted when a buy offer is liquidated
    event BuyOfferLiquidated(
        uint256 offerId,
        address liquidator,
        uint256 timestamp
    );

    /// @notice Event emitted when a buy offer is repaid
    event BuyOfferRepaid(
        uint256 offerId,
        uint256 amount,
        uint8 amountId,
        bool byPart,
        uint256 timestamp
    );

    /// @notice Event emitted when a buy offer is forfeited
    event BuyOfferForfeited(uint256 offerId, uint256 timestamp);

    /** @dev Modifier used to protect from reentrancy.
        Called when a function changing the state of a sale offer struct is entered,
        it prevents changes made to the struct by anyone aside from the current msg.sender.
        It differs from the nonReentrant modifier, 
        as the latter restricts only the msg.sender from calling other functions in the contract.
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
