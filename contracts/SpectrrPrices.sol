// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.8.7 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title SpectrrPrices
/// @author Supergrayfly
/// @notice Fetches the prices of various currency pairs from Chainlink price feed oracles
contract SpectrrPrices {
    /// @notice Gets the price of a token from a chainlink oracle address
    /// @param _chainlinkOracleAddress The address of the chainlink oracle
    function getChainlinkPrice(
        address _chainlinkOracleAddress
    ) public view returns (int256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            _chainlinkOracleAddress
        );

        (, int256 tokenPrice, , , ) = priceFeed.latestRoundData();

        require(tokenPrice > 0, "Price is negative");

        return tokenPrice;
    }
}
