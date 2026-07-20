
import logging

import cv2
import dlib
import numpy as np


from DeepfakeProject.Model import Content,Image,Detail
from DeepfakeProject.Model import Result
import datetime
from PIL import Image

from datetime import datetime      # yeh tb uncomment kry gy jb multiface detectt kry gy

from flask import request, jsonify, send_file, send_from_directory, current_app, Flask
from Controller.UserController import UserController
from Model import User
import base64
from Model.Configure import app, db
from Controller.ContentController import ContentController, FACE_FOLDER, INPUT_FOLDER
import os
from Model.Generation import Generation
import os
print("Running from:", os.getcwd())

# app = Flask(__name__, static_url_path='/uploads', static_folder='uploads')

UPLOAD_FOLDER = "add_face/input"
RESULT_FOLDER = "add_face/result"
IMAGE_FOLDER = 'uploads/test'

PREDICTOR_PATH = "C:/Users/Samia/Downloads/DeepfakeProject/shape_predictor_68_face_landmarks.dat"



# multiple image save
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')  # You can change folder name
os.makedirs(UPLOAD_FOLDER, exist_ok=True)  # Auto-create if doesn't exist

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
# ----------------------------------------------------------------------
BASE_DIR = os.getcwd()
UPLOAD_FOLDER = os.path.join('uploads', 'test')
RESULT_FOLDER = os.path.join('uploads', 'results')

# Make sure folders exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)


# Serve uploaded original images
# @app.route('/uploads/test/<filename>')
# def get_original_image(filename):
#     return send_from_directory(UPLOAD_FOLDER, filename)
#
# # Serve result images
# @app.route('/uploads/results/<filename>')
# def get_result_image(filename):
#     return send_from_directory(RESULT_FOLDER, filename)

# @app.route('/uploads/results/<filename>')
# def serve_result_image(filename):
#     return send_from_directory('uploads/results', filename)
# ----------------------------------------------------------------------------


#
# ----------------------------------------------------------------
# @app.route('/api/merge_faces_swap', methods=['POST'])
# def merge_faces_swap():
#     try:
#         if 'source' not in request.files or 'targets' not in request.files:
#             return jsonify({'error': 'Missing source or targets'}), 400
#
#         source_file = request.files['source']
#         target_files = request.files.getlist('targets')
#
#         timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
#         source_path = os.path.join(INPUT_FOLDER, f'source_{timestamp}.jpg')
#         print("Saving source to:", source_path)  # ← 👈 Yeh line yahan add karein
#
#         source_file.save(source_path)
#
#         target_paths = []
#         for idx, tfile in enumerate(target_files):
#             target_path = os.path.join(INPUT_FOLDER, f'target_{idx}_{timestamp}.jpg')
#             tfile.save(target_path)
#             target_paths.append(target_path)
#
#         source_img = cv2.imread(source_path)
#         predictor = dlib.shape_predictor(PREDICTOR_PATH)
#
#         result_images = []
#         for path in target_paths:
#             target_img = cv2.imread(path)
#             swapped = ContentController.swap_faces_2(source_img, target_img, predictor)
#             result_images.append(swapped)
#
#         # Merge all images horizontally
#         merged = np.hstack(result_images)
#         final_path = os.path.join(RESULT_FOLDER, f'merged_result_{timestamp}.jpg')
#         cv2.imwrite(final_path, merged)
#
#         with open(final_path, "rb") as f:
#             encoded = base64.b64encode(f.read()).decode('utf-8')
#
#         return jsonify({
#             'result': 'Deepfake merged image created successfully',
#             'image': encoded,
#             'saved_path': final_path
#         }), 200
#
#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# --------------------------------------------------------------------------------

@app.route('/api/detect_video', methods=['POST'])
def detect_video():
    try:
        user_id = request.form.get('user_id')
        print(f"Received video user_id: {user_id}")
        if not user_id:
            return jsonify({"error": "User ID is required"}), 400

        if 'file' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['file']
        print(f"Received video file: {file.filename}")
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        response, status_code = ContentController.save_video_content(file, int(user_id))
        return jsonify(response), status_code

    except Exception as e:
        print(f"Video Route Exception: {str(e)}")
        return jsonify({"error": str(e)}), 500

#----------------------------feature deepfake generation----------------


@app.route('/feature_deepkake_generation', methods=['POST'])
def deepkfake_feature():
    try:
        logging.debug(f"Received files: {request.files.keys()}")
        logging.debug(f"Received form data: {request.form}")
        if 'image1' not in request.files or 'image2' not in request.files:
            logging.error("Missing image1 or image2 in request")
            return jsonify({"error": "Both 'image1' and 'image2' files are required"}), 400

        # Get feature_type from form data
        feature_type = request.form.get('feature_type', '4')  # Default to full face (4) if not specified
        if feature_type not in ['1', '2', '3', '4']:
            logging.error(f"Invalid feature_type: {feature_type}")
            return jsonify({"error": "Invalid feature_type. Must be 1 (nose), 2 (lips), 3 (eyes), or 4 (full face)"}), 400
        feature_type = int(feature_type)

        # Map feature_type to feature name for filename
        feature_names = {1: "nose", 2: "lips", 3: "eyes", 4: "full_face"}
        feature_name = feature_names[feature_type]

        # Define directories from app config
        UPLOAD_FOLDER = app.config.get('UPLOAD_FOLDER', 'Uploads')
        RESULT_FOLDER = app.config.get('RESULT_FOLDER', 'add_face/result')
        logging.debug(f"UPLOAD_FOLDER: {UPLOAD_FOLDER}, RESULT_FOLDER: {RESULT_FOLDER}")

        # Ensure directories exist
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)
            logging.debug(f"Created UPLOAD_FOLDER: {UPLOAD_FOLDER}")
        if not os.path.exists(RESULT_FOLDER):
            os.makedirs(RESULT_FOLDER)
            logging.debug(f"Created RESULT_FOLDER: {RESULT_FOLDER}")

        # Save uploaded images
        image1 = request.files['image1']
        image2 = request.files['image2']
        image1_path = os.path.join(UPLOAD_FOLDER, "image1.jpg")
        image2_path = os.path.join(UPLOAD_FOLDER, "image2.jpg")
        logging.debug(f"Saving image1 to {image1_path}")
        image1.save(image1_path)
        logging.debug(f"Saving image2 to {image2_path}")
        image2.save(image2_path)

        # Verify file existence
        if not os.path.exists(image1_path) or not os.path.exists(image2_path):
            raise ValueError("Failed to save one or both images")

        # Process images with specified feature
        logging.debug(f"Calling swap_faces with {image1_path}, {image2_path}, feature_type={feature_type}")
        result_path = ContentController.swap_faces_features(image1_path, image2_path, RESULT_FOLDER, feature_type)

        # Rename result file with feature name
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_filename = f"{feature_name}swap_result{timestamp}.jpg"
        new_result_path = os.path.join(RESULT_FOLDER, unique_filename)
        logging.debug(f"Renaming {result_path} to {new_result_path}")
        os.rename(result_path, new_result_path)

        # Encode result image as base64
        with open(new_result_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode('utf-8')

        # Validate user_id
        user_id = request.form.get('user_id', None)
        if user_id is None:
            logging.error("No user_id provided in request")
            return jsonify({"error": "user_id is required"}), 400
        user_id = int(user_id)
        user = db.session.query(User).filter_by(UserID=user_id).first()
        if not user:
            logging.error(f"Invalid user_id: {user_id} does not exist in user table")
            return jsonify({"error": f"User with UserID {user_id} does not exist"}), 400

        # Save to database
        logging.debug(f"Adding record for user_id: {user_id}")
        new_record = Generation(UserID=user_id, Path=new_result_path, media_type="Image")
        db.session.add(new_record)
        db.session.commit()
        logging.debug("Database commit successful")

        return jsonify({
            "Result": f"{feature_name.replace('_', ' ').capitalize()} swap completed",
            "image": encoded_image,
            "saved_path": new_result_path
        }), 200

    except Exception as e:
        db.session.rollback()
        logging.error(f"Error in /add_face: {str(e)}")
        return jsonify({"error": str(e)}), 500
# ------------------------------yeh 3 image le rha ------------------------------------------------------
@app.route('/multi_feature_swap', methods=['POST'])
def multi_feature_swap():
    try:
        if 'source' not in request.files:
            return jsonify({"error": "source image is required"}), 400

        source_img = cv2.imdecode(np.frombuffer(request.files['source'].read(), np.uint8), cv2.IMREAD_COLOR)
        src_landmarks, _ = ContentController.get_landmarks(source_img)

        # Map of target keys and features
        feature_map = {
            'target1': request.form.get('feature1'),
            'target2': request.form.get('feature2'),
            'target3': request.form.get('feature3'),
        }

        for i in range(1, 4):
            key = f"target{i}"
            feature = feature_map[key]
            if key in request.files and feature:
                target_img = cv2.imdecode(np.frombuffer(request.files[key].read(), np.uint8), cv2.IMREAD_COLOR)
                tgt_landmarks, _ = ContentController.get_landmarks(target_img)
                source_img = ContentController.swap_feature(source_img, src_landmarks, target_img, tgt_landmarks, feature)

        # Save final result
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        result_path = f"multi_feature_swap/outputs/result_{timestamp}.jpg"
        os.makedirs(os.path.dirname(result_path), exist_ok=True)
        cv2.imwrite(result_path, source_img)

        with open(result_path, "rb") as f:
            encoded = base64.b64encode(f.read()).decode('utf-8')

        return jsonify({"image": encoded, "result_path": result_path}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------------------------------------------------------------------


@app.route('/add_users', methods=['POST'])
def create_user():
    try:
        data = request.json
        new_user = UserController.create_user(data)
        return new_user
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/users', methods=['GET'])
def get_all_users():
    try:
        users = UserController.get_all_users()
        return users
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    try:
        user = UserController.get_user_by_id(user_id)
        if user:
            return jsonify(user), 200
        return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/update_users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    try:
        data = request.json
        updated_user = UserController.update_user(user_id, data)
        if updated_user:
            return jsonify({"message": "User updated successfully", "user": updated_user}), 200
        return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/del_users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    try:
        success = UserController.delete_user(user_id)
        if success:
            return jsonify({"message": "User deleted successfully"}), 200
        return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500




@app.route('/login', methods=['POST'])
def login_user():
    try:
        data = request.json  # Get the request body data
        email_or_name = data.get('identifier')  # Can be email or name
        password = data.get('password')  # User's password

        # Call the UserController to handle login logic
        user = UserController.login_user(email_or_name, password)
        if user:
            return jsonify({"message": "Login successful", "user": user}), 200
        return jsonify({"error": "Invalid email/username or password"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500



# Request Password Reset
@app.route('/forgot_password', methods=['POST'])
def forgot_password():
    try:
        data = request.json
        email_or_name = data.get('identifier')  # Email or username

        # Call the UserController to handle password reset request
        response = UserController.request_password_reset(email_or_name)
        if response.get("success"):
            return jsonify(response), 200
        return jsonify(response), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500





# Reset Password
@app.route('/reset_password', methods=['POST'])
def reset_password():
    try:
        data = request.json
        token = data.get('token')  # Reset token
        new_password = data.get('password')  # New password

        # Call the UserController to handle the password reset
        response = UserController.reset_password(token, new_password)
        if response.get("success"):
            return jsonify(response), 200
        return jsonify(response), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


#  yeh single image detection api hai yeh uncomment krna ho ga jb wo wala code run krna to

#-----------------------------   yeh single dteect ke api hai -----------------------------------------------------

@app.route('/api/detect_image', methods=['POST'])
def detect_image():
    try:
        user_id = request.form.get('user_id')
        print(f"Received user_id: {user_id}")
        if not user_id:
            return jsonify({"error": "User ID is required"}), 400

        if 'file' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['file']
        print(f"Received file: {file.filename}")
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        response, status_code = ContentController.save_content(file, int(user_id), 'Image')
        return jsonify(response), status_code

    except Exception as e:
        print(f"Route Exception: {str(e)}")  # Log the exception
        return jsonify({"error": str(e)}), 500


#----------------------------------------------------------------------------------------------------------


# Define the correct absolute path to your result folder//image screen k liye
# image show k rrha jo detect kr rha wo

@app.route('/result/<filename>')
def serve_result_file(filename):
    # folder_path = os.path.join(app.root_path, '..', 'uploads', 'result')   # multiple face k liye yeh
    folder_path = os.path.abspath(os.path.join('uploads', 'results'))    # yeh single image or multiple image disply k liye yeh

    full_path = os.path.join(folder_path, filename)
    print(f"Looking in: {full_path}")
    print("Saving image at:", os.path.join(folder_path, filename))

    if not os.path.exists(full_path):
        print(f"❌ File NOT FOUND: {full_path}")
    else:
        print(f"✅ File FOUND: {full_path}")

    return send_from_directory(folder_path, filename)




# ---------------------------------multiple image-------------------------

# Multiple image detection endpoint
@app.route('/detect_multiple_images', methods=['POST'])
def detect_multiple_images():
    try:
        user_id = request.form.get('user_id')
        if not user_id:
            return jsonify({"error": "User ID is required"}), 400

        images = request.files.getlist('images')
        if not images:
            return jsonify({"error": "No images uploaded"}), 400

        print(f"🔄 Received {len(images)} images from user_id: {user_id}")

        all_results = []

        for file in images:
            print(f"📷 Processing file: {file.filename}")
            response, status_code = ContentController.save_content(file, int(user_id), 'Image')

            if status_code == 200 and "details" in response:
                all_results.append(response["details"])
            else:
                print(f"❌ Error processing {file.filename}: {response.get('error')}")

        return jsonify({
            "message": "Multiple image detection completed",
            "results": all_results
        }), 200

    except Exception as e:
        print(f"❗ Exception in multiple image detection: {str(e)}")
        return jsonify({"error": str(e)}), 500



# ------------------------- delete history ek record--------------------------


@app.route('/delete_history_item', methods=['POST'])
def delete_history_item():
    data = request.json
    content_id = data.get("content_id")

    try:
        # Delete related results
        results = Result.query.filter_by(ContentID=content_id).all()
        for result in results:
            db.session.delete(result)

        # Delete the content itself
        content = Content.query.get(content_id)
        if content:
            db.session.delete(content)

        db.session.commit()
        return jsonify({"message": "History item deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# ------------------------ yeh all history ko dell kr rha-----------------------------------

@app.route('/delete_all_history', methods=['POST'])
def delete_all_history():
    try:
        user_id = request.form.get('user_id')
        print(f"🧹 Deleting all history for user_id: {user_id}")
        
        # Step 0: Get all content IDs for this user
        contents = db.session.query(Content).filter_by(UserID=user_id).all()
        content_ids = [c.ContentID for c in contents]
        
        print(f"🧼 Deleting from child tables for ContentIDs: {content_ids}")
        
        # Step 1: Get all ResultIDs for those ContentIDs
        results = db.session.query(Result).filter(Result.ContentID.in_(content_ids)).all()
        result_ids = [r.ResultID for r in results]
        
        # Step 2: Delete from Detail table using ResultIDs
        db.session.query(Detail).filter(Detail.ResultID.in_(result_ids)).delete(synchronize_session=False)
        
        # Step 3: Delete from Result table using ContentIDs
        db.session.query(Result).filter(Result.ContentID.in_(content_ids)).delete(synchronize_session=False)
        
        # Step 4: Delete from Image table using ContentIDs
        db.session.query(Image).filter(Image.ContentID.in_(content_ids)).delete(synchronize_session=False)
        
        # Step 5: Delete from Content table
        db.session.query(Content).filter(Content.ContentID.in_(content_ids)).delete(synchronize_session=False)
        
        db.session.commit()
        return jsonify({"message": "All history deleted successfully."}), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error deleting all history: {e}")
        return jsonify({"error": str(e)}), 500


# history me imahe display ke ip

# @app.route('/result/<filename>')
# def serve_resulthistory_file(filename):
#     folder_path = os.path.join(app.root_path, '..', 'uploads', 'test')
#     full_path = os.path.join(folder_path, filename)
#
#     if not os.path.exists(full_path):
#         print(f"❌ File NOT FOUND: {full_path}")
#     else:
#         print(f"✅ File FOUND: {full_path}")
#
#     return send_from_directory(folder_path, filename)


#form_data yeh use khai nhi ho rhe
@app.route('/upload_image', methods=['POST'])
def upload_image():
    try:
        # Check if 'file' is in the request
        if 'file' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['file']

        # Validate filename
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        # Get additional details from the request form
        user_id = request.form.get('userId')
        content_type = request.form.get('contentType')

        if not user_id or not content_type:
            return jsonify({"error": "Missing userId or contentType"}), 400

        # Process the file and metadata
        response = ContentController.save_content(file, user_id, content_type)

        return response

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    



# @app.route('/upload_video', methods=['POST'])
# def upload_video():
#     try:
#         if 'file' not in request.files:
#             return jsonify({"error": "No file part in the request"}), 400
#
#         file = request.files['file']
#
#         if file.filename == '':
#             return jsonify({"error": "No selected file"}), 400
#
#         if file:
            # Save the file (example: static/uploads/)
            # file_path = f"static/uploads/{file.filename}"
            # file.save(file_path)

            # # Process the video (mock processing)
            # result = process_video(file_path)  # Call your video processing logic
            #
            # def process_video(file_path):
            #     # Mock analysis result
            #     return {"status": "Fake", "confidence": 87.4}

            # Save result to the database
    #         ContentController.save_content(file)
    #
    #         return jsonify({"message": "Video uploaded and processed successfully", "result": result}), 200
    # except Exception as e:
    #     return jsonify({"error": str(e)}), 500

#params
@app.route('/view_result_details', methods=['GET'])
def view_result_details():
    try:
        # Get the user_id from query parameters
        result_id = request.args.get('result_id', type=int)

        if not result_id:
            return jsonify({"error": "Missing or invalid result_id"}), 400

        # Fetch history
        return ContentController.view_result_details(result_id)

    except Exception as e:
        return jsonify({"error": str(e)}), 500




@app.route('/get_generated_images', methods=['GET'])
def get_generated_images():
    result_folder = os.path.join('add_face', 'result')
    images = []

    for file_name in os.listdir(result_folder):
        if file_name.endswith(('.jpg', '.jpeg', '.png')):
            file_path = os.path.join(result_folder, file_name)
            with open(file_path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                images.append({
                    "file_name": file_name,
                    "base64_image": encoded_string,
                })

    print("🧾 Sending image list:", images)  # ✅ ADD THIS LINE

    return jsonify(images)

# ------------------------  deepfake generation api ------------------------------------

@app.route('/add_face', methods=['POST'])
def add_face():
    try:
        print("📂 request.files.keys():", request.files.keys())
        print("📃 request.form:", request.form)

        if 'source' not in request.files or 'target' not in request.files or 'user_id' not in request.form:
            return jsonify({'error': 'Missing parameters'}), 400

        source = request.files['source']
        target = request.files['target']
        user_id = request.form['user_id']

        print("✅ Sab data mila:", source.filename, target.filename, user_id)

        # ✅ New folders
        INPUT_FOLDER = os.path.join("add_face", "input")
        RESULT_FOLDER = os.path.join("add_face", "result")

        os.makedirs(INPUT_FOLDER, exist_ok=True)
        os.makedirs(RESULT_FOLDER, exist_ok=True)

        # ✅ Save images from correct keys
        source_path = os.path.join(INPUT_FOLDER, "source.jpg")
        target_path = os.path.join(INPUT_FOLDER, "target.jpg")
        source.save(source_path)
        target.save(target_path)

        print("📂 source_path exists:", os.path.exists(source_path))
        print("📂 target_path exists:", os.path.exists(target_path))

        if not os.path.exists(source_path) or not os.path.exists(target_path):
            raise ValueError("Failed to save one or both images")

        # ✅ Deepfake logic
        result_path = ContentController.swap_faces(source_path, target_path, RESULT_FOLDER)

        # ✅ Rename result
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        result_filename = f"result_{timestamp}.jpg"
        final_result_path = os.path.join(RESULT_FOLDER, result_filename)
        os.rename(result_path, final_result_path)

        # ✅ Encode image
        with open(final_result_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode('utf-8')

        # ✅ Save to DB
        user = db.session.query(User).filter_by(UserID=user_id).first()
        if not user:
            return jsonify({"error": f"User with UserID {user_id} not found"}), 400

        new_record = Generation(UserID=user_id, Path=final_result_path, media_type="Image")
        db.session.add(new_record)
        db.session.commit()

        return jsonify({
            "Result": "Face added successfully",
            "image": encoded_image,
            "saved_path": final_result_path
        }), 200

    except Exception as e:
        db.session.rollback()
        logging.error(f"Error in /add_face: {str(e)}")
        return jsonify({"error": str(e)}), 500

# -------------------------- generate deepfake with multiple target images------------------------
@app.route('/add_multiple_faces', methods=['POST'])
def add_multiple_faces():
    try:
        print("📂 request.files.keys():", request.files.keys())
        print("📃 request.form:", request.form)
        
        if 'source' not in request.files or 'user_id' not in request.form:
            return jsonify({'error': 'Missing source or user_id'}), 400
        
        source = request.files['source']
        target_files = request.files.getlist('targets')  # ✅ multiple targets
        user_id = request.form['user_id']
        
        if not target_files:
            return jsonify({'error': 'No target images provided'}), 400
        
        # ✅ Folder setup
        INPUT_FOLDER = os.path.join("add_face", "input")
        RESULT_FOLDER = os.path.join("add_face", "result")
        os.makedirs(INPUT_FOLDER, exist_ok=True)
        os.makedirs(RESULT_FOLDER, exist_ok=True)
        
        # ✅ Save source
        source_path = os.path.join(INPUT_FOLDER, "source.jpg")
        source.save(source_path)
        
        if not os.path.exists(source_path):
            raise ValueError("Failed to save source image")
        
        # ✅ User validation (optional)
        user = db.session.query(User).filter_by(UserID=user_id).first()
        if not user:
            return jsonify({"error": f"User with UserID {user_id} not found"}), 400
        
        results = []
        
        for index, target_file in enumerate(target_files):
            target_path = os.path.join(INPUT_FOLDER, f"target_{index}.jpg")
            target_file.save(target_path)
            
            result_path = ContentController.swap_faces(source_path, target_path, RESULT_FOLDER)
            
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            result_filename = f"result_{index}_{timestamp}.jpg"
            final_result_path = os.path.join(RESULT_FOLDER, result_filename)
            os.rename(result_path, final_result_path)
            
            with open(final_result_path, "rb") as image_file:
                encoded_image = base64.b64encode(image_file.read()).decode('utf-8')
            
            # ✅ Save each in DB (optional per result)
            new_record = Generation(UserID=user_id, Path=final_result_path, media_type="Image")
            db.session.add(new_record)
            
            results.append({
                "target_index": index,
                "image": encoded_image,
                "saved_path": final_result_path
            })
        
        db.session.commit()
        
        return jsonify({
            "Result": "Multiple faces swapped successfully",
            "results": results
        }), 200
    
    except Exception as e:
        db.session.rollback()
        logging.error(f"Error in /add_multiple_faces: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ---------------------------------- view history backup-----------------------------------------

@app.route('/view_history', methods=['GET'])
def view_history():
    try:
        user_id = request.args.get('user_id', type=int)
        if not user_id:
            return jsonify({"error": "Missing or invalid user_id"}), 400

        return ContentController.get_history(user_id)

    except Exception as e:
        print(f"❌ Exception in /view_history: {e}")
        return jsonify({"error": str(e)}), 500




# mahnoor Asking ya km ke nhi ha api
# @app.route('/user-content/<int:user_id>', methods=['GET'])
# def get_user_content_details(user_id):
#     try:
#         # Fetch user and related content using a join
#         user_with_content = (
#             db.session.query(User)
#             .options(joinedload(User.contents))
#             .filter(User.UserID == user_id)
#             .first()
#         )
#
#         if not user_with_content:
#             return jsonify({"error": "User not found"}), 404
#
#         # Structure response data
#         user_data = {
#             "UserID": user_with_content.UserID,
#             "Name": user_with_content.Name,
#             "Email": user_with_content.Email,
#             "Contents": [
#                 {
#                     "ContentID": content.ContentID,
#                     "Path": content.Path,
#                     "Type": content.Type
#                 }
#                 for content in user_with_content.contents
#             ]
#         }
#
#         return jsonify({"success": True, "data": user_data}), 200
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500


# @app.route('/api/all-records', methods=['GET'])
# def get_all_records():
#     try:
#         # Query to fetch all data across tables using joins
#         records = (
#             db.session.query(
#                 User.UserID,
#                 User.Name,
#                 User.Email,
#                 Content.ContentID,
#                 Content.Path,
#                 Content.Type,
#                 Image.Size.label('ImageSize'),
#                 Video.Duration.label('VideoDuration'),
#                 Result.Status,
#                 Detail.ConfidenceScore,
#                 Detail.Frame,
#                 Detail.Time
#             )
#             .outerjoin(Content, User.UserID == Content.UserID)
#             .outerjoin(Image, Content.ContentID == Image.ContentID)
#             .outerjoin(Video, Content.ContentID == Video.ContentID)
#             .outerjoin(Result, Content.ContentID == Result.ContentID)
#             .outerjoin(Detail, Result.ResultID == Detail.ResultID)
#             .all()
#         )
#
#         # Structure the results
#         all_records = []
#         for record in records:
#             all_records.append({
#                 "User": {
#                     "UserID": record.UserID,
#                     "Name": record.Name,
#                     "Email": record.Email
#                 },
#                 "Content": {
#                     "ContentID": record.ContentID,
#                     "Path": record.Path,
#                     "Type": record.Type
#                 },
#                 "Image": {
#                     "Size": record.ImageSize
#                 } if record.ImageSize else None,
#                 "Video": {
#                     "Duration": record.VideoDuration
#                 } if record.VideoDuration else None,
#                 "Result": {
#                     "Status": record.Status
#                 } if record.Status else None,
#                 "Detail": {
#                     "ConfidenceScore": record.ConfidenceScore,
#                     "Frame": record.Frame,
#                     "Time": record.Time
#                 } if record.ConfidenceScore else None
#             })
#
#         return jsonify({"success": True, "data": all_records}), 200
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500
#


#
# ------------------------------  multiple faces detection -------------------------------------
# multiple face detected in image
# -------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------


# @app.route('/api/detect_multiple_image', methods=['POST'])
# def detect_image_2():
#     try:
#         print("🚀 detect_multiple_image called from frontend")
#
#         user_id = request.form.get('user_id')
#         print(f"Received user_id: {user_id}")
#
#         if not user_id:
#             return jsonify({"error": "User ID is required"}), 400
#
#         if 'image' not in request.files:
#             print("❌ No image found in request.files")
#             return jsonify({"error": "No file part in the request"}), 400
#
#         image_file = request.files['image']  # ✅ fixed key
#         print(f"Received file: {image_file.filename}")
#
#         if image_file.filename == '':
#             return jsonify({"error": "No selected file"}), 400
#
#         response, status_code = ContentController.save_content_2(
#             image_file, int(user_id), 'Image'
#         )
#         return jsonify(response), status_code
#
#     except Exception as e:
#         print(f"Route Exception: {str(e)}")
#         return jsonify({"error": str(e)}), 500

# ------------------------------ multiple history fetch --------------------------


app.config['BASE_URL'] = "http://192.168.100.5:5000"


@app.route('/get_history_multipleface/<int:user_id>', methods=['GET'])
def get_history(user_id):
    try:
        # Get all content items by this user
        content_items = Content.query.filter_by(UserID=user_id).order_by(Content.ContentID.desc()).all()

        history = []
        for content in content_items:
            result = Result.query.filter_by(ContentID=content.ContentID).first()

            if result:
                # Get all detail entries linked to this result
                details = Detail.query.filter_by(ResultID=result.ResultID).all()

                # If there are detail entries, find the one with the highest ConfidenceScore
                if details:
                    main_detail = max(details, key=lambda d: d.ConfidenceScore)
                    confidence_score = main_detail.ConfidenceScore
                    result_image = main_detail.Frame
                else:
                    confidence_score = result.Confidence
                    result_image = None

                history.append({
                    "content_id": content.ContentID,
                    "path": content.Path,
                    "type": content.Type,
                    "status": result.Status,
                    "confidence": confidence_score,
                    "result_image": result_image
                })

        return jsonify({
            "status": "success",
            "history": history
        })

    except Exception as e:
        print(f"Error in get_history: {e}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/get_face_results/<int:content_id>', methods=['GET'])
def get_face_results(content_id):
    try:
        result = Result.query.filter_by(ContentID=content_id).first()
        if not result:
            return jsonify({'message': 'No result found', 'results': []})

        details = Detail.query.filter_by(ResultID=result.ResultID).all()
        response = [{
            'face_index': idx + 1,
            'confidence': d.ConfidenceScore,
            'result_image': d.Frame,
            'status': d.Status
        } for idx, d in enumerate(details)]

        return jsonify({'results': response})
    except Exception as e:
        return jsonify({'error': str(e)})
    


# ---------------------------- detect multple image at a time-------------------------------------

@app.route('/detect_all_models', methods=['POST'])
def detect_all_models():
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        # Call the ContentController method
        response = ContentController.save_and_detect(file, user_id=1, content_type="Image")  # Adjust user_id as needed
        return jsonify(response[0]), response[1]

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4321, debug=True)