import IP2Location
from pymongo import MongoClient, UpdateOne
from tqdm import tqdm
import concurrent.futures

# Initialize the IP2Location object
ip2location = IP2Location.IP2Location()

# Load the BIN database (update path to the BIN file on your VM)
bin_file_path = "/home/dat_nguyen_1810/IP2LOCATION-LITE-DB11.BIN"
ip2location.open(bin_file_path)

# Connect to MongoDB (use 'localhost' for MongoDB running on the same VM)
mongo_uri = 'mongodb://localhost:27017/'
client = MongoClient(mongo_uri)
db = client['glamira']
collection = db['summary']

# Function to enrich IP data
def enrich_ip_data(ip):
    record = ip2location.get_all(ip)
    return {
        "country_code": record.country_short,
        "country_name": record.country_long,
        "region_name": record.region,
        "city_name": record.city,
        "latitude": record.latitude,
        "longitude": record.longitude,
        "zipcode": record.zipcode,
        "timezone": record.timezone
    }

# Function to process a batch of documents
def process_batch(batch):
    updates = []
    for document in batch:
        ip = document['ip']  # Assuming the IP address is stored as the "ip" field
        enriched_data = enrich_ip_data(ip)
        updates.append(UpdateOne({'_id': document['_id']}, {'$set': enriched_data}, upsert=True))
    if updates:
        collection.bulk_write(updates)

# Get the total number of documents
total_documents = collection.count_documents({})

# Parameters
batch_size = 100  # Adjust batch size as needed
num_workers = 4  # Number of parallel workers (adjust based on your system)

# Create a progress bar and process documents in parallel
with tqdm(total=total_documents, desc="Enriching IP Data", unit='doc') as pbar:
    with concurrent.futures.ThreadPoolExecutor(max_workers=num_workers) as executor:
        futures = []
        batch = []
        for document in collection.find(projection=['_id', 'ip']):
            batch.append(document)
            if len(batch) >= batch_size:
                futures.append(executor.submit(process_batch, batch))
                batch = []

            pbar.update(1)  # Update progress bar for each processed document

        # Process remaining documents in the last batch
        if batch:
            futures.append(executor.submit(process_batch, batch))
        
        # Wait for all futures to complete
        for future in concurrent.futures.as_completed(futures):
            future.result()

print("IP data enrichment complete.")
