// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Base_Test } from "./Base.t.sol";
import "../src/StringStorage.sol";

contract StringStorageTest is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();

        // Make the Deployer the default caller for the setup
        vm.startPrank({ msgSender: users.deployer });

        // Deploy the {StringStorage} instance
        stringStorage = deployStringStorage();

        // Stop the active prank
        vm.stopPrank();
    }

    function test_SetString() public {
        // Make Eve the caller for this test suite
        vm.startPrank({ msgSender: users.eve });

        // Set the desired string
        string memory _data = "testStringEve";

        // Expect to emit the {StringSet} event once a string is set
        vm.expectEmit({ emitter: address(stringStorage) });
        emit StringSet({ sender: users.eve, data: _data });

        // Run the test
        stringStorage.setString(_data);
    }

    function test_GetString() public {
        // Make Bob the caller for this test suite
        vm.startPrank({ msgSender: users.bob });

        // Set the desired string
        string memory _data = "testStringBob";

        // Run the test
        stringStorage.setString(_data);

        // Test if the string was correctly set
        assertEq(stringStorage.getString(), _data);
    }
}
