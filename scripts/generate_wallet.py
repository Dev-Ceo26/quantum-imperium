#!/usr/bin/env python3
import os
import secrets
import hashlib

def generate_wallet():
    private_key = secrets.token_bytes(32)
    private_key_hex = "0x" + private_key.hex()
    public_key = hashlib.sha256(private_key).digest()
    address = "0x" + hashlib.sha3_256(public_key).hexdigest()[-40:]

    with open("validator.key", "w") as f:
        f.write(private_key_hex)
    os.chmod("validator.key", 0o600)
    with open("validator.pub", "w") as f:
        f.write(public_key.hex())
    with open("validator.address", "w") as f:
        f.write(address)

    print(f"✅ Wallet generato: {address}")
    print("⚠️ Non condividere mai validator.key!")

if __name__ == "__main__":
    generate_wallet()
