from flask import Blueprint, jsonify, request
from datetime import datetime
from flask_jwt_extended import create_access_token
from models.post import Post
from models.user import User
from extensions import db
from auth.authentication import token_required
from sqlalchemy.exc import SQLAlchemyError


users_bp = Blueprint("users_bp", __name__, url_prefix="/users")

@users_bp.route('/user/posts', methods=["GET"])
@token_required
def get_user_posts(user_id: str):
    try:
        user_posts = Post.query.filter_by(user_id=user_id).all()
        if not user_posts:
            return jsonify({'message': 'No posts found for this user.'}), 404

        return jsonify([post.to_dict() for post in user_posts]), 200

    except SQLAlchemyError as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/user/posts/<string:post_id>', methods=["GET"])
@token_required
def get_user_post(user_id: str, post_id: str):
    try:
        post = Post.query.filter_by(id=post_id, user_id=user_id).first()
        if not post:
            return jsonify({'message': 'Post not found.'}), 404

        return jsonify(post.to_dict()), 200

    except SQLAlchemyError as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/user/profile', methods=['GET'])
@token_required
def get_user(user_id: str):
    try:
        user =  User.query.filter_by(id=user_id).first()
        if not user:
            return jsonify({'message': 'User not found.'}), 404

        return jsonify(user.to_dict()), 200

    except SQLAlchemyError as e:
        return jsonify({'error': str(e)}), 500


@users_bp.route('/user', methods=['PUT'])
@token_required
def update_user(user_id: str):  # Only accept user_id as a route parameter
    data = request.get_json()  # Get the JSON data from the request
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    image = data.get('image')

    try:
        user = User.query.get(user_id) # Retrieve user by user_id
        if not user:
            return jsonify({"error": "User not found"}), 404

        if user:
            if name:
                user.name = name
            if email:
                user.email = email
            if password:
                user.set_password(password)  # Hash the new password
            if image:
                user.image = image
            user.updated_at = datetime.utcnow()  # Update the updated_at timestamp
            db.session.commit()
            return jsonify({'message': 'User updated successfully'}), 200

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@users_bp.route('/user/<string:user_id>', methods=['DELETE'])
@token_required
def delete_user(user_id: str):
    try:
        user = User.query.filter_by(id=user_id).first()
        if not user:
            return jsonify({'message': 'User not found.'}), 404

        db.session.delete(user)
        db.session.commit()
        return jsonify({'message': 'User deleted successfully.'}), 200

    except SQLAlchemyError as e:
        db.session.rollback()  # Rollback the session in case of error
        return jsonify({'error': str(e)}), 500