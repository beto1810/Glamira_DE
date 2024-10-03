import IP2Location
from pymongo import MongoClient, UpdateOne
from multiprocessing.pool import ThreadPool

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

def process_batch(batch):
    operations = []
    for document in batch:
        if 'country_code' in document:
            continue
        ip = document['ip']
        enriched_data = enrich_ip_data(ip)
        operations.append(UpdateOne({'_id': document['_id']}, {'$set': enriched_data}, upsert=True))
    
    if operations:
        collection.bulk_write(operations, ordered=False)

# Get the total number of documents
total_documents = collection.count_documents({})

# Create a progress bar and process documents
batch_size = 100  # Adjust batch size as needed
pool_size = 4  # Number of parallel threads
processed_count = 0

print(f"Starting IP data enrichment for {total_documents} documents.")

# Fetch documents in batches
cursor = collection.find()
batch = []

for document in cursor:
    batch.append(document)
    
    if len(batch) >= batch_size:
        with ThreadPool(pool_size) as pool:
            pool.map(process_batch, [batch])
        batch = []

    processed_count += 1
    if processed_count % 10 == 0 or processed_count == total_documents:
        print(f"Processed {processed_count}/{total_documents} documents")

# Process remaining documents in the final batch
if batch:
    with ThreadPool(pool_size) as pool:
        pool.map(process_batch, [batch])

print("IP data enrichment complete.")
