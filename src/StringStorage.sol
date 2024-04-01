// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Vm } from "forge-std/Vm.sol";

contract StringStorage {
    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Precompiled contract address to verify Schnorr signatures
    address public immutable VERIFY_SCHNORR_SIG_PRECOMPILE = address(0x0000000000000000000000000000000000000101);

    /// @dev Precompiled contract address to sign using the Schnorr scheme
    address public immutable SIGN_SCHNORR_PRECOMPILE = address(0x0000000000000000000000000000000000000102);

    /*//////////////////////////////////////////////////////////////////////////
                                  PRIVATE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    // Only for testing purposes
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Mapping to store strings for each caller
    mapping(address caller => mapping(bytes signature => string)) public stringDataWithSignature;

    /// @dev Mapping to store strings for each caller
    mapping(address caller => string) public stringData;

    /*//////////////////////////////////////////////////////////////////////////
                                     EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a string is set
    event StringSet(address indexed sender, bytes signature, string data);

    /*//////////////////////////////////////////////////////////////////////////
                                     ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the call to get a Schnorr signature failed
    error SchnorrSignPrecompileCallFailed();

    /// @notice Thrown when the call to verify the Schnorr signature failed
    error SchnorrVerifyPrecompileCallFailed();

    /// @notice Thrown when the Schnorr signature is not valid
    error InvalidSignature();

    /// @notice Thrown when the public key has an invalid format
    error InvalidPublicKey();

    /*//////////////////////////////////////////////////////////////////////////
                                USER-FACING METHODS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Sets multiple authenticated strings per user based on their Schnorr signatures or
    /// only one unauthenticated string if a signature is not provided
    ///
    /// Notes:
    /// - If provided, the public key must be in the compressed form:
    /// - 0x{prefix}{X} where {prefix} can be {02} if the Y is even or {03} if odd
    /// - {X} and {Y} are the coordinates of the public key P(x,y) point
    ///
    /// @param data The string value
    /// @param signature The Schnorr signature (64 bytes) computed over the keccak256 hash of the string (optional)
    /// @param publicKey The ECDSA secp256k1 public key (33 bytes) (optional)
    function setString(string calldata data, bytes calldata signature, bytes calldata publicKey) external {
        // Check if a signature is provided
        if (signature.length != 0) {
            // Check if the public key has the correct format
            if (publicKey.length != 33) {
                revert InvalidPublicKey();
            }

            // Compute the keccak256 hash over the string
            bytes32 dataHash = keccak256(abi.encodePacked(data));

            // Call the precompiled-contract responsible for validating the Schnorr signature
            (bool ok, bytes memory isValid) =
                VERIFY_SCHNORR_SIG_PRECOMPILE.staticcall(abi.encodePacked(publicKey, dataHash));

            // Revert if call failed with an error (i.e. invalid input length)
            if (!ok) revert SchnorrVerifyPrecompileCallFailed();

            // Revert if signature is not valid
            if (uint256(bytes32(isValid)) != 1) {
                revert InvalidSignature();
            }

            // Save the string against the sender's address and signature
            stringDataWithSignature[msg.sender][signature] = data;
        } else {
            // Otherwise save the string directly against the sender's address
            stringData[msg.sender] = data;
        }

        // Emit an event to log the action
        emit StringSet(msg.sender, signature, data);
    }

    /// @notice Generates a Schnorr signature over a string using the user's private key
    /// @param privateKey The ECDSA secp256k1 private key
    /// @param data The string over which the signature is computed
    function signData(uint256 privateKey, string calldata data) external view returns (bytes memory) {
        // Compute the keccak256 hash over the string
        bytes32 dataHash = keccak256(abi.encodePacked(data));

        // Call the precompiled-contract responsible for generating the Schnorr signature
        (bool ok, bytes memory signature) = SIGN_SCHNORR_PRECOMPILE.staticcall(abi.encode(privateKey, dataHash));

        // Revert if call failed with an error (i.e. invalid input length)
        if (!ok) revert SchnorrSignPrecompileCallFailed();

        return signature;
    }

    /// @notice Returns the Schnorr-authenticated string(s) stored by the user if a signature is provided, otherwise retrieves the unauthenticated one
    /// @param signature The Schnorr signature over the requested string
    /// @return The string data
    function getString(bytes calldata signature) external view returns (string memory) {
        // Check if a signature is passed and return the associated string
        if (signature.length != 0) {
            return stringDataWithSignature[msg.sender][signature];
        }

        // Otherwise return the unauthenticated string
        return stringData[msg.sender];
    }

    /// @notice Returns the public key derived from the private key
    /// @param privateKey The ECDSA secp256k1 private key
    /// @return The ECDSA secp256k1 compressed public key
    function derivePublicKey(uint256 privateKey) external returns (bytes memory) {
        Vm.Wallet memory wallet = vm.createWallet(privateKey);

        bytes1 compressionByte = wallet.publicKeyY % 2 == 0 ? bytes1(0x02) : bytes1(0x03);
        return abi.encodePacked(compressionByte, wallet.publicKeyX);
    }
}
