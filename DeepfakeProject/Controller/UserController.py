import secrets

from Model import User, db
from werkzeug.security import generate_password_hash, check_password_hash


class UserController:

    @staticmethod
    def create_user(data):
        # Check if the user already exists by email
        existing_user = db.session.query(User).filter(User.Email == data['Email']).first()
        if existing_user:
            return {"error": "User with this email already exists"}, 409

        try:
            # Create a new user instance
            #hashed_password = generate_password_hash(data['Passord'], method='sha256')
            new_user = User(
                Name=data['Name'],
                Email=data['Email'],
                Password=data['Password']
            )
            db.session.add(new_user)
            db.session.commit()
            return {"success": f"User {new_user.Name} has been successfully added",
                    "user": {"id": new_user.UserID, "name": new_user.Name, "email": new_user.Email}}, 201
        except Exception as exp:
            db.session.rollback()
            return {"error": f"Error creating user: {str(exp)}"}, 500

    @staticmethod
    def get_all_users():
        try:
            # Fetch all users
            users = db.session.query(User).all()
            if not users:
                return {"message": "No users found"}, 404
            return [{"id": user.UserID, "name": user.Name, "email": user.Email} for user in users], 200
        except Exception as exp:
            return {"error": f"Error fetching users: {str(exp)}"}, 500

    @staticmethod
    def get_user_by_id(user_id):
        try:
            # Fetch user by ID
            user = db.session.query(User).filter(User.UserID == user_id).first()
            if not user:
                return {"error": "User not found"}, 404
            return {"id": user.UserID, "name": user.Name, "email": user.Email}, 200
        except Exception as exp:
            return {"error": f"Error fetching user: {str(exp)}"}, 500

    @staticmethod
    def update_user(user_id, data):
        try:
            # Fetch user by ID
            user = db.session.query(User).filter(User.UserID == user_id).first()
            if not user:
                return {"error": "User not found"}, 404

            # Update user fields
            user.Name = data.get('Name', user.Name)
            user.Email = data.get('Email', user.Email)
            user.Password = data.get('Password', user.Password)
            db.session.commit()
            return {"success": f"User {user.Name} has been successfully updated",
                    "user": {"id": user.UserID, "name": user.Name, "email": user.Email}}, 200
        except Exception as exp:
            db.session.rollback()
            return {"error": f"Error updating user: {str(exp)}"}, 500

    @staticmethod
    def delete_user(user_id):
        try:
            # Fetch user by ID
            user = db.session.query(User).filter(User.UserID == user_id).first()
            if not user:
                return {"error": "User not found"}, 404

            # Delete user
            db.session.delete(user)
            db.session.commit()
            return {"success": f"User {user.Name} has been successfully deleted"}, 200
        except Exception as exp:
            db.session.rollback()
            return {"error": f"Error deleting user: {str(exp)}"}, 500




    @staticmethod
    def login_user(identifier, password):
        try:
            # Fetch user by email or username
            user = db.session.query(User).filter(
                (User.Email == identifier) | (User.Name == identifier)
            ).first()

            if not user:
                return None  # User not found

            # Check if the password is already hashed
            if user.Password.startswith("pbkdf2:"):
                # Verify hashed password
                if not check_password_hash(user.Password, password):
                    return None  # Invalid password
            else:
                # Plain-text password comparison (temporary solution)
                if user.Password != password:
                    return None  # Invalid password

            # If successful, return user details
            return {
                "id": user.UserID,
                "name": user.Name,
                "email": user.Email
            }
        except Exception as exp:
            raise Exception(f"Error during login: {str(exp)}")

    @staticmethod
    def request_password_reset(identifier):
        try:
            # Find user by email or username
            user = db.session.query(User).filter(
                (User.Email == identifier) | (User.Name == identifier)
            ).first()

            if not user:
                return {"error": "User not found"}  # Return just the dictionary

            # Generate a reset token
            reset_token = secrets.token_hex(16)
            user.ResetToken = reset_token  # Assuming there's a ResetToken field in the User model
            db.session.commit()

            # Simulate sending the reset token (mocked below)
            print(f"Reset token for {user.Email}: {reset_token}")

            return {"success": f"Password reset token sent to {user.Email}"}
        except Exception as exp:
            db.session.rollback()
            return {"error": f"Error during password reset request: {str(exp)}"}

    @staticmethod
    def reset_password(token, new_password):
        try:
            # Find user by reset token
            user = db.session.query(User).filter(User.ResetToken == token).first()

            if not user:
                return {"error": "Invalid or expired token"}  # Token not found

            # Hash the new password using a valid method
            hashed_password = generate_password_hash(new_password, method='pbkdf2:sha256')
            user.Password = hashed_password
            user.ResetToken = None  # Clear the reset token after successful reset
            db.session.commit()

            return {"success": "Password has been reset successfully"}
        except Exception as exp:
            db.session.rollback()
            return {"error": f"Error resetting password: {str(exp)}"}
