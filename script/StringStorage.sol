// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseScript } from "./Base.s.sol";
import "../src/StringStorage.sol";

// Run this script by "forge script script/StringStorage.s.sol --rpc-url sepolia"
contract StringStorageScript is BaseScript {
    function run() public broadcast returns (StringStorage stringStorage) {
        // Deploy the the {StringStorage} contract instance
        stringStorage = new StringStorage();
    }
}
