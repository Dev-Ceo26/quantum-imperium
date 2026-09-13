# Nonce Recovery Engine — Quantum Imperium

Questo modulo implementa il **Nonce Recovery Engine** e l'**Expiry Engine** di Quantum Imperium.

## Come Funziona
TX nonce 10
│
▼
PENDING (nella mempool)
│
├── Se inclusa in un blocco entro l'expiry
│ │
│ ▼
│ CONFIRMED (nonce 10 consumato)
│
└── Se NON inclusa entro l'expiry
│
▼
EXPIRED (nonce 10 rilasciato)
│
▼
Nonce 11 può procedere

text

## Stati dei Nonce

| Stato | Descrizione |
| :--- | :--- |
| **FREE** | Nonce non ancora usato |
| **PENDING** | TX in mempool, nonce consumato ma non confermato |
| **CONFIRMED** | TX inclusa in un blocco |
| **EXPIRED** | TX scaduta, nonce rilasciato (consumed/expired) |

## Componenti

| File | Descrizione |
| :--- | :--- |
| `nonce_manager.py` | Gestisce lo stato dei nonce |
| `expiry_engine.py` | Controlla le TX scadute |
| `config.json` | Configurazione |

## Avvio

```bash
cd nonce_engine
python3 expiry_engine.py
Configurazione
Modifica config.json:

json
{
  "rpc_url": "http://localhost:30334",
  "poll_interval": 5,
  "default_expiry": 86400,
  "max_pending_txs": 10000
}
Quantum Imperium Core Team — Settembre 2026
