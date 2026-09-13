// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "../governance/GuardianRegistry.sol";

/**
 * @title ImperiumMessenger
 * @notice Verifica le firme dei Guardian per i messaggi cross-chain.
 * @dev Non ha owner. Legge i Guardian dal GuardianRegistry.
 */
contract ImperiumMessenger {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    GuardianRegistry public immutable registry;
    uint256 public immutable threshold;

    constructor(address _registry, uint256 _threshold) {
        require(_registry != address(0), "registry zero");
        require(_threshold > 0, "threshold zero");
        registry = GuardianRegistry(_registry);
        threshold = _threshold;
    }

    /**
     * @notice Verifica che `signatures` contenga almeno `threshold`
     *         firme valide di Guardian attivi, senza duplicati.
     */
    function verifySignatures(
        bytes32 messageHash,
        bytes[] calldata signatures
    ) external view returns (bool) {
        if (signatures.length < threshold) return false;

        bytes32 ethHash = messageHash.toEthSignedMessageHash();
        address[] memory seen = new address[](threshold);
        uint256 valid = 0;

        for (uint256 i = 0; i < signatures.length; i++) {
            address signer = ethHash.recover(signatures[i]);

            if (!registry.isActiveGuardian(signer)) continue;

            bool duplicate = false;
            for (uint256 j = 0; j < valid; j++) {
                if (seen[j] == signer) {
                    duplicate = true;
                    break;
                }
            }
            if (duplicate) continue;

            seen[valid] = signer;
            valid++;

            if (valid >= threshold) return true;
        }
        return false;
    }
}
