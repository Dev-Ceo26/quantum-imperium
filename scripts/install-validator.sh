#!/bin/bash
set -e

echo "🚀 Imperium Chain — Installazione Validatore"
command -v git >/dev/null 2>&1 || { echo "❌ Git non installato"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 non installato"; exit 1; }

if [ ! -d "quantum_chain" ]; then
    git clone https://github.com/Dev-Ceo26/quantum-imperium.git quantum_chain
fi
cd quantum_chain

cp genesis/genesis-testnet.json ~/genesis-testnet.json
python3 scripts/generate_wallet.py

sudo cp scripts/reth-validator.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable reth-validator.service
sudo systemctl start reth-validator.service

echo "✅ Validatore installato con successo!"
