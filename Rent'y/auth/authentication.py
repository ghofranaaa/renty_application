import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")
from functools import wraps
from flask import request, jsonify
import jwt
from models.user import User

# Use the same JWT_SECRET_KEY as in your Flask app
SECRET_KEY = os.getenv('JWT_SECRET_KEY', '123456789')
revoked_tokens = set()  # Use a persistent storage in production, e.g., Redis or a database

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        # Check if 'Authorization' header is present
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            # Debug: Print the Authorization header
            print(f"Authorization header received: {auth_header}")
            try:
                token = auth_header.split(" ")[1]  # Extract token after 'Bearer'
            except IndexError:
                # Debug: Missing Bearer token format
                print("Error: Token missing after Bearer")
                return jsonify({"error": "Authorization header is invalid. Bearer token missing"}), 401
        else:
            # Debug: No Authorization header present
            print("Error: No Authorization header found")
            return jsonify({"error": "Authorization header missing"}), 401

        if not token:
            # Debug: No token was extracted from the header
            print("Error: No token extracted from header")
            return jsonify({"error": "Token not found"}), 401

        try:
            # Decode the token using the same secret key
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            jti = data['jti']  # Ensure your JWT includes a 'jti' claim

            if jti in revoked_tokens:
                return jsonify({"error": "Token has been revoked"}), 401

            user_id = data['sub']
            # Verify the user exists
            user = User.query.get(user_id)
            if not user:
                # Debug: User not found in the database
                print("Error: User not found")
                return jsonify({"error": "User not found"}), 401

        except jwt.ExpiredSignatureError:
            # Debug: Token has expired
            print("Error: Token has expired")
            return jsonify({"error": "Token has expired"}), 401
        except jwt.InvalidTokenError:
            # Debug: Token is invalid
            print("Error: Invalid token")
            return jsonify({"error": "Invalid token"}), 401

        # Pass the user_id to the decorated function
        return f(user_id=user_id, *args, **kwargs)

    return decorated
