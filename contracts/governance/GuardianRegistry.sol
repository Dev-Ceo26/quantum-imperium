// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title GuardianRegistry
 * @notice Registro dei Guardian di Quantum Imperium.
 * @dev NESSUN owner umano. La governance è il Timelock della DAO
 *      tramite GOVERNOR_ROLE.
 */
contract GuardianRegistry is AccessControl {
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    struct Guardian {
        address addr;
        bytes32 publicKey;
        uint256 stakedAmount;
        uint256 registeredAt;
        bool active;
    }

    uint256 public minStake;

    mapping(address => Guardian) public guardians;
    address[] public guardianList;

    event GuardianRegistered(address indexed guardian, bytes32 publicKey, uint256 stake);
    event GuardianSlashed(address indexed guardian, uint256 amount, bytes32 reason);
    event GuardianDeactivated(address indexed guardian);
    event MinStakeUpdated(uint256 oldValue, uint256 newValue);

    constructor(address governor, uint256 _minStake) {
        require(governor != address(0), "governor zero");
        _grantRole(DEFAULT_ADMIN_ROLE, governor);
        _grantRole(GOVERNOR_ROLE, governor);
        minStake = _minStake;
    }

    function registerGuardian(bytes32 publicKey) external payable {
        require(guardians[msg.sender].addr == address(0), "already registered");
        require(msg.value >= minStake, "stake too low");
        require(publicKey != bytes32(0), "pubkey zero");
        guardians[msg.sender] = Guardian(
            msg.sender, publicKey, msg.value, block.timestamp, true
        );
        guardianList.push(msg.sender);
        emit GuardianRegistered(msg.sender, publicKey, msg.value);
    }

    function isActiveGuardian(address who) external view returns (bool) {
        return guardians[who].active;
    }

    function slashGuardian(address guardian, uint256 amount, bytes32 reason)
        external
        onlyRole(GOVERNOR_ROLE)
    {
        Guardian storage g = guardians[guardian];
        require(g.active, "not active");
        require(amount <= g.stakedAmount, "amount too high");
        g.stakedAmount -= amount;
        emit GuardianSlashed(guardian, amount, reason);
    }

    function deactivateGuardian(address guardian)
        external
        onlyRole(GOVERNOR_ROLE)
    {
        require(guardians[guardian].active, "not active");
        guardians[guardian].active = false;
        emit GuardianDeactivated(guardian);
    }

    function setMinStake(uint256 newMin) external onlyRole(GOVERNOR_ROLE) {
        emit MinStakeUpdated(minStake, newMin);
        minStake = newMin;
    }

    function getGuardianCount() external view returns (uint256) {
        return guardianList.length;
    }
}
