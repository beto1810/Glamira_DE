from pymongo import MongoClient

# Connect to the MongoDB server
client = MongoClient('mongodb://localhost:27017/')  # Update the connection string as needed

# Access the database and collection
db = client['glamira']
collection = db['summary']

# Find the total number of documents in the collection
total_documents = collection.count_documents({})

# Find documents without the "cart_products" key
cursor = collection.find({"cart_products": {"$exists": False}})

# Counters for processed and matched documents
processed_count = 0
matched_count = 0

for doc in cursor:
    matched_count += 1
    # Check if "product_id" exists in the document
    if "product_id" in doc:
        # Create the new "cart_products" key with "product_id"
        cart_products = {
            "product_id": doc["product_id"]
        }

        # Include "option" if it exists in the document
        if "option" in doc:
            cart_products["option"] = doc["option"]

        # Update the document with the new "cart_products" key
        collection.update_one(
            {"_id": doc["_id"]},
            {"$set": {"cart_products": cart_products}}
        )
        processed_count += 1

    # Print progress
    print(f"Processed {processed_count} documents out of {matched_count} matched (Total: {total_documents})")

# Close the connection
client.close()
