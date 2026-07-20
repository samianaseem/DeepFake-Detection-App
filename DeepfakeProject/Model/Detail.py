from Model.Configure import db


class Detail(db.Model):
    __tablename__ = 'Detail'
    DetailID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ResultID = db.Column(db.Integer, db.ForeignKey('Result.ResultID'), nullable=False)
    Time = db.Column(db.TIMESTAMP, server_default=db.func.current_timestamp(), nullable=False)
    ConfidenceScore = db.Column(db.Float, nullable=False)
    Frame = db.Column(db.String(255), nullable=False)
    Status = db.Column(db.String(255), nullable=True)

    # Relationships
    result = db.relationship('Result', back_populates='details')