# auth.py
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from jwt.exceptions import InvalidTokenError, ExpiredSignatureError

# 🔒 Security Schema
security = HTTPBearer()

# ⚙️ Configuration (Best Practice: Load from env)
# In production, this comes from os.environ.get("JWT_SECRET")
SECRET_KEY = "super-secret-krishna-kumar-dummy"
ALGORITHM = "HS256"

def verify_token(req: Request, credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Decodes the JWT token, verifies expiration and signature.
    Returns the user payload if valid.
    """
    token = credentials.credentials

    try:
        # 1. Decode & Verify
        # We explicitly set the algorithm to prevent "None" algorithm attacks
        payload = jwt.decode(
            token, 
            SECRET_KEY, 
            algorithms=[ALGORITHM],
            options={"require": ["exp", "sub"]} # Enforce these claims exist
        )
        

        if payload["sub"] is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token missing 'sub' (subject) claim"
            )
        
        req.state.user = payload
            
        return payload

    except ExpiredSignatureError:
        # 🕒 Specific error for frontend: "Your session time ran out"
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired. Please login again.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    except InvalidTokenError as e:
        # 🚫 Specific error for hackers/bugs: "This token is fake/corrupt"
        # Log this error internally for security monitoring!
        print(f"SECURITY ALERT: Invalid token attempt. Error: {str(e)}")
        
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    except Exception as e:
        # 💥 Catch-all for unexpected crashes
        print(f"INTERNAL AUTH ERROR: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal authentication error"
        )