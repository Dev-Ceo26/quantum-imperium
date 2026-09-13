# Guida all'Installazione di un Validatore

## Prerequisiti

- 4 core CPU, 16 GB RAM, 100 GB SSD
- Ubuntu 22.04+ o Debian 12+
- Git, Python 3.10+, Rust

## Passi

1. Installa le dipendenze: `sudo apt install -y git python3 python3-pip`
2. Installa Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
3. Clona il repository: `git clone https://github.com/Dev-Ceo26/quantum-imperium.git`
4. Compila Reth: `cd reth && cargo install --locked --path bin/reth --bin reth`
5. Configura il genesis: `cp genesis/genesis-testnet.json ~/`
6. Genera il wallet: `python3 scripts/generate_wallet.py`
7. Avvia il servizio: `sudo systemctl start reth-validator`

## Porte

| Nodo | Chain ID | HTTP-RPC | P2P | AUTH-RPC |
| :--- | :--- | :--- | :--- | :--- |
| Testnet | 9818 | 30334 | 30303 | 8551 |
| Mainnet | 9819 | 30333 | 30304 | 8552 |

---

**Imperium Chain Core Team — 2026**
