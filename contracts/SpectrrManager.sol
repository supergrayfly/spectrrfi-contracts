// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SpectrrManager
/// @author Supergrayfly
/// @notice This contracrt handles functions that can only be called by the dev address (e.g.: Adding new tradable tokens).
contract SpectrrManager is Ownable {
    /// @notice address where transaction fees will be sent
    address public feeAddr = 0x29AA18b166FF8B1C67c8A1f12CDB487080068128;

    /** @notice Fee corresponding to 0.1% (amount * (100 / 0.1) = amount * 1000),
				taken from every accept sale/buy offer transaction.
        In the case of a sale offer it is paid by the buyer.
        In the case of a buy offer it is paid by the seller.
    */
    uint16 public constant FEE_PERCENT = 1000;

    /// @notice The number of tokens tradable by this contract
    /// @dev Used as a counter for the tokens mapping
    uint8 public tokenCount = 0;

    /// @dev Map of the number of tokens and Token struct
    mapping(uint8 => Token) public tokens;

    /// @dev Token struct, containing info on a ERC20 token
    struct Token {
        uint8 tokenId;
        uint8 priceDecimals;
        string tokenName;
        IERC20 Itoken;
        address tokenAddr;
        address chainlinkAddr;
    }

    /// @notice Event emitted when a new token is added
    event NewToken(
        uint8 tokenId,
        string name,
        address tokenAddr,
        address chainlinkAddr
    );

    /// @notice Event emitted when the fee address is changed
    event FeeAddrChanged(address newAddr, uint256 timestamp);

    /// @notice Adds a token to the array of tokens tradable by this contract
    /// @dev Only callable by owner
    /// @param _tokenName Name of the token to add in the following format: "btc"
    /// @param _tokenAddr Address of the token
    /// @param _chainlinkAddr Address of the chainlink contract used to take the price from
    /// @param _priceDecimals Number of decimals the chainlink price has
    function addToken(
        string memory _tokenName,
        address _tokenAddr,
        address _chainlinkAddr,
        uint8 _priceDecimals
    ) external onlyOwner {
        uint8 id = ++tokenCount;

        IERC20 Itoken = IERC20(_tokenAddr);

        Token memory token = Token(
            id,
            _priceDecimals,
            _tokenName,
            Itoken,
            _tokenAddr,
            _chainlinkAddr
        );

        tokens[id] = token;

        emit NewToken(id, _tokenName, _tokenAddr, _chainlinkAddr);
    }

    /// @notice Changes the fee address
    /// @dev Only callable by the current owner
    function changeFeeAddr(address _newFeeAddr) external onlyOwner {
        feeAddr = _newFeeAddr;

        emit FeeAddrChanged(_newFeeAddr, block.timestamp);
    }
}
