import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["JOBS_TABLE"])

def handler(event, context):
    payload = event.get("Payload", event)

    job_id = payload["jobId"]
    user_id = payload["userId"]
    
    table.update_item(
        Key={
            "jobId": job_id,
            "userId": user_id
        },
        UpdateExpression="SET #s = :s",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":s": "COMPLETED"}
    )

    return payload
