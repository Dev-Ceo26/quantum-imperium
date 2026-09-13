// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ImperiumBridgeRoot is Ownable, Pausable, ReentrancyGuard {
    address[] public validators;
    uint256 public threshold;
    mapping(bytes32 => bool) public processedMessages;
    mapping(address => uint256) public maxAmountPerTx;

    event DepositInitiated(address indexed token, address indexed sender, uint256 amount, uint256 nonce);
    event WithdrawalExecuted(bytes32 indexed messageHash, address indexed token, address indexed recipient, uint256 amount);

    constructor(address[] memory _validators, uint256 _threshold) {
        require(_threshold > 0 && _threshold <= _validators.length, "Invalid threshold");
        validators = _validators;
        threshold = _threshold;
    }

    function deposit(address token, uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0 && amount <= maxAmountPerTx[token], "Invalid amount");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 nonce = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, amount)));
        emit DepositInitiated(token, msg.sender, amount, nonce);
    }

    function executeWithdrawal(address token, address recipient, uint256 amount, uint256 nonce, bytes[] calldata signatures) external whenNotPaused nonReentrant {
        require(signatures.length >= threshold, "Not enough signatures");
        bytes32 messageHash = keccak256(abi.encodePacked(token, recipient, amount, nonce));
        require(!processedMessages[messageHash], "Already processed");
        processedMessages[messageHash] = true;
        IERC20(token).transfer(recipient, amount);
        emit WithdrawalExecuted(messageHash, token, recipient, amount);
    }

    function setMaxAmountPerTx(address token, uint256 amount) external onlyOwner {
        maxAmountPerTx[token] = amount;
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
