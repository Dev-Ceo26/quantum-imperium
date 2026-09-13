# Contributing to Quantum Imperium

Grazie per il tuo interesse nel contribuire a **Quantum Imperium**! Questo documento spiega come partecipare al progetto.

---

## 📋 Codice di Condotta

Tutti i contributori sono tenuti a rispettare il nostro Codice di Condotta:

- **Rispetto**: Tratta tutti con rispetto, indipendentemente dal background.
- **Collaborazione**: Lavora insieme agli altri per migliorare il progetto.
- **Trasparenza**: Comunica apertamente le tue intenzioni e i tuoi risultati.
- **Sicurezza**: Segnala vulnerabilità in modo responsabile.

---

## 🚀 Come Contribuire

### 1. Segnalare un Bug

Prima di aprire una issue, verifica che il bug non sia già stato segnalato. Se non lo è:

1. Vai su [Issues](https://github.com/Dev-Ceo26/quantum-imperium/issues).
2. Clicca su "New Issue".
3. Descrivi il bug in dettaglio.

### 2. Proporre una Feature

1. Apri una issue con etichetta `enhancement`.
2. Descrivi la feature e perché sarebbe utile.
3. Attendi il feedback dei maintainer.

### 3. Inviare una Pull Request

1. Fai un fork del repository.
2. Crea un branch per la tua modifica.
3. Apporta le modifiche.
4. Testa le modifiche.
5. Committa con un messaggio chiaro.
6. Pusha il branch.
7. Apri una Pull Request su GitHub.

---

## 🧪 Test

Prima di inviare una PR, assicurati che tutti i test passino:

```bash
forge test
cd sentinels && python3 -m pytest
📁 Struttura del Progetto
text
quantum_chain/
├── contracts/          # Smart contract
├── docs/               # Documentazione
├── genesis/            # File genesis
├── scripts/            # Script di installazione
├── sentinels/          # Sentinelle AI
└── test/               # Test
🎯 Aree di Contribuzione
Area	Competenze	Priorità
Contratti Solidity	Solidity, Foundry	Alta
Sentinelle AI	Python, AI/ML	Alta
Relayer	Python, Web3	Alta
Documentazione	Markdown	Media
Frontend	HTML/CSS/JS	Media
Test	Python, Foundry	Alta
🔐 Sicurezza
Se trovi una vulnerabilità critica, non aprire una issue pubblica. Invia una email a:

text
security@imperiumscan.com
📜 Licenza
Contribuendo, accetti che le tue modifiche siano rilasciate sotto la licenza MIT.

Quantum Imperium Core Team — 2026
ENDOFFILE

echo "✅ CONTRIBUTING.md creato"
ls -la CONTRIBUTING.md

text

**3. Crea `relayer/relayer.py` (senza `!` all'inizio, usa `#!/usr/bin/env` con apice singolo):**

```bash
cat > relayer/relayer.py << 'ENDOFFILE'
#!/usr/bin/env python3
"""
Relayer per il bridge Quantum Imperium ed Ethereum.
Ascolta gli eventi e porta i messaggi tra le due chain.
NON ha potere di firma: le firme vengono dai Guardian.
"""
import json
import time
import logging
from web3 import Web3

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [RELAYER] %(levelname)s: %(message)s'
)
logger = logging.getLogger("Relayer")

class ImperiumRelayer:
    def __init__(self, config):
        self.eth_rpc = config['eth_rpc']
        self.imperium_rpc = config['imperium_rpc']
        self.eth_bridge = config['eth_bridge_address']
        self.imperium_bridge = config['imperium_bridge_address']
        self.validators = config['validators']
        self.poll_interval = config.get('poll_interval', 10)
        self.eth_w3 = Web3(Web3.HTTPProvider(self.eth_rpc))
        self.imperium_w3 = Web3(Web3.HTTPProvider(self.imperium_rpc))
        self.last_eth_block = 0
        self.last_imperium_block = 0

    def listen_ethereum(self):
        try:
            current_block = self.eth_w3.eth.block_number
            if self.last_eth_block == 0:
                self.last_eth_block = current_block
                return
            for block_num in range(self.last_eth_block + 1, current_block + 1):
                block = self.eth_w3.eth.get_block(block_num, full_transactions=True)
                for tx in block.transactions:
                    if tx.to and tx.to.lower() == self.eth_bridge.lower():
                        logger.info(f"Deposito rilevato: {tx.hash.hex()}")
                        self.request_signatures('MINT', {'tx_hash': tx.hash.hex()})
            self.last_eth_block = current_block
        except Exception as e:
            logger.error(f"Errore in listen_ethereum: {e}")

    def listen_imperium(self):
        try:
            current_block = self.imperium_w3.eth.block_number
            if self.last_imperium_block == 0:
                self.last_imperium_block = current_block
                return
            for block_num in range(self.last_imperium_block + 1, current_block + 1):
                block = self.imperium_w3.eth.get_block(block_num, full_transactions=True)
                for tx in block.transactions:
                    if tx.to and tx.to.lower() == self.imperium_bridge.lower():
                        logger.info(f"Prelievo rilevato: {tx.hash.hex()}")
                        self.request_signatures('RELEASE', {'tx_hash': tx.hash.hex()})
            self.last_imperium_block = current_block
        except Exception as e:
            logger.error(f"Errore in listen_imperium: {e}")

    def request_signatures(self, action, data):
        signatures = []
        for validator in self.validators:
            try:
                logger.info(f"Richiesta firma a {validator} per {action}")
            except Exception as e:
                logger.error(f"Errore: {e}")
        return signatures

    def run(self):
        logger.info("=== RELAYER AVVIATO ===")
        while True:
            self.listen_ethereum()
            self.listen_imperium()
            time.sleep(self.poll_interval)

if __name__ == '__main__':
    with open('relayer/config.json', 'r') as f:
        config = json.load(f)
    relayer = ImperiumRelayer(config)
    relayer.run()
