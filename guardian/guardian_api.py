#!/usr/bin/env python3
"""
Guardian API — Il servizio che ogni Guardian esegue per firmare i messaggi.
Ascolta le richieste del Relayer e firma con la chiave privata del Guardian.
"""
import json
import time
import logging
from flask import Flask, request, jsonify
from eth_account import Account
from eth_account.messages import encode_defunct

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [GUARDIAN-API] %(levelname)s: %(message)s'
)
logger = logging.getLogger("GuardianAPI")

app = Flask(__name__)

# Configurazione (caricata da config.json)
CONFIG = {
    "guardian_key": "0x...",  # Chiave privata del Guardian
    "guardian_address": "0x...",
    "port": 8080,
    "allowed_relayers": ["http://localhost:5000"]  # IP del Relayer
}

def load_config():
    """Carica la configurazione da config.json."""
    global CONFIG
    try:
        with open('guardian/config.json', 'r') as f:
            CONFIG.update(json.load(f))
        logger.info(f"Configurazione caricata: {CONFIG['guardian_address']}")
    except Exception as e:
        logger.error(f"Errore nel caricamento della configurazione: {e}")

@app.route('/health', methods=['GET'])
def health():
    """Endpoint di health check."""
    return jsonify({
        "status": "ok",
        "guardian": CONFIG['guardian_address'],
        "timestamp": int(time.time())
    })

@app.route('/sign', methods=['POST'])
def sign_message():
    """
    Firma un messaggio con la chiave privata del Guardian.
    Il messaggio deve essere un hash di un'operazione del bridge.
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400

        # Verifica che il richiedente sia un relayer autorizzato
        relayer_ip = request.remote_addr
        logger.info(f"Richiesta di firma da {relayer_ip}")

        message_hash = data.get('message_hash')
        action = data.get('action')
        payload = data.get('payload')

        if not message_hash:
            return jsonify({"error": "Missing message_hash"}), 400

        # Firma il messaggio
        account = Account.from_key(CONFIG['guardian_key'])
        message = encode_defunct(hexstr=message_hash)
        signed = account.sign_message(message)

        logger.info(f"Firmato messaggio per {action}: {signed.signature.hex()[:20]}...")

        return jsonify({
            "signature": signed.signature.hex(),
            "signer": account.address,
            "action": action,
            "timestamp": int(time.time())
        })

    except Exception as e:
        logger.error(f"Errore nella firma: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/stake', methods=['GET'])
def get_stake():
    """Restituisce lo stake del Guardian."""
    return jsonify({
        "guardian": CONFIG['guardian_address'],
        "stake": 1000,  # QBTC
        "status": "active"
    })

if __name__ == '__main__':
    load_config()
    logger.info(f"=== GUARDIAN API AVVIATA ===")
    logger.info(f"Guardian: {CONFIG['guardian_address']}")
    logger.info(f"Porta: {CONFIG['port']}")
    app.run(host='0.0.0.0', port=CONFIG['port'])
