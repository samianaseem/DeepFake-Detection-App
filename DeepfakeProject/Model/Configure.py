from flask import Flask
from flask_sqlalchemy import SQLAlchemy


# this file is for connection

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:admin@localhost/DeepFakeDetection'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
print("Connected", db)

