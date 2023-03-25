// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.8.7 <0.9.0;

interface ISpectrrDividendToken {
		function distributeDividends(uint256 amount) external;

    function collectDividends(address account) external;
}
