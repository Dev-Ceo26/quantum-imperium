// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ImperiumMessenger.sol";

interface IMintableBurnableToken {
    function mint(address to, uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
}

/**
 * @title ImperiumBridgeChild
 * @notice Lato Imperium (L2) del bridge.
 * @dev NESSUN owner umano. GOVERNOR_ROLE = Timelock della DAO.
 */
contract ImperiumBridgeChild is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    ImperiumMessenger public immutable messenger;
    uint256 public immutable l1ChainId;
    uint256 public immutable thisChainId;

    mapping(address => bool) public supportedTokens;
    mapping(address => address) public localToRemote;
    mapping(address => address) public remoteToLocal;
    mapping(bytes32 => bool) public processedMessages;

    uint256 public withdrawNonce;
    address public feeCollector;
    bool public paused;

    event TokenRegistered(address indexed localToken, address indexed remoteToken);
    event WithdrawalInitiated(
        address indexed withdrawer,
        address indexed recipient,
        address indexed token,
        uint256 amount,
        uint256 nonce,
        bytes32 messageHash
    );
    event DepositFinalized(
        address indexed recipient,
        address indexed token,
        uint256 amount,
        uint256 indexed nonce,
        bytes32 messageHash
    );
    event FeeCollectorUpdated(address oldCollector, address newCollector);
    event Paused(bool state);

    modifier notPaused() {
        require(!paused, "paused");
        _;
    }

    constructor(
        address _messenger,
        uint256 _l1ChainId,
        address _feeCollector,
        address governor
    ) {
        require(_messenger != address(0), "messenger zero");
        require(_feeCollector != address(0), "feeCollector zero");
        require(governor != address(0), "governor zero");

        messenger = ImperiumMessenger(_messenger);
        l1ChainId = _l1ChainId;
        thisChainId = block.chainid;
        feeCollector = _feeCollector;

        _grantRole(DEFAULT_ADMIN_ROLE, governor);
        _grantRole(GOVERNOR_ROLE, governor);
    }

    // --- Governance (solo DAO/Timelock) ---

    function setPaused(bool state) external onlyRole(GOVERNOR_ROLE) {
        paused = state;
        emit Paused(state);
    }

    function setFeeCollector(address newCollector) external onlyRole(GOVERNOR_ROLE) {
        require(newCollector != address(0), "zero");
        emit FeeCollectorUpdated(feeCollector, newCollector);
        feeCollector = newCollector;
    }

    function registerToken(address localToken, address remoteToken)
        external
        onlyRole(GOVERNOR_ROLE)
    {
        require(localToken != address(0) && remoteToken != address(0), "zero token");
        require(remoteToLocal[remoteToken] == address(0), "remote already mapped");
        supportedTokens[localToken] = true;
        localToRemote[localToken] = remoteToken;
        remoteToLocal[remoteToken] = localToken;
        emit TokenRegistered(localToken, remoteToken);
    }

    // --- Utente ---

    function withdrawToL1(address token, address recipient, uint256 amount)
        external
        nonReentrant
        notPaused
    {
        require(recipient != address(0), "recipient zero");
        require(amount > 0, "amount zero");
        require(supportedTokens[token], "token not supported");

        address remoteToken = localToRemote[token];
        require(remoteToken != address(0), "remote not mapped");

        IMintableBurnableToken(token).burnFrom(msg.sender, amount);

        uint256 nonce = ++withdrawNonce;
        bytes32 messageHash = keccak256(
            abi.encode(remoteToken, recipient, amount, nonce, thisChainId, l1ChainId)
        );

        emit WithdrawalInitiated(msg.sender, recipient, token, amount, nonce, messageHash);
    }

    function finalizeDeposit(
        address token,
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 srcChainId,
        bytes[] calldata signatures
    ) external nonReentrant notPaused {
        require(recipient != address(0), "recipient zero");
        require(amount > 0, "amount zero");

        bytes32 messageHash = keccak256(
            abi.encode(token, recipient, amount, nonce, srcChainId, thisChainId)
        );
        require(!processedMessages[messageHash], "already processed");
        require(messenger.verifySignatures(messageHash, signatures), "invalid signatures");

        processedMessages[messageHash] = true;

        address localToken = remoteToLocal[token];
        require(localToken != address(0), "unknown remote token");

        IMintableBurnableToken(localToken).mint(recipient, amount);

        emit DepositFinalized(recipient, localToken, amount, nonce, messageHash);
    }
}
