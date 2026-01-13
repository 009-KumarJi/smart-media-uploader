import mimetypes

def handler(event, context):
    payload = event.get("Payload", event)

    input_key = payload["inputKey"]

    # Guess MIME type from filename
    mime, _ = mimetypes.guess_type(input_key)

    if not mime:
        media_type = "unknown"
    elif mime.startswith("image/"):
        media_type = "image"
    elif mime.startswith("video/"):
        media_type = "video"
    elif mime.startswith("audio/"):
        media_type = "audio"
    else:
        media_type = "unknown"

    payload["type"] = media_type
    payload["mime"] = mime

    return payload
