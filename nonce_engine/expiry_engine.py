#!/usr/bin/env python3
"""
Expiry Engine — Controlla le TX in mempool e marca come EXPIRED quelle scadute.
"""
import json
import time
import logging
import requests
from nonce_manager import NonceManager, NonceState

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [EXPIRY-ENGINE] %(levelname)s: %(message)s'
)
logger = logging.getLogger("ExpiryEngine")

class ExpiryEngine:
    def __init__(self, config):
        self.rpc_url = config['rpc_url']
        self.poll_interval = config.get('poll_interval', 5)
        self.nonce_manager = NonceManager(config)

    def get_pending_txs(self):
        """Ottiene le TX pending dalla mempool."""
        payload = {
            "jsonrpc": "2.0",
            "method": "eth_getBlockByNumber",
            "params": ["pending", True],
            "id": 1
        }
        try:
            response = requests.post(self.rpc_url, json=payload, timeout=5)
            data = response.json()
            if 'result' in data and data['result']:
                return data['result'].get('transactions', [])
            return []
        except Exception as e:
            logger.error(f"Errore nel recupero delle TX pending: {e}")
            return []

    def process_txs(self, txs):
        """Processa le TX e aggiorna lo stato dei nonce."""
        for tx in txs:
            tx_hash = tx.get('hash', '')
            from_addr = tx.get('from', '')
            nonce = int(tx.get('nonce', '0x0'), 16)

            # Se la TX non è ancora tracciata, marcala come PENDING
            if tx_hash not in self.nonce_manager.pending_txs:
                self.nonce_manager.mark_pending(from_addr, nonce, tx_hash)

    def check_expiry(self):
        """Controlla le TX scadute e le marca come EXPIRED."""
        return self.nonce_manager.check_expiry()

    def run(self):
        """Loop principale dell'Expiry Engine."""
        logger.info("=== EXPIRY ENGINE AVVIATO ===")
        while True:
            txs = self.get_pending_txs()
            self.process_txs(txs)
            expired = self.check_expiry()

            if expired:
                logger.warning(f"TX scadute: {len(expired)}")

            stats = self.nonce_manager.get_stats()
            logger.info(f"Stats: {stats['pending_txs']} pending, {stats['states']}")

            time.sleep(self.poll_interval)

if __name__ == '__main__':
    with open('nonce_engine/config.json', 'r') as f:
        config = json.load(f)

    engine = ExpiryEngine(config)
    engine.run()
