// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.8.7 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SpectrrManager
/// @author Supergrayfly
/// @notice This contract handles functions that can only be called by the dev address (e.g.: Adding new tradable tokens).
contract SpectrrManager is Ownable {
    /** @notice Fee corresponding to 0.1% (100 / 0.1 = 1000),
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
        string name;
        uint8 id;
        uint8 decimals;
        uint8 chainlinkPriceDecimals;
        address dividendContractAddress;
        address chainlinkOracleAddress;
        address addr;
    }

    /// @notice Event emitted when a new token is added
    event NewTokenAdded(
        uint8 tokenId,
        string tokenName,
        address tokenAddress,
        address dividendTokenContractAddress,
        address chainlinkOracleAddress
    );

    /// @notice Adds a token to the array of tokens tradable by this contract
    /// @dev Only callable by owner
    /// @param _tokenName Name of the token to add in the format: "wbtc"
    /// @param _tokenAddress Address of the token
    /// @param _chainlinkOracleAddress Address of the chainlink contract used to take the price from
    /// @param _chainlinkOracleDecimals Number of decimals the chainlink price has
    /// @param _decimals Number of decimals the token contract has
    function addToken(
        string memory _tokenName,
        address _tokenAddress,
        address _chainlinkOracleAddress,
        address _dividendContractAddress,
        uint8 _chainlinkOracleDecimals,
        uint8 _decimals
    ) external onlyOwner {
        uint8 id = ++tokenCount;

        Token memory token = Token(
            _tokenName,
            id,
            _decimals,
            _chainlinkOracleDecimals,
            _dividendContractAddress,
            _chainlinkOracleAddress,
            _tokenAddress
        );

        tokens[id] = token;

        emit NewTokenAdded(
            id,
            _tokenName,
            _tokenAddress,
            _dividendContractAddress,
            _chainlinkOracleAddress
        );
    }

    /// @notice Changes the address of the chainlink oracle of a token
    /// @dev Only callable by the current owner
    /// @param _tokenId id of the token we want to change the oracle address
    /// @param _newChainlinkOracleAddress address of the new chainlink oracle
    function changeChainlinkOracleAddress(
        uint8 _tokenId,
        address _newChainlinkOracleAddress
    ) external onlyOwner {
        require(_tokenId > 0 && _tokenId <= tokenCount, "Invalid Id");
        require(_newChainlinkOracleAddress != address(0), "Address is Zero");

        tokens[_tokenId].chainlinkOracleAddress = _newChainlinkOracleAddress;
    }
}
