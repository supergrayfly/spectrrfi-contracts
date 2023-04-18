// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.8.7 <0.9.0;

contract AggregatorV3 {
    int256 private price;

    constructor(int256 _price) {
        price = _price * 10 ** 18;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, price, 0, 0, 0);
    }
}
