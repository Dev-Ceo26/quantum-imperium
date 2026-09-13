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

CONFIG = {
    "eth_rpc": "https://sepolia.infura.io/v3/YOUR_PROJECT_ID",
    "imperium_rpc": "https://rpc-testnet.imperiumscan.com",
    "eth_bridge_address": "0x0000000000000000000000000000000000000000",
    "imperium_bridge_address": "0x0000000000000000000000000000000000000000",
    "validators": [
        "http://validator1.imperiumscan.com",
        "http://validator2.imperiumscan.com",
        "http://validator3.imperiumscan.com",
        "http://validator4.imperiumscan.com",
        "http://validator5.imperiumscan.com"
    ],
    "poll_interval": 10
}

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
    relayer = ImperiumRelayer(CONFIG)
    relayer.run()
