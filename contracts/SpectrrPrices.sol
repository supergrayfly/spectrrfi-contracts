// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title SpectrrPrices
/// @author Supergrayfly
/// @notice Fetches the prices of various currency pairs
contract SpectrrPrices {
    /// @notice The maximum timeframe in seconds, at which the price request must be fulfilled.
    uint256 public constant MAX_RESPONSE_TIME = 15;

    function getChainlinkPrice(
        address _chainlinkAddr
    ) public view returns (int256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_chainlinkAddr);

        (, int256 price, uint256 startedAt, uint256 updatedAt, ) = priceFeed
            .latestRoundData();

        checkPrice(price, startedAt, updatedAt);

        return price;
    }

    /// @notice Checks if the price is valid
    /// @dev It firsts ensures that the price is positive, and then if the request was fulfilled in the required time frame.
    /// @param _price Price of the token
    /// @param _startedAt Time at which the request was initiated
    /// @param _timestamp Time at which the request was fulfilled
    function checkPrice(
        int256 _price,
        uint256 _startedAt,
        uint256 _timestamp
    ) internal pure {
        require(_price > 0, "Price is negative");
        require(
            _timestamp - _startedAt <= MAX_RESPONSE_TIME,
            "Time diff too large"
        );
    }
}
