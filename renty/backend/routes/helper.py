from flask import jsonify
from auth.authentication import token_required
from models.post import Post
from werkzeug.utils import secure_filename
import re
import os
from typing import Union


UPLOAD_FOLDER = 'static/uploads'

# Allowed extensions
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

VALID_INSTRUMENT_TYPES = ["Guitar", "Piano", "Drums", "Violin"]

def validate_post_input(title: str, description: str, price: Union[str, float], status: str, image: str,
                        instrument_type: str, brand: str, phone_number: str, location: str):
    # Validate title
    if not title or len(title) < 5:
        return jsonify({"error": "Title must be at least 5 characters long."}), 400

    # Validate description
    if description and len(description) < 10:
        return jsonify({"error": "Description must be at least 10 characters long."}), 400

    # Convert price to float
    try:
        price = float(price)
    except (ValueError, TypeError):
        return jsonify({"error": "Price must be a valid number."}), 400

    # Validate price
    if price <= 0:
        return jsonify({"error": "Price must be a valid number."}), 400

    # Validate phone number (Ensure it's a string and check if it contains only digits)
    if not phone_number.isdigit() or len(phone_number) < 8:
        return jsonify({"error": "Phone number must be at least 8 digits long and contain only digits."}), 400

    # Validate status
    if status not in ['for rental', 'for sale']:
        return jsonify({"error": "Status must be 'for rental' or 'for sale'."}), 400

    # If an image is provided, validate it
    if image:
        # Validate if image is a URL
        if re.match(r'^(http|https)://', image):
            # Ensure the URL points to a file with a valid image extension
            if not allowed_image(image):
                return jsonify({"error": "Image URL must point to a valid image format (png, jpg, jpeg)."}), 400

        # Validate if image is a local file path
        elif os.path.isfile(os.path.join(UPLOAD_FOLDER, secure_filename(image))):
            # Check if the file is in the correct upload folder and has an allowed extension
            if not allowed_image(image):
                return jsonify({"error": "Local image must be in png, jpg or jpeg format."}), 400
        else:
            return jsonify({"error": "Image must be a valid URL or a valid local file in the uploads folder."}), 400

    # Validate instrument type
    if instrument_type not in VALID_INSTRUMENT_TYPES:
        return jsonify({"error": f"Instrument type must be one of: {', '.join(VALID_INSTRUMENT_TYPES)}."}), 400

    # Validate brand
    if not brand or len(brand) < 3:
        return jsonify({"error": "Brand must be at least 3 characters long."}), 400

    # Validate location
    if not location or location == "":
        return jsonify({"error": "Location is required"}), 400

    return None  # No validation errors


def allowed_image(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
