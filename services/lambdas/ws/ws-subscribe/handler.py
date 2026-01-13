# ws-subscribe/handler.py
import json
import boto3
import os
import time

ddb = boto3.resource("dynamodb")
table = ddb.Table(os.environ["WS_TABLE"])

def handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        job_id = body["jobId"]
    except:
        return {
            "statusCode": 400,
            "body": "Missing jobId"
        }

    connection_id = event["requestContext"]["connectionId"]

    table.put_item(Item={
        "jobId": job_id,
        "connectionId": connection_id,
        "expiresAt": int(time.time()) + 3600
    })

    return {
        "statusCode": 200,
        "body": "subscribed"
    }
