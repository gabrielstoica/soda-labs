// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Abstract contract to store all the events emitted in the tested contracts
abstract contract Events {
    /// @notice Emitted when a string is set
    event StringSet(address indexed sender, bytes signature, string data);
}
