def handler(event, context):
    payload = event.get("Payload", event)

    job_id = payload["jobId"]

    required = ["jobId", "userId", "inputKey"]

    for r in required:
        if r not in payload:
            raise Exception(f"Missing field {r}")

    return payload
