class PQEngine:
    @staticmethod
    def sign(msg, key):
        return b"signature"

    @staticmethod
    def verify(msg, sig, key):
        return True
