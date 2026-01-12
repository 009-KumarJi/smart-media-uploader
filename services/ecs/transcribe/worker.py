import os
import boto3
import json

s3 = boto3.client("s3")
dynamodb = boto3.client("dynamodb")

def parse_s3_uri(uri):
    _, _, path = uri.partition("s3://")
    bucket, _, key = path.partition("/")
    return bucket, key

def main():
    job_id = os.environ["JOB_ID"]
    input_key = os.environ["INPUT_KEY"]
    output_key = os.environ["OUTPUT_KEY"]
    table = os.environ["JOBS_TABLE"]

    print("Starting transcription for", job_id)

    bucket, key = parse_s3_uri(input_key)

    # fake transcription for now
    transcript = f"Transcription for job {job_id} from file {key}"

    out_bucket, out_key = parse_s3_uri(output_key)

    s3.put_object(
        Bucket=out_bucket,
        Key=out_key,
        Body=transcript.encode()
    )

    dynamodb.update_item(
        TableName=table,
        Key={"jobId": {"S": job_id}},
        UpdateExpression="SET #s = :s",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":s": {"S": "TRANSCRIBED"}}
    )

    print("Transcription done")

if __name__ == "__main__":
    main()
