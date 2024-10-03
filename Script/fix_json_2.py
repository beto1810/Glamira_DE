import json

def fix_json(input_file, output_file):
    conversion_count = 0  # Initialize a counter for conversions

    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            record = json.loads(line)
            if 'cart_products' in record:
                for product in record['cart_products']:
                    if 'option' in product:
                        # Check if 'option' is a list or needs conversion
                        if not isinstance(product['option'], list):
                            # If 'option' is not a list, convert it to a list
                            if isinstance(product['option'], dict):
                                product['option'] = [product['option']]  # Convert single object to list
                            elif isinstance(product['option'], (str, int, float, bool)):
                                # Convert non-object flat values into a single object
                                product['option'] = [{"value": product['option']}]  # Wrap flat value in a dict
                            else:
                                # Handle other cases where 'option' is neither list nor dict
                                product['option'] = [{"value": product['option']}]  # Wrap unexpected values
                            conversion_count += 1
                            print(f"Converted documents so far: {conversion_count}")  # Print the count continuously
            json.dump(record, outfile)
            outfile.write('\n')
    
    print(f"Total documents converted: {conversion_count}")

# Run the function on your file
fix_json("new_glamira_ouput.json", "fixed_glamira_output.json")
