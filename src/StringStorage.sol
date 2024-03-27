// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StringStorage {
    /// @dev Mapping to store strings for each caller
    mapping(address caller => string) public stringData;

    /// @notice Emitted when a string is set
    event StringSet(address indexed sender, string data);

    /// @notice Sets and updates a string for a {msg.sender}
    /// @param _data The string value
    function setString(string memory _data) external {
        // Save the string against the sender's address
        stringData[msg.sender] = _data;

        // Emit an event to log the action
        emit StringSet(msg.sender, _data);
    }

    /// @notice Retrieves the saved string of the caller
    /// @return The string data
    function getString() external view returns (string memory) {
        return stringData[msg.sender];
    }
}
