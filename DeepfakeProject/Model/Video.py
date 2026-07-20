from Model.Configure import db

class Video(db.Model):
    __tablename__ = 'Video'
    ContentID = db.Column(db.Integer, db.ForeignKey('Content.ContentID'), primary_key=True)
    Duration = db.Column(db.Float, nullable=False)

    # Relationships
    content = db.relationship('Content', back_populates='video')
