# CREATE TABLE Content (
#     ContentID INT AUTO_INCREMENT PRIMARY KEY,
#     UserID INT NOT NULL,
#     Path VARCHAR(255) NOT NULL,
#     Type ENUM('Image', 'Video') NOT NULL,
#     FOREIGN KEY (UserID) REFERENCES User(UserID)
# );

from Model.Configure import db

class Content(db.Model):
    __tablename__ = 'Content'
    ContentID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    UserID = db.Column(db.Integer, db.ForeignKey('User.UserID'), nullable=False)
    Path = db.Column(db.String(255), nullable=False)
    Type = db.Column(db.Enum('Image', 'Video'), nullable=False)

    # Relationships
    user = db.relationship('User', back_populates='contents')
    image = db.relationship('Image', back_populates='content', uselist=False, cascade="all, delete-orphan")
    video = db.relationship('Video', back_populates='content', uselist=False, cascade="all, delete-orphan")
    result = db.relationship('Result', back_populates='content', cascade="all, delete-orphan")
   