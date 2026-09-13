// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GuardianRegistry is Ownable {
    struct Guardian {
        address addr;
        bytes32 publicKey;
        uint256 stakedAmount;
        uint256 registeredAt;
        bool active;
    }

    uint256 public constant MIN_STAKE = 1000 * 10**18;
    mapping(address => Guardian) public guardians;
    address[] public guardianList;

    event GuardianRegistered(address indexed guardian, bytes32 publicKey);
    event GuardianSlashed(address indexed guardian, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function registerGuardian(bytes32 _publicKey) external {
        require(guardians[msg.sender].addr == address(0), "Already registered");
        guardians[msg.sender] = Guardian(msg.sender, _publicKey, MIN_STAKE, block.timestamp, true);
        guardianList.push(msg.sender);
        emit GuardianRegistered(msg.sender, _publicKey);
    }

    function slashGuardian(address guardian, uint256 amount) external onlyOwner {
        require(guardians[guardian].active && amount <= guardians[guardian].stakedAmount, "Invalid");
        guardians[guardian].stakedAmount -= amount;
        emit GuardianSlashed(guardian, amount);
    }

    function getGuardianCount() external view returns (uint256) {
        return guardianList.length;
    }
}
