// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title GuardianRegistry
 * @notice Registro dei Guardian di Quantum Imperium.
 * @dev NESSUN owner umano. La governance è il Timelock della DAO
 *      tramite GOVERNOR_ROLE.
 */
contract GuardianRegistry is AccessControl, ReentrancyGuard {
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    struct Guardian {
        address addr;
        bytes32 publicKey;
        uint256 stakedAmount;
        uint256 registeredAt;
        bool active;
    }

    uint256 public minStake;
    uint256 public unstakeCooldown = 7 days;

    mapping(address => Guardian) public guardians;
    address[] public guardianList;
    mapping(address => uint256) public unstakeRequestedAt;

    event GuardianRegistered(address indexed guardian, bytes32 publicKey, uint256 stake);
    event GuardianSlashed(address indexed guardian, uint256 amount, bytes32 reason);
    event GuardianDeactivated(address indexed guardian);
    event MinStakeUpdated(uint256 oldValue, uint256 newValue);
    event UnstakeRequested(address indexed guardian, uint256 availableAt);
    event GuardianUnstaked(address indexed guardian, uint256 amount);

    constructor(address governor, uint256 _minStake) {
        require(governor != address(0), "governor zero");
        _grantRole(DEFAULT_ADMIN_ROLE, governor);
        _grantRole(GOVERNOR_ROLE, governor);
        minStake = _minStake;
    }

    // --- Registrazione ---

    function registerGuardian(bytes32 publicKey) external payable {
        require(guardians[msg.sender].addr == address(0), "already registered");
        require(msg.value >= minStake, "stake too low");
        require(publicKey != bytes32(0), "pubkey zero");

        guardians[msg.sender] = Guardian(
            msg.sender,
            publicKey,
            msg.value,
            block.timestamp,
            true
        );
        guardianList.push(msg.sender);

        emit GuardianRegistered(msg.sender, publicKey, msg.value);
    }

    function isActiveGuardian(address who) external view returns (bool) {
        return guardians[who].active;
    }

    // --- Governance (solo DAO/Timelock) ---

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

    function setUnstakeCooldown(uint256 newCooldown)
        external
        onlyRole(GOVERNOR_ROLE)
    {
        unstakeCooldown = newCooldown;
    }

    // --- Unstake (volontario) ---

    function requestUnstake() external {
        require(guardians[msg.sender].active, "not active");
        require(unstakeRequestedAt[msg.sender] == 0, "already requested");

        unstakeRequestedAt[msg.sender] = block.timestamp;
        emit UnstakeRequested(msg.sender, block.timestamp + unstakeCooldown);
    }

    function executeUnstake() external nonReentrant {
        require(unstakeRequestedAt[msg.sender] != 0, "no request");
        require(
            block.timestamp >= unstakeRequestedAt[msg.sender] + unstakeCooldown,
            "cooldown"
        );

        uint256 amount = guardians[msg.sender].stakedAmount;
        require(amount > 0, "nothing to unstake");

        guardians[msg.sender].active = false;
        guardians[msg.sender].stakedAmount = 0;
        unstakeRequestedAt[msg.sender] = 0;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        emit GuardianUnstaked(msg.sender, amount);
    }

    // --- View ---

    function getGuardianCount() external view returns (uint256) {
        return guardianList.length;
    }
}
