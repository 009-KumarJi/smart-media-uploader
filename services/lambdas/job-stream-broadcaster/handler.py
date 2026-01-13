import boto3
import os
import json

dynamodb = boto3.resource("dynamodb")
apigw = boto3.client("apigatewaymanagementapi")

WS_TABLE = os.environ["WS_TABLE"]
WS_ENDPOINT = os.environ["WS_ENDPOINT"]

ws_table = dynamodb.Table(WS_TABLE)

def handler(event, context):
    print("EVENT:", json.dumps(event))

    for record in event["Records"]:
        if record["eventName"] not in ["INSERT", "MODIFY"]:
            continue

        new = record["dynamodb"].get("NewImage")
        if not new:
            continue

        job_id = new["jobId"]["S"]
        status = new["status"]["S"]
        progress = int(new.get("progress", {"N": "0"})["N"])

        # Find all websocket subscribers for this job
        conns = ws_table.query(
            KeyConditionExpression="jobId = :j",
            ExpressionAttributeValues={":j": job_id}
        )

        for c in conns.get("Items", []):
            cid = c["connectionId"]

            try:
                apigw.post_to_connection(
                    ConnectionId=cid,
                    Data=json.dumps({
                        "jobId": job_id,
                        "status": status,
                        "progress": progress
                    })
                )
            except Exception as e:
                print("WS send failed:", e)
                ws_table.delete_item(Key={
                    "jobId": job_id,
                    "connectionId": cid
                })
