// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title SpectrrPrices
/// @author Supergrayfly
/// @notice Fetches the prices of various currency pairs from Chainlink price feed oracles
contract SpectrrPrices {
    function getChainlinkPrice(
        address _chainlinkAddr
    ) public view returns (int256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_chainlinkAddr);

        (, int256 price,,, ) = priceFeed
            .latestRoundData();

        require(price > 0, "Price is negative");

        return price;
    }
}
