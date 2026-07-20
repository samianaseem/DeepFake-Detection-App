

from Model.Configure import db

class Image(db.Model):
    __tablename__ = 'Image'
    ContentID = db.Column(db.Integer, db.ForeignKey('Content.ContentID'), primary_key=True)
    Size = db.Column(db.Float, nullable=False)

    # Relationships
    content = db.relationship('Content', back_populates='image')