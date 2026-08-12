import json
import time
from typing import List, Dict
from dataclasses import dataclass

@dataclass
class Transaction:
    sender: str
    receiver: str
    amount: int
    timestamp: float

@dataclass
class Block:
    index: int
    timestamp: float
    transactions: List[Transaction]
    previous_hash: str
    hash: str = ""

class QuantumBlockchain:
    def __init__(self):
        self.chain = []
        self.create_genesis()

    def create_genesis(self):
        genesis = Block(0, time.time(), [], "0")
        genesis.hash = "0"
        self.chain.append(genesis)
