import boto3
import os
import subprocess
import json
import time

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")

JOBS_TABLE = os.environ["JOBS_TABLE"]

def main():
    job_id = os.environ["JOB_ID"]
    input_key = os.environ["INPUT_KEY"]
    output_key = os.environ["OUTPUT_KEY"]
    user_id = os.environ["USER_ID"]
    RAW_BUCKET = os.environ["RAW_BUCKET"]

    local_input = "/tmp/input.mp4"
    local_output = "/tmp/output.mp4"

    print("Downloading from S3...")
    s3.download_file(RAW_BUCKET, input_key, local_input)
    update_job(job_id, user_id, stage="DOWNLOADED", progress=10)
    
    #TODO: Remove --- ARTIFICIAL WAIT START ---
    print("Waiting for 10 seconds...")
    time.sleep(10) 
    # --- ARTIFICIAL WAIT END ---
    
    print("Running FFmpeg...")
    update_job(job_id, user_id, stage="TRANSCODING", progress=20)

    proc = subprocess.Popen([
        "ffmpeg", "-y",
        "-i", local_input,
        "-vf", "scale=1280:-1",
        local_output
    ], stderr=subprocess.PIPE, text=True)

    for line in proc.stderr:
        if "time=" in line:
            update_job(job_id, user_id, stage="TRANSCODING", progress=50)

    proc.wait()

    out_bucket = output_key.split("/")[2]
    out_key = "/".join(output_key.split("/")[3:])
    
    print("Uploading to S3...")
    update_job(job_id, user_id, stage="UPLOADING", progress=80)
    s3.upload_file(local_output, out_bucket, out_key)
    update_job(job_id, user_id, stage="DONE", progress=100)
    print("Done.")

def update_job(job_id, user_id, **fields):
    table = dynamodb.Table(JOBS_TABLE)
    update = []
    names = {}
    values = {}

    for k, v in fields.items():
        key = "#" + k
        val = ":" + k
        update.append(f"{key} = {val}")
        names[key] = k
        values[val] = v

    update.append("#hb = :hb")
    names["#hb"] = "heartbeatAt"
    values[":hb"] = int(time.time())

    table.update_item(
        Key={"jobId": job_id, "userId": user_id},
        UpdateExpression="SET " + ", ".join(update),
        ExpressionAttributeNames=names,
        ExpressionAttributeValues=values
    )


if __name__ == "__main__":
    main()
