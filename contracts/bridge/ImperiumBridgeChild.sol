// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ImperiumBridgeChild is Ownable, Pausable, ReentrancyGuard {
    address public wrappedToken;
    uint256 public threshold;
    address[] public validators;
    mapping(bytes32 => bool) public processedMessages;

    event MintInitiated(bytes32 indexed messageHash, address indexed token, address indexed recipient, uint256 amount, uint256 nonce);
    event WithdrawalInitiated(address indexed token, address indexed sender, uint256 amount, uint256 nonce);

    constructor(address _wrappedToken, address[] memory _validators, uint256 _threshold) {
        require(_threshold > 0 && _threshold <= _validators.length, "Invalid threshold");
        wrappedToken = _wrappedToken;
        validators = _validators;
        threshold = _threshold;
    }

    function mint(address token, address recipient, uint256 amount, uint256 nonce, bytes[] calldata signatures) external whenNotPaused nonReentrant {
        require(signatures.length >= threshold, "Not enough signatures");
        bytes32 messageHash = keccak256(abi.encodePacked(token, recipient, amount, nonce, "MINT"));
        require(!processedMessages[messageHash], "Already processed");
        processedMessages[messageHash] = true;
        ERC20(wrappedToken).mint(recipient, amount);
        emit MintInitiated(messageHash, token, recipient, amount, nonce);
    }

    function withdrawToL1(address token, uint256 amount, uint256 nonce) external whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        ERC20(wrappedToken).burnFrom(msg.sender, amount);
        emit WithdrawalInitiated(token, msg.sender, amount, nonce);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
