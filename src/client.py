from google.cloud import storage

class GCPClient:
    def __init__(self, credentials_path):
        self.credentials_path = credentials_path

    def authenticate(self):
        client = storage.Client.from_service_account_json(self.credentials_path)
        return client
