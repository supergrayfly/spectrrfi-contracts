// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/// @title SpectrrPaymentSplitter
/// @author Supergrayfly
/// @notice This contract receives and distributes the fees genrated by Spectrr Finance to different receivers.
contract SpectrrPaymentSplitter is PaymentSplitter {
    address[] private receivers = [
        0xb89bfaA5D807dbE1cB1b25747eCb9E6f12fc78a9,
        0x1AFa95c1b0894Fd61bF3C2Bc523E71DeA56f42AF,
        0x94627157C99c05Dc48499A0654F28334a05551Cd
    ];
    uint256[] private receiversShares = [40, 30, 30];

    constructor() PaymentSplitter(receivers, receiversShares) {}
}
