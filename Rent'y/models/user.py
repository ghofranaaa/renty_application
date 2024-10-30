from datetime import datetime
import sys
import os
import bcrypt
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")

import uuid
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import relationship
from extensions import db


class User(db.Model):
    __tablename__ = 'users'
    
    id = Column(String(36), primary_key=True, default=str(uuid.uuid4()))
    name = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    image = Column(String(255), nullable=True)  # Store URL or path to the image
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    posts = relationship('Post', back_populates='user', cascade='all, delete')  # User's posts


    def __init__(self, name, email, password, image):
        self.name = name
        self.email = email
        self.password = self._hash_password(password)
        self.image = image


    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "password": self.password,
            "image": self.image,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat() if self.updated_at else None
        }


    def _hash_password(self, password):
        """Hash the password using bcrypt"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

    def verify_password(self, password):
        """Verify if the provided password matches the stored hash"""
        return bcrypt.checkpw(password.encode('utf-8'), self.password.encode('utf-8'))

    def set_password(self, password):
        """Update the user's password"""
        self.password = self._hash_password(password)
