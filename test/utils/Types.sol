// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Users {
    // Deployer account
    address payable deployer;
    // Eve's account
    UserWithKey eve;
    // Bob's account
    UserWithKey bob;
}

struct UserWithKey {
    address payable user;
    uint256 key;
}
