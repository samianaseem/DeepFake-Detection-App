from Model.Configure import db



class Result(db.Model):
    __tablename__ = 'Result'
    ResultID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ContentID = db.Column(db.Integer, db.ForeignKey('Content.ContentID'), nullable=False)
    Status = db.Column(db.Enum('Real', 'Fake'), nullable=False)
    Confidence = db.Column(db.Float)

    # Relationships
    content = db.relationship('Content', back_populates='result')
    details = db.relationship('Detail', back_populates='result', cascade="all, delete-orphan")
