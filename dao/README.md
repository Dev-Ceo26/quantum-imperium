# Imperium DAO — Quantum Imperium

La DAO di Quantum Imperium è l'organo di governance on-chain del progetto.

## Caratteristiche

| Parametro | Valore |
| :--- | :--- |
| **Voting Delay** | 1 giorno |
| **Voting Period** | 7 giorni |
| **Quorum** | 30% dei voti |
| **Timelock Delay** | 2 giorni |
| **Token di Governance** | IMP |

## Flusso di Governance
Community → Proposal → Validator + Guardian Vote → Quorum → Activation Height → Protocol Upgrade

text

## Tipi di Proposta

| Categoria | Quorum | Esempi |
| :--- | :--- | :--- |
| **Upgrade normale** | 50% | Nuove feature |
| **Parametri economici** | 60% | Fee, reward, stake |
| **Consensus-critical** | 75% | Modifiche al consenso |
| **Emergency/Security** | 80% | Patch di sicurezza |

## Deploy

```bash
forge create dao/ImperiumDAO.sol:ImperiumDAO \
  --rpc-url https://rpc-testnet.imperiumscan.com \
  --private-key $PRIVATE_KEY \
  --legacy \
  --gas-price 1000000000 \
  --broadcast
Quantum Imperium Core Team — Settembre 2026
