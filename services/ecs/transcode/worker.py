import boto3
import os
import subprocess
import json

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")

JOBS_TABLE = os.environ["JOBS_TABLE"]

def main():
    job_id = os.environ["JOB_ID"]
    input_key = os.environ["INPUT_KEY"]
    output_key = os.environ["OUTPUT_KEY"]

    bucket = input_key.split("/")[2]
    key = "/".join(input_key.split("/")[3:])

    local_input = "/tmp/input.mp4"
    local_output = "/tmp/output.mp4"

    print("Downloading from S3...")
    s3.download_file(bucket, key, local_input)

    print("Running FFmpeg...")
    subprocess.run([
        "ffmpeg", "-y",
        "-i", local_input,
        "-vf", "scale=1280:-1",
        local_output
    ], check=True)

    out_bucket = output_key.split("/")[2]
    out_key = "/".join(output_key.split("/")[3:])

    print("Uploading to S3...")
    s3.upload_file(local_output, out_bucket, out_key)

    print("Updating DynamoDB...")
    table = dynamodb.Table(JOBS_TABLE)
    table.update_item(
        Key={"jobId": job_id},
        UpdateExpression="SET #s = :s",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":s": "TRANSCODED"}
    )

    print("Done.")

if __name__ == "__main__":
    main()
