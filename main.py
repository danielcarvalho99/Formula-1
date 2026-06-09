from client import GCPClient
from extractor import Extractor
from writer import Writer

def main():

    # Initialize GCP client and authenticate
    client = GCPClient("bucket-access.json")
    client = client.authenticate()

    # Inputs
    start = int(input("Add start date: "))
    end = int(input("Add end date: "))
    
    # Extract data and save to local CSV files
    extractor = Extractor(start=start, end=end, modes=['R'])
    extractor.process_data()

    # Write local CSV files to GCP bucket
    writer = Writer(client)
    files = writer.list_files(path="data/", extension=".csv")

    for file in files:
        writer.write_to_bucket(local_file_path=f"data/{file}", gcp_file_path=f"bronze/races/{file}", bucket_name="bucket-f1-data")
        print(f"Wrote {file} to GCP")


if __name__ == "__main__":
    main()
