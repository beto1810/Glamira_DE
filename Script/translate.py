import json
import time
from googletrans import Translator

# File path
file = "processed_glamira_data.json"

# Initialize translator
translator = Translator()

# Function to detect and correct encoding
def correct_encoding(text):
    encodings = ['utf-8', 'latin1', 'windows-1252']  # List of potential encodings
    for encoding in encodings:
        try:
            # Attempt to decode with the current encoding and then re-encode to UTF-8
            return text.encode(encoding).decode('utf-8')
        except (UnicodeDecodeError, UnicodeEncodeError):
            continue
    # If no encoding works, return the original text
    print(f"Could not determine encoding for text: {text}")
    return text

# Function to translate text to English and log changes
def translate_to_english(text):
    try:
        if text:
            translated = translator.translate(text, dest='en')
            if translated.text == text:
                print(f"Text '{text}' is already in English or not translated.")
            else:
                print(f"Original: '{text}' | Translated: '{translated.text}'")
            return translated.text
        else:
            return text
    except Exception as e:
        print(f"Error translating text '{text}': {e}")
        return text

# Load JSON data from the file
try:
    with open(file, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error loading JSON file: {e}")
    data = []

# Iterate through each document in the JSON array
for item in data:
    for field in ['name', 'category', 'gender']:
        if field in item and item[field] is not None and isinstance(item[field], str):
            # Correct encoding if needed
            item[field] = correct_encoding(item[field])
            # Translate text to English
            item[field] = translate_to_english(item[field])
            # Introduce a delay to handle rate limits
            time.sleep(1)

# Save the translated data back to the file
try:
    with open(file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
except Exception as e:
    print(f"Error saving JSON file: {e}")

# Print the translated documents
print(json.dumps(data, ensure_ascii=False, indent=4))
