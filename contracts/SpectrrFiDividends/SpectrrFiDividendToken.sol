// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.8.7 <0.9.0;

import "./base/ERC20Dividends.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title SpectrrFiDividendToken
/// @author Supergrayfly
/// @notice ERC20Dividends token contract representing the shares of fees generated by Spectrr Finance.
/// For each tradable token on SpectrrFi (e.g. wBTC), there will be a matching Dividend Token (e.g. SpectrrFi Dividend Btc or SBtc)
contract SpectrrFiDividendToken is ERC20Dividends, Ownable, ReentrancyGuard {
    /// @notice The address of the ERC20 contract in which dividends will be paid in
    address public immutable paymentTokenAddress;

    event DividendsCollected(address _receiver, uint256 _amount);

    /// @dev ERC20Dividends constructor
    /// @dev Mints the initial supply to msg.sender
    /// @dev Transfers the ownership from msg.sender to the SpectrrFi Contract address,
    /// since fees will be generated and distributed by that contract.
    /// @dev Sets the address of the ERC20 contract in which dividends will be paid in
    constructor(
        string memory _dividendTokenName,
        string memory _dividendTokenSymbol,
        uint256 _dividendTokenSupply,
        address _paymentTokenAddress,
        address _spectrrFiContractAddress
    ) ERC20Dividends(_dividendTokenName, _dividendTokenSymbol) {
        _mint(msg.sender, _dividendTokenSupply);
        transferOwnership(_spectrrFiContractAddress);
        paymentTokenAddress = _paymentTokenAddress;
    }

    /// @notice Distribute dividends to all SpectrrDividendToken Holders
    /// @dev OnlyOwner modifier restricts call to only the SpectrrFi Contract Address
    /// @param _amount The amount to distribute between SpectrrFiDividendToken holders
    function distributeDividends(uint256 _amount) external onlyOwner {
        _distributeDividends(_amount);
    }

    /// @notice Collect dividends by shareholders
    /// @notice Dividends of an account can only be withdrawn by SpectrrDividendToken holders
    /// @dev Token transfer reverts if dividends are 0
    /// @param _account The account to which dividends will be sent
    function collectDividends(address _account) external nonReentrant {
        require(msg.sender == _account, "Invalid Sender");

        uint256 dividends = _prepareCollect(_account);

        if (dividends > 0) {
            IERC20(paymentTokenAddress).transfer(msg.sender, dividends);
        } else {
            revert("No available dividends");
        }

        emit DividendsCollected(_account, dividends);
    }
}
