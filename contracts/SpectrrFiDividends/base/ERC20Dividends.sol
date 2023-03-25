// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20VotesComp.sol";
import "./AbstractDividends.sol";

/************************************************************************************************
Originally from https://github.com/indexed-finance/dividends/blob/master/contracts/base/ERC20Dividends.sol
This source code has been modified from the original, which was copied from the github repository
at commit hash 698b9c3f0c10e2c15d2572dbb18492509ef316d8.
Subject to the MIT license
*************************************************************************************************/

contract ERC20Dividends is ERC20VotesComp, AbstractDividends {
    constructor(
        string memory name,
        string memory symbol
    )
        ERC20Permit(name)
        ERC20(name, symbol)
        ERC20VotesComp()
        AbstractDividends(balanceOf, totalSupply)
    {}

    /**
     * @dev Internal function that transfer tokens from one address to another.
     * Update pointsCorrection to keep funds unchanged.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(
        address from,
        address to,
        uint96 value
    ) internal virtual {
        super._transfer(from, to, value);
        _correctPointsForTransfer(from, to, value);
    }

    /**
     * @dev Internal function that mints tokens to an account.
     * Update pointsCorrection to keep funds unchanged.
     * @param account The account that will receive the created tokens.
     * @param amount The amount that will be created.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        _correctPoints(account, -int256(amount));
    }

    /**
     * @dev Internal function that burns an amount of the token of a given account.
     * Update pointsCorrection to keep funds unchanged.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);
        _correctPoints(account, int256(amount));
    }
}
