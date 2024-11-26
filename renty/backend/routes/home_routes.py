from flask import Blueprint, jsonify, request, url_for
from flask_jwt_extended import create_access_token, get_jwt, jwt_required
from auth.authentication import token_required, revoked_tokens
from extensions import db
from models.user import User
from models.post import Post


home_bp = Blueprint("home_bp", __name__, url_prefix="/home")

@home_bp.route("/register", methods=["POST"])
def register_user():
    try:
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')

        if not name or not email or not password:
            return jsonify({'message': "Missing name, email or password"}), 400

        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({'message': 'Email already registered'}), 400

        new_user = User(name=name, email=email, password=password, image=None)
        db.session.add(new_user)
        db.session.commit()

        return jsonify({'message': 'User created successfully'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@home_bp.route("/login", methods=["POST"])
def login_user():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        user = User.query.filter_by(email=email).first()
        if not user:
            return jsonify({'message': 'Email not found'}), 404

        if not user.verify_password(password):
            return jsonify({'message': 'Invalid password'}), 401

        # Generate token with JWTManager
        access_token = create_access_token(identity=user.id)

        return jsonify({'access_token': access_token, 'user_id': user.id}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@home_bp.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    jti = get_jwt()["jti"]
    revoked_tokens.add(jti)  # Add token's JTI to blocklist
    return jsonify({'message': 'Logged out successfully'}), 200

POSTS_PER_PAGE = 10
@home_bp.route("/search", methods=["GET"])
@token_required
def get_paginated_posts(user_id):
    page = request.args.get('page', 1, type=int)
    if page is None:
        posts = Post.query.all()
        return jsonify([post.to_dict() for post in posts]), 200

    pagination = Post.query.paginate(page=page, per_page=POSTS_PER_PAGE, error_out=False)
    posts = pagination.items

    # generating urls for next and prev pages
    next_url = url_for('home_bp.get_paginated_posts', page=pagination.next_num, _external=True) \
        if pagination.has_next else None
    prev_url = url_for('home_bp.get_paginated_posts', page=pagination.prev_num, _external=True) \
        if pagination.has_prev else None

    links = []
    if next_url:
        links.append(f'<{next_url}>; rel="next"')
    if prev_url:
        links.append(f'<{prev_url}>; rel="prev"')

    # following the http format
    headers = {
        'Link': ', '.join(links) if links else None
    }

    response = {
        'posts': [post.to_dict() for post in posts],
        'pagination': {
            'total': pagination.total,
            'pages': pagination.pages,
            'next': next_url,
            'prev': prev_url
        }
    }

    return jsonify(response), 200, headers

@home_bp.route("/posts/<string:post_id>", methods=["GET"])
@token_required
def get_single_post(post_id: str, user_id: str):
    try:
        post = Post.query.get(post_id)
        if not post:
            return jsonify({'message': 'Post not found.'}), 404
        return jsonify(post.to_dict()), 200  # Assuming you have a to_dict method

    except SQLAlchemyError as e:
        return jsonify({'error': str(e)}), 500

@home_bp.route("/category", methods=["GET"])
@token_required
def get_by_category(user_id=None):
    instrument_type = request.args.get('type')
    if instrument_type:
        posts = Post.query.filter_by(instrument_type=instrument_type).all()
    else:
        posts = Post.query.all()
    return jsonify([post.to_dict() for post in posts])

@home_bp.route("/posts/search", methods=["GET"])
def search_posts():
    title = request.args.get('title', '').strip()  # Get the query parameter 'title'
    
    if not title:
        return jsonify({'error': 'Title query is required'}), 400
    
    posts = Post.query.filter(Post.title.ilike(f"%{title}%")).all()
    
    if not posts:
        return jsonify({'message': 'No posts found'}), 404
    
    posts_data = [post.to_dict() for post in posts]
    return jsonify(posts_data), 200