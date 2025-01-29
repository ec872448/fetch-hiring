import json


input_files = {
    "brands": r"C:\temp\brands.json",
    "receipts": r"C:\temp\receipts.json",
    "users": r"C:\temp\users.json"
}

output_files = {
    "brands": r"C:\temp\brands_fixed.json",
    "receipts": r"C:\temp\receipts_fixed.json",
    "users": r"C:\temp\users_fixed.json"
}

def flatten_mongo_json(obj):
    """ Recursively flattens MongoDB-style JSON fields. """
    if isinstance(obj, dict):
        new_obj = {}
        for key, value in obj.items():
            # Convert MongoDB "_id": {"$oid": "value"} → "id": "value"
            if key == "_id" and isinstance(value, dict) and "$oid" in value:
                new_obj["id"] = value["$oid"]
            # Convert MongoDB "date": {"$date": 12345678} → "date": 12345678
            elif isinstance(value, dict) and "$date" in value:
                new_obj[key] = value["$date"]
            # Convert nested `cpg` field
            elif key == "cpg" and isinstance(value, dict):
                if "$id" in value:
                    new_obj["cpgId"] = value["$id"]
                if "$ref" in value:
                    new_obj["cpgRef"] = value["$ref"]
            else:
                new_obj[key] = flatten_mongo_json(value)
        return new_obj
    elif isinstance(obj, list):
        return [flatten_mongo_json(item) for item in obj]
    else:
        return obj


for key in input_files:
    with open(input_files[key], "r", encoding="utf-8") as file:
        raw_data = file.readlines()

    cleaned_json = [flatten_mongo_json(json.loads(line.strip())) for line in raw_data if line.strip()]

    # Save cleaned JSON
    with open(output_files[key], "w", encoding="utf-8") as file:
        json.dump(cleaned_json, file, indent=4)

    print(f"✅ Fixed {input_files[key]} → {output_files[key]}")

print("🎉 JSON cleaning complete! Now you can import into SQL Server.")
