import json
import os
import boto3

sf = boto3.client("stepfunctions")
dynamodb = boto3.resource("dynamodb")

STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]
JOBS_TABLE = os.environ["JOBS_TABLE"]

def handler(event, context):
    for record in event.get("Records", []):
        raw = record.get("body")

        if not raw:
            print("Skipping empty message")
            continue

        try:
            payload = json.loads(raw)
        except Exception:
            print("Skipping invalid JSON:", raw)
            continue   # <-- do NOT crash

        job_id = payload["jobId"]
        user_id = payload["userId"]

        print("Starting Step Function for", job_id)

        sf.start_execution(
            stateMachineArn=STATE_MACHINE_ARN,
            input=json.dumps(payload)
        )

        table = dynamodb.Table(JOBS_TABLE)

        table.update_item(
            Key={
                "jobId": job_id,
                "userId": user_id
            },
            UpdateExpression="SET #s = :s",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":s": "RUNNING"}
        )

