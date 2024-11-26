import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate


db = SQLAlchemy()
migrate = Migrate()
