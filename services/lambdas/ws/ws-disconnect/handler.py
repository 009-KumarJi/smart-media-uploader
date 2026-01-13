# ws-disconnect/handler.py
import boto3
import os

ddb = boto3.resource("dynamodb")
table = ddb.Table(os.environ["WS_TABLE"])

def handler(event, context):
    connection_id = event["requestContext"]["connectionId"]

    resp = table.scan(
        FilterExpression="connectionId = :c",
        ExpressionAttributeValues={":c": connection_id}
    )

    for item in resp.get("Items", []):
        table.delete_item(
            Key={
                "jobId": item["jobId"],
                "connectionId": item["connectionId"]
            }
        )

    return {
        "statusCode": 200,
        "body": "disconnected"
    }
