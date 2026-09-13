#!/usr/bin/env python3
"""
Nonce Manager — Gestisce lo stato dei nonce per Quantum Imperium.

Stati possibili:
- PENDING: TX in mempool, nonce consumato ma non confermato
- CONFIRMED: TX inclusa in un blocco, nonce consumato
- EXPIRED: TX scaduta, nonce rilasciato (consumed/expired)
- FREE: nonce non ancora usato
"""
import json
import time
import logging
from typing import Dict, Optional
from enum import Enum

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [NONCE-MANAGER] %(levelname)s: %(message)s'
)
logger = logging.getLogger("NonceManager")

class NonceState(Enum):
    FREE = "free"
    PENDING = "pending"
    CONFIRMED = "confirmed"
    EXPIRED = "expired"

class NonceManager:
    def __init__(self, config):
        self.rpc_url = config['rpc_url']
        self.default_expiry = config.get('default_expiry', 86400)
        self.nonces: Dict[str, Dict[int, Dict]] = {}  # address -> nonce -> state
        self.pending_txs: Dict[str, Dict] = {}  # tx_hash -> tx_info

    def get_nonce_state(self, address: str, nonce: int) -> NonceState:
        """Restituisce lo stato di un nonce per un indirizzo."""
        if address not in self.nonces:
            return NonceState.FREE
        if nonce not in self.nonces[address]:
            return NonceState.FREE
        return NonceState(self.nonces[address][nonce]['state'])

    def set_nonce_state(self, address: str, nonce: int, state: NonceState, tx_hash: str = None):
        """Imposta lo stato di un nonce."""
        if address not in self.nonces:
            self.nonces[address] = {}
        self.nonces[address][nonce] = {
            'state': state.value,
            'tx_hash': tx_hash,
            'timestamp': int(time.time())
        }
        logger.info(f"Nonce {nonce} per {address[:10]}... -> {state.value}")

    def get_next_valid_nonce(self, address: str) -> int:
        """Restituisce il prossimo nonce valido per un indirizzo."""
        if address not in self.nonces:
            return 0
        used_nonces = sorted(self.nonces[address].keys())
        if not used_nonces:
            return 0
        return max(used_nonces) + 1

    def mark_pending(self, address: str, nonce: int, tx_hash: str):
        """Marca un nonce come PENDING."""
        self.set_nonce_state(address, nonce, NonceState.PENDING, tx_hash)
        self.pending_txs[tx_hash] = {
            'address': address,
            'nonce': nonce,
            'timestamp': int(time.time())
        }

    def mark_confirmed(self, address: str, nonce: int, tx_hash: str):
        """Marca un nonce come CONFIRMED."""
        self.set_nonce_state(address, nonce, NonceState.CONFIRMED, tx_hash)
        if tx_hash in self.pending_txs:
            del self.pending_txs[tx_hash]

    def mark_expired(self, address: str, nonce: int, tx_hash: str):
        """Marca un nonce come EXPIRED e lo rilascia."""
        self.set_nonce_state(address, nonce, NonceState.EXPIRED, tx_hash)
        if tx_hash in self.pending_txs:
            del self.pending_txs[tx_hash]
        logger.warning(f"Nonce {nonce} per {address[:10]}... EXPIRED e rilasciato")

    def check_expiry(self):
        """Controlla tutte le TX pending e marca come EXPIRED quelle scadute."""
        now = int(time.time())
        expired_txs = []

        for tx_hash, tx_info in list(self.pending_txs.items()):
            age = now - tx_info['timestamp']
            if age >= self.default_expiry:
                self.mark_expired(tx_info['address'], tx_info['nonce'], tx_hash)
                expired_txs.append(tx_hash)

        if expired_txs:
            logger.info(f"TX scadute: {len(expired_txs)}")

        return expired_txs

    def get_stats(self) -> Dict:
        """Restituisce statistiche sui nonce."""
        stats = {
            'total_addresses': len(self.nonces),
            'pending_txs': len(self.pending_txs),
            'states': {
                'free': 0,
                'pending': 0,
                'confirmed': 0,
                'expired': 0
            }
        }
        for address, nonces in self.nonces.items():
            for nonce, info in nonces.items():
                stats['states'][info['state']] += 1
        return stats

if __name__ == '__main__':
    with open('nonce_engine/config.json', 'r') as f:
        config = json.load(f)

    manager = NonceManager(config)

    # Test
    manager.mark_pending("0x1234", 0, "0xabc")
    manager.mark_pending("0x1234", 1, "0xdef")
    manager.mark_confirmed("0x1234", 0, "0xabc")
    manager.mark_expired("0x1234", 1, "0xdef")

    print(f"Prossimo nonce valido: {manager.get_next_valid_nonce('0x1234')}")
    print(f"Statistiche: {manager.get_stats()}")
