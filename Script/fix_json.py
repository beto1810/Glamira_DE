import json

def fix_option_field(record):
    """
    Fixes the 'option' field in 'cart_products' to ensure it's a list of objects or an empty list.
    """
    if 'cart_products' in record:
        for product in record['cart_products']:
            if 'option' in product:
                if not isinstance(product['option'], list):
                    # If 'option' is not a list, convert to list with empty objects
                    product['option'] = []
                else:
                    # Ensure each item in 'option' is an object with expected fields
                    product['option'] = [
                        {
                            "option_label": item.get("option_label", ""),
                            "option_id": item.get("option_id", ""),
                            "value_label": item.get("value_label", ""),
                            "value_id": item.get("value_id", "")
                        } if isinstance(item, dict) else {}
                        for item in product['option']
                    ]
    return record

def update_documents(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            record = json.loads(line)
            fixed_record = fix_option_field(record)
            json.dump(fixed_record, outfile)
            outfile.write('\n')

# Run the function on your file
update_documents("new_glamira_output.json", "fixed_glamira_output_v6.json")