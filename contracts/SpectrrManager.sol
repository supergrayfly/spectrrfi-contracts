// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SpectrrManager
/// @author Supergrayfly
/// @notice This contract handles functions that can only be called by the dev address (e.g.: Adding new tradable tokens).
contract SpectrrManager is Ownable {
    /// @notice address where transaction fees will be sent
    address public feeAddress = 0x35A6F13710087492F0F0146F8471117c9cB22E18;

    /** @notice Fee corresponding to 0.1% (amount * (100 / 0.1) = 1000,
				taken when an offer is created and accepted.
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
        uint8 decimals;
        string tokenName;
        address tokenAddress;
        address chainlinkOracleAddress;
        IERC20 Itoken;
    }

    /// @notice Event emitted when a new token is added
    event NewTokenAdded(
        uint8 tokenId,
        string tokenName,
        address tokenAddress,
        address chainlinkOracleAddress
    );

    /// @notice Event emitted when the fee address is changed
    event FeeAddressChanged(address newAddress);

    /// @notice Adds a token to the array of tokens tradable by this contract
    /// @dev Only callable by owner
    /// @param _tokenName Name of the token to add in the following format: "btc"
    /// @param _tokenAddress Address of the token
    /// @param _chainlinkOracleAddress Address of the chainlink contract used to take the price from
    /// @param _decimals Number of decimals the chainlink price has
    function addToken(
        string memory _tokenName,
        address _tokenAddress,
        address _chainlinkOracleAddress,
        uint8 _decimals
    ) external onlyOwner {
        uint8 id = ++tokenCount;

        IERC20 Itoken = IERC20(_tokenAddress);

        Token memory token = Token(
            id,
            _decimals,
            _tokenName,
            _tokenAddress,
            _chainlinkOracleAddress,
            Itoken
        );

        tokens[id] = token;

        emit NewTokenAdded(
            id,
            _tokenName,
            _tokenAddress,
            _chainlinkOracleAddress
        );
    }

    /// @notice Changes the fee address
    /// @dev Only callable by the current owner
    /// @param _newFeeAddress The new fee address
    function changeFeeAddress(address _newFeeAddress) external onlyOwner {
        feeAddress = _newFeeAddress;
        emit FeeAddressChanged(_newFeeAddress);
    }
}
