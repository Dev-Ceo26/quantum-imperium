# Architettura del Bridge Imperium ↔ Ethereum

## Panoramica

Il bridge collega Imperium Chain a Ethereum con un modello **Multi-sig 4/7**.

## Componenti

- **ImperiumBridgeRoot.sol** (Ethereum): Lock/Release
- **ImperiumBridgeChild.sol** (Imperium): Mint/Burn
- **Relayer** (off-chain): Trasporta messaggi

## Sicurezza

| Misura | Descrizione |
| :--- | :--- |
| Soglia 4/7 | Almeno 4 validatori su 7 |
| Nonce univoci | Ogni messaggio ha un nonce |
| processedMessages | Evita replay |
| Pausa | Contratto pausabile |

---

**Imperium Chain Core Team — 2026**
