# TODO: add MIME detection later
def handler(event, context):
    payload = event.get("Payload", event)

    job_id = payload["jobId"]
    return payload