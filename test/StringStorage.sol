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

    function test_SignData() external {
        // Make Eve the caller for this test suite
        vm.startPrank({ msgSender: users.eve.user });

        uint256 privateKey = uint256(0x45d9991fa6e6015f7b6b64612aef0e25a27bdac5dc88b4784723256bda2c24a6);
        string memory data = "test";
        bytes memory signature =
            hex"36ad41d5cfc7e42d06272b3d92dd997079231a6064a092dbceb915aa4bd1b48a10c148d154d58907845f09600a3a075102d918b064bce745357882719257eba7";

        bytes memory generatedSignature = stringStorage.signData(privateKey, data);

        assertEq(generatedSignature, signature);
    }

    modifier givenSignatureProvided() {
        _;
    }

    function test_AuthenticatedSetString() external givenSignatureProvided {
        // Make Eve the caller for this test suite
        vm.startPrank({ msgSender: users.eve.user });

        string memory data = "test";
        bytes memory sig =
            hex"36ad41d5cfc7e42d06272b3d92dd997079231a6064a092dbceb915aa4bd1b48a10c148d154d58907845f09600a3a075102d918b064bce745357882719257eba7";

        bytes memory publicKey = hex"023af2066249340f16af8acc4ec2d72e8737e1a445383332ce5881980738271fd7";

        // Expect to emit the {StringSet} event once a string is set
        vm.expectEmit({ emitter: address(stringStorage) });
        emit StringSet({ sender: users.eve.user, signature: sig, data: data });

        // Run the test
        stringStorage.setString({ data: data, signature: sig, publicKey: publicKey });
    }

    modifier givenSignatureNotProvided() {
        _;
    }

    function test_UnauthenticatedSetString() public givenSignatureNotProvided {
        // Make Bob the caller for this test suite
        vm.startPrank({ msgSender: users.bob.user });

        // Set the desired string
        string memory data = "testStringBob";

        // Expect to emit the {StringSet} event once a string is set
        vm.expectEmit({ emitter: address(stringStorage) });
        emit StringSet({ sender: users.bob.user, signature: "", data: data });

        // Run the test
        stringStorage.setString({ data: data, signature: "", publicKey: "" });

        // Test if the string was correctly set
        string memory storedData = stringStorage.getString({ signature: "" });
        assertEq(storedData, data);
    }
}
