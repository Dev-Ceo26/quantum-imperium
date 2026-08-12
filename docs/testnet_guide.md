# 🚀 Quantum Imperium Testnet Guide

Benvenuto nel testnet di **Quantum Imperium** — la blockchain che si propone come "Piano B" di Ethereum per l'era post-quantistica.

Questa guida ti accompagna passo dopo passo per installare il nodo, partecipare al testnet, diventare Guardian e guadagnare i primi QBTC.

---

## 📋 Prerequisiti

Prima di iniziare, assicurati di avere:

| Requisito | Versione minima | Note |
|-----------|----------------|------|
| **Python** | 3.10+ | `python3 --version` |
| **Git** | 2.30+ | `git --version` |
| **IPFS** | 0.20.0+ | `ipfs --version` |
| **Tor** | (opzionale) | Per routing anonimo |

Su macOS (Catalina o superiore):
```bash
brew install python3 git ipfs tor
Su Ubuntu/Debian:

bash
sudo apt update
sudo apt install python3 python3-pip git ipfs tor
🛠️ Installazione del nodo
1. Clona il repository
bash
git clone https://github.com/Dev-Ceo26/quantum-imperium.git
cd quantum-imperium
2. Installa le dipendenze
bash
python3 -m venv venv
source venv/bin/activate  # Su Windows: venv\Scripts\activate
pip install -r requirements.txt
3. Avvia IPFS (in un terminale separato)
bash
ipfs daemon
Per routing anonimo con Tor:

bash
sudo systemctl start tor
torsocks ipfs daemon --enable-pubsub-experiment --routing=dht
⛓️ Avvia il nodo
Opzione A: Modalità interattiva (CLI)
bash
python3 main.py
Dal menu puoi:

Mintare QBTC (opzione 0) per ottenere fondi di test

Inviare transazioni (opzione 1)

Minare blocchi (opzione 4) per guadagnare ricompense

Visualizzare la chain (opzione 5)

Controllare il saldo (opzione 6)

Opzione B: API REST
bash
python3 api_server.py
L'API sarà disponibile su http://localhost:30333

Endpoint principali:

GET /status – Stato della blockchain

GET /balance/<address> – Saldo di un indirizzo

POST /transaction – Invia una transazione

POST /mine – Mina un blocco

🦸 Diventa Guardian
I Guardian sono i validatori della rete. Per diventarlo:

1. Accumula 1000 QBTC
Usa il mining (opzione 4) o il minting (opzione 0) per ottenere fondi.

2. Registrati come Guardian
bash
python3 -c "
from core.blockchain import QuantumBlockchain
bc = QuantumBlockchain()
bc.register_guardian('TUO_INDIRIZZO', 1000, len(bc.chain))
print('Guardian registrato!')
"
3. Partecipa al consenso QPoS
I Guardian firmano i blocchi con firme Dilithium. Più alto è il tuo stake, maggiore è il peso del tuo voto.

Ricompense:

50 QBTC per blocco minato

Una parte delle fee di transazione

Fee di recovery (5 QBTC per richiesta approvata)

🎮 Quantum Game — Sfide per sviluppatori
Completa le sfide per guadagnare NFT "Quantum Pioneer" e QBTC testnet.

Sfida	Descrizione	Ricompensa
1. Deploy di un contratto	Deploya un contratto sulla VM	🏅 Pioneer Badge + 100 QBTC
2. Diventa Guardian	Stake 1000 QBTC e firma un blocco	🏅 Guardian Badge + 500 QBTC
3. Contribuisci al codice	Apri una PR con un bug fix o una nuova feature	🏅 Developer Badge + 1000 QBTC
Come inviare una soluzione
Completa la sfida

Apri una issue su GitHub con:

Il tuo indirizzo wallet

La prova del completamento (es. hash della transazione, link alla PR)

Attendi la verifica

Ricevi la ricompensa!

🔧 Comandi utili per il test
Creare un secondo wallet
bash
python3 -c "from core.wallet import PQWallet; w=PQWallet(); print(w.address())"
Inviare QBTC via API
bash
curl -X POST http://localhost:30333/transaction \
  -H "Content-Type: application/json" \
  -d '{"to":"INDIRIZZO_DESTINATARIO","amount":10}'
Minare un blocco via API
bash
curl -X POST http://localhost:30333/mine
Controllare il saldo di un indirizzo
bash
curl http://localhost:30333/balance/INDIRIZZO
Visualizzare la chain (ultimi 5 blocchi)
bash
curl http://localhost:30333/chain?limit=5
⚠️ Risoluzione dei problemi
Errore: Connection refused su IPFS
Assicurati che il demone IPFS sia in esecuzione:

bash
ipfs daemon
Errore: Invalid signature
La verifica delle firme è disabilitata per il test. Non preoccuparti, le transazioni vengono comunque elaborate.

Errore: Insufficient balance
Usa il minting (opzione 0) per ottenere QBTC di test.

Errore: Port already in use
Cambia la porta dell'API modificando api_server.py:

python
app.run(host='0.0.0.0', port=30334)
📊 Monitoraggio del testnet
Dashboard locale
L'API REST espone un endpoint di stato:

bash
curl http://localhost:30333/status
Risposta di esempio:

json
{
  "chain_length": 42,
  "pending_txs": 3,
  "accounts": 15
}
Interfaccia web
Avvia il server web:

bash
python3 -m http.server 8080
Poi apri http://localhost:8080 nel browser per un'interfaccia grafica semplice.

📞 Supporto
Discord: https://discord.gg/J2W8Dk56m

GitHub Issues: https://github.com/Dev-Ceo26/quantum-imperium/issues

Email: core@imperiumchain.com

📄 Licenza
MIT License — vedi LICENSE per i dettagli.

Quantum Imperium Core Team — Agosto 2026
