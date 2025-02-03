import json
import boto3
import os
from pymongo import MongoClient

# AWS clients
sqs = boto3.client('sqs')
secretsmanager = boto3.client('secretsmanager')
region = "eu-central-1"

# Get environment variables
SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')
MONGO_SECRET_ARN = os.getenv('MONGO_SECRET_ARN')

def get_secret(secret_name, region_name=region):
    # Create a session using IAM credentials (uses default credentials from AWS CLI or environment)
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region)

    try:
        # Get the secret value
        response = client.get_secret_value(SecretId=secret_name)

        # Check if the secret is stored as a string or binary
        if "SecretString" in response:
            secret = response["SecretString"]
        else:
            secret = response["SecretBinary"].decode("utf-8")

        # Parse JSON secrets (if applicable)
        try:
            return json.loads(secret)  # If secret is a JSON string, return as a dictionary
        except json.JSONDecodeError:
            return secret  # Return as plain string if not JSON

    except Exception as e:
        print(f" Error retrieving secret: {e}")
        return None


# Get MongoDB connection string from AWS Secrets Manager
def get_mongo_connection_string():
    # secret_value = secretsmanager.get_secret_value(SecretId=str(MONGO_SECRET_ARN))
    secret_name = 'mongodb_clarity_connection_string'
    response = get_secret(secret_name)
    print('Debug: ', response)
    # Parse the secret (either JSON or plain text)
    if "SecretString" in response:
      secret_data = json.loads(response["SecretString"])
    else:
      secret_data = json.loads(response["SecretBinary"].decode("utf-8"))

      # Extract connection string
      connection_string = secret_data.get("connection_string")
      if not connection_string:
        raise KeyError(" Error: connection_string not found in secret!")
    return connection_string


def lambda_handler(event, context):
    # Get MongoDB connection
    mongo_conn_str = get_mongo_connection_string()
    client = MongoClient(mongo_conn_str)
    db = client["food-orders"]  # Project: Clarity, Database: orders
    collection = db["requests"]

    for record in event['Records']:
        
        # message_body = json.loads(record['body'])
        message_body = record['body']

        # Insert into MongoDB Atlas
        collection.insert_one({ "message_id" : record['messageId'], "messageBody": record['body']})
        # Insert into MongoDB Atlas
        # collection.insert_one({
        #     "order_id": message_body["order_id"],
        #     "customer": message_body["customer"],
        #     "items":    message_body["items"],
        #     "total_price": message_body["price"],
        #     "timestamp": message_body["timestamp"]
        # })

        # Delete message from SQS after processing
        # sqs.delete_message( QueueUrl=SQS_QUEUE_URL, ReceiptHandle=record['receiptHandle'])

    return {"statusCode": 200, "body": "Messages processed successfully"}

if __name__ == "__main__":
    context = []
    event = {
        "Records": [
            { "receiptHandle": "01", "body": {"order_id": "001", "customer": "David", "items": "bananas", "price": "3.3", "timestamp": "2025-02-02 23:35"}},
            { "receiptHandle": "02", "body": {"order_id": "002", "customer": "Jacob", "items": "Melons", "price": "6.3", "timestamp": "2025-02-02 23:36"}},
            { "receiptHandle": "03", "body": {"order_id": "003", "customer": "Gil", "items": "Oranges", "price": "5.2", "timestamp": "2025-02-02 23:37"}},
            { "receiptHandle": "04", "body": {"order_id": "004", "customer": "Mark", "items": "Pears", "price": "4.1", "timestamp": "2025-02-02 23:38"}}
        ]
    }
    
    lambda_handler(event, context)
