# Guardian Node — Quantum Imperium

Questa è l'API che ogni Guardian esegue per firmare i messaggi del bridge.

## Setup

```bash
# Installa le dipendenze
pip install -r requirements.txt

# Configura il tuo Guardian
cp config.json config.local.json
nano config.local.json
Modifica config.local.json con:

guardian_key: La tua chiave privata (non condividerla mai)

guardian_address: Il tuo indirizzo pubblico

port: La porta su cui esporre l'API

Avvio
bash
python3 guardian_api.py
Endpoint
Endpoint	Metodo	Descrizione
/health	GET	Health check
/sign	POST	Firma un messaggio
/stake	GET	Restituisce lo stake
Sicurezza
Non condividere mai guardian_key

Usa un firewall per limitare l'accesso all'API

Autorizza solo i relayer fidati

Quantum Imperium Core Team — Settembre 2026
