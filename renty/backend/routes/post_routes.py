from flask import Blueprint, jsonify, request
from models.post import Post
from models.user import User
from extensions import db
from auth.authentication import token_required
from routes.helper import validate_post_input
from sqlalchemy.exc import SQLAlchemyError


posts_bp = Blueprint("posts_bp", __name__, url_prefix="/posts")

#authenticated user
@posts_bp.route("/create", methods=["POST"])
@token_required
def create_post(user_id: str):
    data = request.get_json()  # Get the incoming JSON data
    instrument_type = data.get('instrument_type')
    title = data.get('title')
    brand = data.get('brand')
    price = data.get('price')
    description = data.get('description')
    phone_number = data.get('phone_number')
    image = data.get('image')
    status = data.get('status')
    location = data.get('location')

    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({"error": "User not found"}), 404

        validation_error = validate_post_input(title, description, price, status, image, instrument_type, brand, phone_number, location)
        if validation_error:
            return validation_error


        new_post = Post(
            user_id=user_id,
            instrument_type=instrument_type,
            title=title,
            brand=brand,
            price=price,
            description=description,
            phone_number=phone_number,
            image=image,
            availability="available",  # Default availability is set to 'available'
            status=status,
            location=location,
        )

        db.session.add(new_post)
        db.session.commit()

        return jsonify({"message": "Post created successfully", "post_id": new_post.id}), 201

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


@posts_bp.route("/posts/<string:post_id>", methods=["PUT"])
@token_required
def update_post(user_id: str, post_id: str):
    data = request.get_json()  # Get the incoming JSON data
    instrument_type = data.get('instrument_type')
    title = data.get('title')
    brand = data.get('brand')
    price = data.get('price')
    phone_number = data.get('phone_number')
    description = data.get('description')
    image = data.get('image')
    availability=data.get('availability')
    status = data.get('status')
    location = data.get('location')

    try:
        post = Post.query.filter_by(id=post_id, user_id=user_id).first()

        if not post:
            return jsonify({"error": "Post not found"}), 404

        validation_error = validate_post_input(title, description, price, status, image, instrument_type, brand, phone_number, location)
        if validation_error:
            return validation_error

        if instrument_type:
            post.instrument_type = instrument_type
        if title:
            post.title = title
        if brand:
            post.brand = brand
        if price is not None:  # Check for None explicitly
            post.price = price
        if phone_number:
            post.phone_number = phone_number
        if description:
            post.description = description
        if image:
            post.image = image
        if status:
            post.status = status
        if location:
            post.location = location

        db.session.commit()
        return jsonify({"message": "Post updated successfully"}), 200

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@posts_bp.route("/posts/<string:post_id>", methods=["DELETE"])
@token_required
def delete_post(user_id, post_id):
    try:
        post = Post.query.filter_by(id=post_id, user_id=user_id).first()

        if not post:
            return jsonify({'message': 'Post not found'}), 404

        db.session.delete(post)
        db.session.commit()
        return jsonify({'message': 'Post deleted successfully.'}), 200

    except SQLAlchemyError as e:
        db.session.rollback()  # Rollback the session in case of error
        return jsonify({'error': str(e)}), 500



VALID_AVAILABILITIES = ["sold", "rented", "available"]
VALID_STATUSES = ["for sale", "for rental"]

@posts_bp.route("/<string:post_id>/status", methods=["PATCH"])
@token_required
def mark_post_availability(user_id: str, post_id: str):
    try:
        # Get the JSON payload
        data = request.get_json()
        availability = data.get('availability')

        # Validate that 'availability' is provided and not None
        if availability is None:
            return jsonify({"error": "Availability is required."}), 400

        # Validate availability
        availability = availability.lower()
        if availability not in VALID_AVAILABILITIES:
            return jsonify({
                "error": f"Invalid availability. Must be one of: {', '.join(VALID_AVAILABILITIES)}"
            }), 400

        # Fetch the post
        post = Post.query.filter_by(id=post_id, user_id=user_id).first()
        if not post:
            return jsonify({
                "error": "Post not found."
            }), 404

        # Validate the post status
        if post.status not in VALID_STATUSES:
            return jsonify({
                "error": "Invalid post status."
            }), 400

        # Handle availability transition based on status and current availability
        if availability == "available":
            if post.availability == "sold":
                return jsonify({
                    "error": "Cannot mark a sold item as available"
                }), 400
            
        elif availability == "rented":
            if post.status != "for rental":
                return jsonify({
                    "error": "Only posts with 'for rental' status can be marked as rented"
                }), 400
            if post.availability == "sold":
                return jsonify({
                    "error": "Cannot rent a sold item"
                }), 400
                
        elif availability == "sold":
            if post.status != "for sale":
                return jsonify({
                    "error": "Only posts with 'for sale' status can be marked as sold"
                }), 400

        # Update availability
        post.availability = availability
        db.session.commit()
        
        return jsonify({
            "message": f"Post marked as {availability}",
            "post": post.to_dict()
        }), 200

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

