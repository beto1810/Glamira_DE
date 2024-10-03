import json

def fix_is_paypal_field(record):
    """
    Fixes the 'is_paypal' field to ensure it's a boolean.
    """
    if 'is_paypal' in record:
        value = record['is_paypal']
        if value in ["1", 1, "true", True]:
            record['is_paypal'] = True
        elif value in ["0", 0, "false", False]:
            record['is_paypal'] = False
        else:   
            # Handle unexpected values or leave as is if it's already valid
            record['is_paypal'] = None
    return record

def update_documents(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            record = json.loads(line)
            fixed_record = fix_is_paypal_field(record)
            json.dump(fixed_record, outfile)
            outfile.write('\n')

# Run the function on your file
update_documents("fixed_glamira_output_v6.json", "fixed_glamira_output_v7.json")
