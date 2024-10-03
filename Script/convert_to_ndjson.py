import ijson
import json

# File paths
input_file = 'glamira_sum.json'
output_file = 'glamira_sum_nd-output.json'


with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    objects = ijson.items(infile, 'item')
    for obj in objects:
        outfile.write(json.dumps(obj) + '\n')

print(f"NDJSON saved to {output_file}")