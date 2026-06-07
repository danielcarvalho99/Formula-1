class Writer:
    def __init__(self, gcp_client, path="data/"):
        self.gcp_client = gcp_client
        self.path = path

    def list_files(self, path, extension=".csv"):
        import os
        return [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and f.endswith(extension)]

    def write_to_bucket(self, bucket_name: str, local_file_path: str, gcp_file_path: str):
        try:
            bucket = self.gcp_client.bucket(bucket_name)
            blob = bucket.blob(gcp_file_path)
            blob.upload_from_filename(local_file_path)
        except Exception as e:
            print(f"Error occurred while writing to bucket: {e}")
