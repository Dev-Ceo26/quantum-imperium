# Guida Operativa per i Nuovi Guardian

Questa guida spiega cosa fare **dopo** essere stati selezionati come Guardian di Quantum Imperium.

---

## 📋 Fase 1: Setup del Nodo

### 1.1 Requisiti Hardware

| **Componente** | **Minimo** | **Consigliato** |
| :--- | :--- | :--- |
| **CPU** | 4 core | 8 core |
| **RAM** | 16 GB | 32 GB |
| **Storage** | 100 GB SSD | 500 GB NVMe |
| **Rete** | 5 Mbps | 100 Mbps |

### 1.2 Installazione di Reth

```bash
sudo apt update
sudo apt install -y git python3 python3-pip build-essential cmake
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
git clone https://github.com/paradigmxyz/reth
cd reth
cargo install --locked --path bin/reth --bin reth
1.3 Configura il Genesis
bash
cp genesis/genesis-testnet.json ~/genesis-testnet.json
1.4 Genera il Wallet del Guardian
bash
python3 scripts/generate_wallet.py
Questo genera:

guardian.key (chiave privata, non condividerla mai)

guardian.pub (chiave pubblica)

guardian.address (indirizzo del Guardian)

📋 Fase 2: Avvio del Nodo
2.1 Avvia Reth
bash
reth node \
  --chain ~/genesis-testnet.json \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 30334 \
  --http.api eth,net,web3 \
  --port 30303 \
  --authrpc.port 8551 \
  --dev \
  --dev.block-time 1s
2.2 Verifica che il Nodo Risponda
bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
  http://localhost:30334
Dovresti ricevere {"jsonrpc":"2.0","id":1,"result":"0x265a"}.

📋 Fase 3: Avvio delle Sentinelle AI
3.1 Installa le Dipendenze
bash
cd sentinels
pip install -r requirements.txt
3.2 Configura le Sentinelle
bash
cp config.json config.local.json
Modifica config.local.json con il tuo RPC:

json
{
  "rpc_url": "http://localhost:30334",
  "poll_interval": 5,
  "gas_spike_threshold": 10,
  "default_expiry": 86400
}
3.3 Avvia l'Orchestratore
bash
python3 orchestrator.py
📋 Fase 4: Registrazione come Guardian
4.1 Registra il tuo Indirizzo
Invia il tuo guardian.address su Discord al canale #guardian-registration.

4.2 Firma il Patto del Guardiano
Il Patto del Guardiano è un impegno on-chain che specifica:

Il tuo indirizzo pubblico

La tua chiave pubblica

La data di inizio del mandato

Le regole di comportamento

Il meccanismo di slashing

4.3 Stake 1.000 QBTC
Trasferisci 1.000 QBTC al contratto di staking. Questi fondi saranno bloccati per 6 mesi.

📋 Fase 5: Monitoraggio e Manutenzione
5.1 Controlla i Log
bash
sudo journalctl -u reth-validator -f
sudo journalctl -u imperium-sentinels -f
5.2 Monitora gli Alert
bash
cat ~/sentinels/alerts.log
5.3 Aggiorna Reth
Periodicamente, aggiorna Reth all'ultima versione:

bash
cd reth
git pull
cargo install --locked --path bin/reth --bin reth
sudo systemctl restart reth-validator
🚨 Sicurezza
Regola	Descrizione
Non condividere mai guardian.key	Se compromessa, il tuo stake è a rischio
Usa un firewall	sudo ufw allow 30303/tcp && sudo ufw allow 30334/tcp
Aggiorna regolarmente	Reth e le sentinelle
Segnala anomalie	Su Discord nel canale #security-alerts
📞 Supporto
Discord: https://discord.gg/J2W8Dk56m

Email: support@imperiumscan.com

Quantum Imperium Core Team — Settembre 2026
