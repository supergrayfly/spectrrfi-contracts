// SPDX-License-Identifier: BSD-3-Clause-Attribution
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/// @title SpectrrPaymentSplitter
/// @author Supergrayfly
/// @notice This contract receives and distributes the fees genrated by Spectrr Finance to different receivers.
contract SpectrrPaymentSplitter is PaymentSplitter {
    address[] private receivers = [
        0x5B69571405eDa0Fa3A1fF84C7b7B7EC61c6cc752,
        0xffbea2BDe6BE5c88506e4f450DB646F71ef58a30,
        0xAfA85Cb51f4dA448F2EF438F5cDe06831E4abEB8
    ];
    uint256[] private receiversShares = [40, 30, 30];

    constructor() PaymentSplitter(receivers, receiversShares) {}
}
