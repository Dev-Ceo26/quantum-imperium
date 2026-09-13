#!/usr/bin/env python3
"""
Guardian Client — Il client che il Relayer usa per raccogliere le firme.
Invia richieste agli endpoint /sign di tutti i Guardian.
"""
import json
import time
import logging
import requests
from typing import List, Dict

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [GUARDIAN-CLIENT] %(levelname)s: %(message)s'
)
logger = logging.getLogger("GuardianClient")

class GuardianClient:
    def __init__(self, config):
        self.guardians = config['guardians']
        self.threshold = config.get('threshold', 4)
        self.timeout = config.get('timeout', 10)

    def request_signatures(self, message_hash: str, action: str, payload: dict = None) -> List[Dict]:
        """
        Richiede la firma a tutti i Guardian.
        Restituisce una lista di firme valide.
        """
        signatures = []
        request_data = {
            "message_hash": message_hash,
            "action": action,
            "payload": payload or {}
        }

        for guardian in self.guardians:
            try:
                logger.info(f"Richiesta firma a {guardian}")
                response = requests.post(
                    f"{guardian}/sign",
                    json=request_data,
                    timeout=self.timeout
                )
                if response.status_code == 200:
                    data = response.json()
                    signatures.append({
                        "signer": data['signer'],
                        "signature": data['signature'],
                        "action": data['action']
                    })
                    logger.info(f"Firma ricevuta da {data['signer'][:10]}...")
                else:
                    logger.warning(f"Errore da {guardian}: {response.status_code}")
            except Exception as e:
                logger.error(f"Errore nella richiesta a {guardian}: {e}")

        logger.info(f"Firme raccolte: {len(signatures)}/{self.threshold}")

        if len(signatures) < self.threshold:
            logger.error(f"Firme insufficienti: {len(signatures)} < {self.threshold}")
            return []

        return signatures

    def get_guardian_health(self) -> Dict[str, bool]:
        """Verifica lo stato di salute di tutti i Guardian."""
        health = {}
        for guardian in self.guardians:
            try:
                response = requests.get(f"{guardian}/health", timeout=5)
                health[guardian] = response.status_code == 200
            except:
                health[guardian] = False
        return health

if __name__ == '__main__':
    with open('guardian/config.json', 'r') as f:
        config = json.load(f)

    client = GuardianClient(config)

    # Test di health check
    print("Health check dei Guardian:")
    health = client.get_guardian_health()
    for guardian, status in health.items():
        print(f"  {guardian}: {'✅' if status else '❌'}")
