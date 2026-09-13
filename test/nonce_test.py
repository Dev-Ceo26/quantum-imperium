#!/usr/bin/env python3
"""
Test del Nonce Recovery Engine.
Verifica che il nonce venga rilasciato dopo l'expiry.
"""
import sys
import time
sys.path.append('../nonce_engine')

from nonce_manager import NonceManager, NonceState

def test_nonce_release():
    """Test: il nonce viene rilasciato dopo l'expiry."""
    config = {
        'rpc_url': 'http://localhost:30334',
        'default_expiry': 2,
        'poll_interval': 1
    }
    manager = NonceManager(config)

    manager.mark_pending("0x1234", 10, "0xtx10")
    assert manager.get_nonce_state("0x1234", 10) == NonceState.PENDING
    print("✅ Test 1: TX marcata come PENDING")

    manager.mark_pending("0x1234", 11, "0xtx11")
    assert manager.get_nonce_state("0x1234", 11) == NonceState.PENDING
    print("✅ Test 2: TX marcata come PENDING (nonce 11)")

    manager.mark_confirmed("0x1234", 10, "0xtx10")
    assert manager.get_nonce_state("0x1234", 10) == NonceState.CONFIRMED
    print("✅ Test 3: TX confermata (nonce 10)")

    time.sleep(3)
    expired = manager.check_expiry()
    assert manager.get_nonce_state("0x1234", 11) == NonceState.EXPIRED
    print("✅ Test 4: TX scaduta (nonce 11) e rilasciata")

    next_nonce = manager.get_next_valid_nonce("0x1234")
    assert next_nonce == 12
    print(f"✅ Test 5: Prossimo nonce valido: {next_nonce}")

    stats = manager.get_stats()
    print(f"✅ Test 6: Statistiche: {stats}")

    print("\n🎉 Tutti i test superati!")

if __name__ == '__main__':
    test_nonce_release()
