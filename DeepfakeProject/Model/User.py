

from Model.Configure import db

class User(db.Model):
    __tablename__ = 'User' #name must be matched wih table name

    # Define columns
    UserID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Name = db.Column(db.String(255), nullable=False)
    Email = db.Column(db.String(255), nullable=False, unique=True)
    Password = db.Column(db.String(255), nullable=False)
    ResetToken = db.Column(db.String(255), nullable=True)

    # Relationships (if needed in the future)
    # Example: user_orders = db.relationship('Order', back_populates='user')
    # Relationships
    contents = db.relationship('Content', back_populates='user', cascade="all, delete-orphan")
    generations = db.relationship('Generation', back_populates='user', lazy=True)