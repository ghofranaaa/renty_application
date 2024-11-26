from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")

from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, Float, Enum
from sqlalchemy.orm import relationship
from extensions import db
import uuid


class Post(db.Model):
    __tablename__ = 'posts'

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey('users.id'), nullable=False)
    instrument_type = Column(Enum("Guitar", "Piano", "Violin", "Drums"), nullable=False)

    brand = Column(String(100), nullable=False)  # Brand of the instrument
    title = Column(String(100), nullable=False)
    price = Column(Float, nullable=False)  # Assuming price is in cents or the smallest currency unit
    description = Column(String(500), nullable=True)  # Description of the post
    phone_number = Column(String(8), nullable=False)
    image = Column(String(255), nullable=True)  # Store URL or path to the image
    availability = Column(Enum("sold", "rented", "available"), nullable=False)  # Availability can be 'available', 'sold', etc.
    status = Column(Enum("for sale", "for rental"), nullable=False)
    location = Column(String(300), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


    user = relationship('User', back_populates='posts')

    def __init__(self, user_id, instrument_type, title, image, brand, price, description,
                 status, phone_number, availability, location):
        self.user_id = user_id
        self.instrument_type = instrument_type
        self.brand = brand
        self.title = title
        self.price = price
        self.description = description
        self.phone_number = phone_number
        self.image = image
        self.availability = availability
        self.status = status
        self.location = location

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "instrument_type": self.instrument_type,
            "brand": self.brand,
            "title": self.title,
            "price": self.price,
            "description": self.description,
            "phone_number": self.phone_number,
            "image": self.image,
            "availability": self.availability,
            "status": self.status,
            "location": self.location,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }
