from Model.Configure import db

class Generation(db.Model):
    __tablename__ = 'Generation'  # ✅ FIXED: double underscores

    Gen_ID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    UserID = db.Column(db.Integer, db.ForeignKey('User.UserID'), nullable=False)  # ✅ FIXED: match DB column
    Path = db.Column(db.String(255), nullable=False)
    media_type = db.Column(db.Enum('Image', 'Video'), nullable=False)

    # Relationships
    user = db.relationship('User', back_populates='generations')
