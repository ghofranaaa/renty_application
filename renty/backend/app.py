from flask import Flask, Blueprint, jsonify, request, send_from_directory
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from extensions import db, migrate
from werkzeug.utils import secure_filename
from flask_jwt_extended import JWTManager  # Import JWTManager
from auth.authentication import token_required
from datetime import timedelta
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def create_app():
    app = Flask(__name__)

    # Load configuration based on the environment
    env = os.getenv('FLASK_ENV', 'development')  # Default to 'development' if not set
    if env == 'production':
        app.config.from_object('config.ProductionConfig')
    else:
        app.config.from_object('config.DevelopmentConfig')

    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', '123456789')
    app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', '123456789')  # Set a secure key for JWT
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)  # Set expiration to 24 hours
    app.config['UPLOAD_FOLDER'] = 'static/uploads'


    # Initialize the database and migration
    db.init_app(app)
    migrate.init_app(app, db)
    jwt = JWTManager(app)
    CORS(app)

    # Register blueprints
    from routes.user_routes import users_bp
    from routes.post_routes import posts_bp
    from routes.home_routes import home_bp

    app.register_blueprint(users_bp)
    app.register_blueprint(posts_bp)
    app.register_blueprint(home_bp)


    # Add a default route for the root URL
    @app.route('/splash', methods=['GET'])
    def splash():
        return jsonify({"message": "Welcome to Renty"}), 200


    @app.route('/upload', methods=['POST'])
    def upload_file():
        if 'file' not in request.files:
            return 'No file part', 400
        file = request.files['file']
        if file.filename == '':
            return 'No selected file', 400
        if file:
            filename = secure_filename(file.filename)  # Make sure the filename is safe
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return {'filename': filename}, 200


# Endpoint to serve the uploaded images
    @app.route('/uploads/<filename>')
    def uploaded_file(filename):
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)


    # Create tables
    with app.app_context():
        db.create_all()

    return app  # Return the app instance here, outside the `with` block

if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=5000,debug=True)
