class IPFSClient:
    def __init__(self, gateway="/ip4/127.0.0.1/tcp/5001"):
        self.gateway = gateway

    def add_json(self, data):
        return "QmHash"

    def get_json(self, cid):
        return {}
