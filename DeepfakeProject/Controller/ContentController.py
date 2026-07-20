from Model import db, Content, Image, Result, Detail, Video  # Assuming you have a Content model
import cv2
from Model.Configure import db, app
import dlib
import numpy as np
# from datetime import datetime   # yeh tb add ho ge jab multiple face detect ho gy
import datetime     # yeh tb krna hai jb single image wala krna ho

import os




from werkzeug.utils import secure_filename
from PIL import Image as PILImage
import pillow_avif  # 👈 necessary to enable AVIF support


from flask import Flask, send_from_directory, send_file
from PIL import Image as PILImage
from flask import current_app

import torch
from io import BytesIO
import tensorflow as tf
from torchvision import models
from facenet_pytorch import MTCNN


# -------for merge image swap
UPLOAD_FOLDER = 'add_face_merged'
INPUT_FOLDER = os.path.join(UPLOAD_FOLDER, 'input')
RESULT_FOLDER = os.path.join(UPLOAD_FOLDER, 'result')
# ✅ Yeh line ensure karein ke folders exist karein
os.makedirs(INPUT_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)

# -------------------------------------------------
UPLOAD_FOLDER = 'uploads/test'
RESULT_FOLDER = 'uploads/result'
app.config['RESULT_FOLDER'] = 'uploads/result'
FACE_FOLDER   = 'uploads/face'
os.makedirs(RESULT_FOLDER, exist_ok=True)
os.makedirs(FACE_FOLDER, exist_ok=True)

# At the top of your controller file
UPLOAD_FOLDER = os.path.join('uploads', 'test')
RESULT_FOLDER = os.path.join('uploads', 'results')

import logging

# Create a logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# Console handler
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)

# Format for logs
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
console_handler.setFormatter(formatter)

# Add handler to logger
logger.addHandler(console_handler)


# Configuration for Swin Transformer model
device = torch.device("cpu")  # Use CPU only
model_path = "C:/Users/Samia/Downloads/DeepfakeProject/swin_deepfake_mtcnn_final.pth"  # Update with your model path
mtcnn = MTCNN(image_size=224, margin=20, device=device)
model = models.swin_t(weights='DEFAULT')
model.head = torch.nn.Linear(model.head.in_features, 2)  # 2 classes: Real and Fake
model.load_state_dict(torch.load(model_path, map_location=device))
model = model.to(device)
model.eval()

# MTCNN face detector
detector = MTCNN()

# Dlib face detector and predictor for landmarks
dlib_detector = dlib.get_frontal_face_detector()
predictor = "C:/Users/Samia/Downloads/DeepfakeProject/shape_predictor_68_face_landmarks.dat"


class ContentController:



    # --------------------   yeh image 1 ko detect wala hai is ke api b alag ho ge acha ------------------------------------
    
    
    
    @staticmethod
    def preprocess_face(face):
        """Convert OpenCV image to PIL and preprocess for model."""
        face = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
        face = Image.fromarray(face)
        face_tensor = mtcnn(face)
        if face_tensor is None:
            return None
        face_tensor = face_tensor.unsqueeze(0).to(device)
        return face_tensor

    import cv2

    @staticmethod
    def detect_image(image_path):
        try:
            # Read the image
            img = cv2.imread(image_path)
            if img is None:
                return {"error": f"Could not load image at {image_path}"}, 400

            # Convert to PIL for MTCNN
            img_pil = Image.open(image_path).convert("RGB")

            # Detect face using MTCNN
            face_tensor = mtcnn(img_pil)
            if face_tensor is None:
                return {"error": "No face detected in the image."}, 400

            # Predict using Swin Transformer
            with torch.no_grad():
                output = model(face_tensor.unsqueeze(0).to(device))
                probs = torch.nn.functional.softmax(output, dim=1)
                predicted = torch.argmax(probs, dim=1).item()
                confidence = probs[0][predicted].item()
                label = "Fake" if predicted == 0 else "Real"

            # Draw bounding box and label on the image
            faces = mtcnn.detect(img_pil)
            if faces[0] is not None:
                for box in faces[0]:
                    x, y, w, h = [int(coord) for coord in box]
                    x, y = max(0, x), max(0, y)
                    color = (0, 0, 255) if predicted == 0 else (0, 255, 0)
                    cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
                    cv2.putText(img, f"{label} ({confidence * 100:.2f}%)", (x, y - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

            # Save the result image
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            save_path = os.path.join(RESULT_FOLDER, f"result_{timestamp}.jpg")
            cv2.imwrite(save_path, img)

            return {
                "message": "Image Processed Successfully!",
                "details": {
                    "result": label,
                    "confidence_score": float(confidence),
                    "result_image": f"result_{timestamp}.jpg"
                }
            }, 200

        except Exception as e:
            return {"error": str(e)}, 500


    @staticmethod
    def test_and_visualize(image_path, newContent):
        try:
            print(f"Processing image at: {image_path}")
            img = cv2.imread(image_path)
            if img is None:
                print(f"Failed to load image at {image_path}")
                return {"error": f"Could not load image at {image_path}"}, 400
            print("Image loaded successfully")

            img_pil = PILImage.open(image_path).convert("RGB")
            print("Face detection starting...")
            face_tensor = mtcnn(img_pil)  # Assuming mtcnn is globally defined
            if face_tensor is None:
                print("No face detected")
                return {"error": "No face detected in the image."}, 400
            print("Face detected successfully")

            print("Model prediction starting...")
            with torch.no_grad():
                output = model(face_tensor.unsqueeze(0).to(device))  # Assuming model and device are defined
                probs = torch.nn.functional.softmax(output, dim=1)
                predicted = torch.argmax(probs, dim=1).item()
                confidence = probs[0][predicted].item()
                label = "Fake" if predicted == 0 else "Real"
            print(f"Prediction: {label}, Confidence: {confidence}")

            faces = mtcnn.detect(img_pil)
            if faces[0] is not None:
                for box in faces[0]:
                    x, y, w, h = [int(coord) for coord in box]
                    x, y = max(0, x), max(0, y)
                    color = (0, 0, 255) if predicted == 0 else (0, 255, 0)
                    cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
                    cv2.putText(img, f"{label} ({confidence * 100:.2f}%)", (x, y - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            save_path = os.path.join(RESULT_FOLDER, f"result_{timestamp}.jpg")  # Assuming RESULT_FOLDER is defined
            print(f"Saving result to: {save_path}")
            cv2.imwrite(save_path, img)
            print(f"Result image saved at: {save_path}")

            db.session.add(newContent)
            db.session.commit()
            content_id = newContent.ContentID
            print(f"Content ID after commit: {content_id}")

            file_size_kb = os.path.getsize(image_path) / 1024
            if newContent.Type == 'Image':
                newImage = Image(ContentID=content_id, Size=file_size_kb)  # Corrected instantiation
                db.session.add(newImage)

            newResult = Result(ContentID=content_id, Status=label, Confidence=confidence)
            db.session.add(newResult)
            db.session.commit()
            print(f"Result ID: {newResult.ResultID}")

            fileNames = [{"image_path": save_path, "status": label, "threshold": float(confidence)}]
            print(f"Creating Detail objects for ResultID: {newResult.ResultID}")
            print(f"Detail type check: {type(Detail)}")
            for f in fileNames:
                print(f"Detail data: {f}")
                print(f"Attempting to create Detail object for ResultID: {newResult.ResultID}")
                newResultDetails = Detail(
                    ResultID=newResult.ResultID,
                    ConfidenceScore=f["threshold"],
                    Frame=f["image_path"],
                    Status=f["status"],

                )
                print(f"Created Detail object: {newResultDetails}")
                db.session.add(newResultDetails)

            db.session.commit()
            print("Database operations completed")

            return {
                "message": "Processing completed successfully.",
                "details": {
                    "content_id": content_id,
                    "result_id": newResult.ResultID,
                    "result": label,
                    "confidence_score": float(confidence),
                    "result_image": f"result_{timestamp}.jpg"
                }
            }, 200

        except Exception as e:
            print(f"Test and Visualize Exception: {str(e)}")
            import traceback
            print(f"Stack trace: {traceback.format_exc()}")
            db.session.rollback()
            return {"error": str(e)}, 500

    import datetime
    @staticmethod
    def save_content(file, user_id, content_type):
        try:
            print(f"Saving file for user_id: {user_id}")
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")  # Fixed line
            file_extension = os.path.splitext(file.filename)[1]
            file_name = f"{timestamp}{file_extension}"
            file_path = os.path.join(UPLOAD_FOLDER, file_name)  # Assuming UPLOAD_FOLDER is defined
            print(f"Saving to: {file_path}")
            file.save(file_path)
            print(f"File saved successfully at: {file_path}")

            new_content = Content(
                UserID=user_id,
                Path=file_name,
                Type=content_type
            )
            print(f"Created Content object: {new_content}")

            return ContentController.test_and_visualize(file_path, new_content)

        except Exception as e:
            print(f"Save Content Exception: {str(e)}")
            db.session.rollback()
            return {"error": f"Error saving content: {str(e)}"}, 500

 # ----------------------------------------------------------------------------------------------------
 # ---------------------------------------------------------------------------------------------------
    @staticmethod
    def view_result_details(result_id):
        try:
            # Fetch all content uploaded by the user
            contents = db.session.query(Detail).filter_by(ResultID=result_id).all()
            details = [
                {
                    "result_id": content.ResultID,
                    "file_name": content.Frame,
                    "status": content.Status,
                    "confidence_score": content.ConfidenceScore
                }
                for content in contents
            ]
            return details
        except Exception as e:
            raise Exception(f"Error fetching details: {str(e)}")

# -------------------   deepfake generate function -----------------------------------------
    @staticmethod
    def swap_faces(image1_path, image2_path, result_folder):
        try:
            img1 = cv2.imread(image1_path)
            img2 = cv2.imread(image2_path)
            if img1 is None or img2 is None:
                raise ValueError("Could not load one or both images")

            predictor_path = "C:/Users/Samia/Downloads/DeepfakeProject/shape_predictor_68_face_landmarks.dat"
            if not os.path.exists(predictor_path):
                raise FileNotFoundError(f"Predictor file not found: {predictor_path}")

            detector = dlib.get_frontal_face_detector()
            face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
            predictor = dlib.shape_predictor(predictor_path)

            image1 = cv2.resize(img1, (512, 512))
            image2 = cv2.resize(img2, (512, 512))

            gray1 = cv2.cvtColor(image1, cv2.COLOR_BGR2GRAY)
            gray2 = cv2.cvtColor(image2, cv2.COLOR_BGR2GRAY)

            faces1 = detector(gray1)
            faces2 = detector(gray2)

            if len(faces1) == 0 or len(faces2) == 0:
                raise ValueError("No faces detected in one or both images.")

            def get_landmarks(image, face):
                landmarks = predictor(image, face)
                return np.array([(p.x, p.y) for p in landmarks.parts()], dtype=np.int32)

            landmarks1 = get_landmarks(gray1, faces1[0])
            landmarks2 = get_landmarks(gray2, faces2[0])

            hull_index = cv2.convexHull(landmarks2, returnPoints=False)
            landmarks1_hull = np.array([landmarks1[idx[0]] for idx in hull_index])
            landmarks2_hull = np.array([landmarks2[idx[0]] for idx in hull_index])

            h_matrix, _ = cv2.findHomography(landmarks1_hull, landmarks2_hull, cv2.RANSAC)
            warped_image = cv2.warpPerspective(image1, h_matrix, (image2.shape[1], image2.shape[0]))

            mask = np.zeros_like(gray2)
            cv2.fillConvexPoly(mask, landmarks2_hull, 255)
            mask = cv2.GaussianBlur(mask, (15, 15), 10)

            center = (faces2[0].center().x, faces2[0].center().y)
            output = cv2.seamlessClone(warped_image, image2, mask, center, cv2.NORMAL_CLONE)

            result_path = os.path.join(result_folder, "temp_result.jpg")
            if not cv2.imwrite(result_path, output):
                raise ValueError("Failed to save result image")

            return result_path
        except Exception as e:
            raise ValueError(f"Face swap failed: {str(e)}")


    #     ----------------------------------------------------------------------------------------------
    

    @staticmethod
    
    def get_history(user_id):
        try:
            print(f"📥 Fetching history for user_id: {user_id}")
            contents = db.session.query(Content).filter_by(UserID=user_id).all()
            print(f"🧾 Found {len(contents)} contents")

            # Use HISTORY_FOLDER from config
            result_folder = os.path.join(current_app.root_path, current_app.config['RESULT_FOLDER'])
            print(f"📁 Using RESULT_FOLDER: {result_folder}")

            history = []

            for content in contents:
                file_name = content.Path
                file_path = os.path.join(result_folder, file_name)
                print(f"🔍 Checking: {file_path}")

                # Don't check os.path.exists here to prevent skipping
                history.append({
                    "id": content.ContentID,
                    "file_name": file_name,
                    "type": content.Type,
                    "result_id": content.result[0].ResultID if content.result else None,
                    "status": content.result[0].Status if content.result else None,
                    "datetime": content.result[0].details[0].Time.strftime('%Y-%m-%d %H:%M:%S') if content.result and
                                                                                                   content.result[
                                                                                                       0].details else None
                    
                })

            return history

        except Exception as e:
            print(f"❌ Error in RESULT_FOLDER: {e}")
            raise Exception(f"Error fetching history: {str(e)}")

    
    
        
    #---------------------------------video working -------------------------------------------------
    @staticmethod
    def extract_video_frames_with_faces(video_path, max_frames=5, min_face_confidence=0.5, frame_strategy="fixed",
                                        interval=None, max_interval_frames=None):
        """Extract frames with faces from the video based on the specified strategy."""
        try:
            cap = cv2.VideoCapture(video_path)
            if not cap.isOpened():
                return {"error": f"Could not open video at {video_path}"}, 400
            
            duration = cap.get(cv2.CAP_PROP_FRAME_COUNT) / cap.get(cv2.CAP_PROP_FPS)
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            fps = cap.get(cv2.CAP_PROP_FPS)
            frames = []
            frame_paths = []
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            
            # Determine frame indices based on strategy
            if frame_strategy == "fixed":
                # Extract exactly max_frames (or fewer if not enough faces)
                frame_indices = np.random.choice(total_frames, min(max_frames, total_frames), replace=False)
                frame_indices = sorted(frame_indices)
            elif frame_strategy == "fixed4":
                # Extract exactly 4 evenly spaced frames (or fewer if not enough faces or frames)
                frame_indices = np.linspace(0, total_frames - 1, min(4, total_frames), dtype=int)
                frame_indices = sorted(set(frame_indices))
            elif frame_strategy == "random":
                # Extract a random number of frames up to max_frames
                num_frames = np.random.randint(1, min(max_frames + 1, total_frames + 1))
                frame_indices = np.random.choice(total_frames, num_frames, replace=False)
                frame_indices = sorted(frame_indices)
            elif frame_strategy == "random5":
                # Extract exactly 5 random frames (or fewer if not enough faces or frames)
                frame_indices = np.random.choice(total_frames, min(5, total_frames), replace=False)
                frame_indices = sorted(frame_indices)
            elif frame_strategy == "interval":
                # Extract frames at specified intervals (seconds or frames)
                if interval is None:
                    return {"error": "Interval must be specified for interval strategy"}, 400
                if isinstance(interval, float):  # Interval in seconds
                    interval_frames = int(interval * fps)
                else:  # Interval in frames
                    interval_frames = int(interval)
                frame_indices = list(range(0, total_frames, interval_frames))
                if max_interval_frames is not None:
                    frame_indices = frame_indices[:max_interval_frames]
            else:
                return {"error": f"Invalid frame_strategy: {frame_strategy}"}, 400
            
            # Extract frames with faces
            for idx, frame_idx in enumerate(frame_indices):
                cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
                ret, frame = cap.read()
                if not ret:
                    continue
                
                frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame_pil = PILImage.fromarray(frame_rgb)
                
                face_tensor = mtcnn(frame_pil)
                if face_tensor is None:
                    continue
                
                faces = mtcnn.detect(frame_pil)
                if faces[0] is not None and faces[1][0] >= min_face_confidence:
                    frame_path = os.path.join(RESULT_FOLDER, f"frame_{timestamp}_{idx}.jpg")
                    cv2.imwrite(frame_path, frame)
                    frames.append(frame)
                    frame_paths.append(frame_path)
            
            cap.release()
            if not frames:
                return {"error": "No frames with faces detected in the video"}, 400
            
            print(f"Extracted {len(frames)} frames with faces using {frame_strategy} strategy")
            return {"frames": frames, "frame_paths": frame_paths, "duration": duration}, 200
        
        except Exception as e:
            print(f"Extract Video Frames Exception: {str(e)}")
            return {"error": str(e)}, 500
    
    @staticmethod
    def process_video(video_path, new_content):
        try:
            print(f"Processing video at: {video_path}")
            # Use fixed strategy by default; adjust parameters as needed
            frame_result, status_code = ContentController.extract_video_frames_with_faces(
                video_path,
                max_frames=5,
                min_face_confidence=0.5,
                frame_strategy="fixed4",  # Options: "fixed", "random", "interval"
                interval=1.0,  # For interval: 1 second
                max_interval_frames=5  # Optional limit for interval
            )
            if status_code != 200:
                return frame_result, status_code
            
            frames = frame_result["frames"]
            frame_paths = frame_result["frame_paths"]
            duration = frame_result["duration"]
            print(f"Extracted {len(frames)} frames with faces")
            
            results = []
            for idx, (frame, frame_path) in enumerate(zip(frames[:4], frame_paths[:4])):
                print(f"Processing frame {idx} at: {frame_path}")
                frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame_pil = PILImage.fromarray(frame_rgb)
                face_tensor = mtcnn(frame_pil)
                if face_tensor is None:
                    print(f"No face detected in frame {idx}")
                    results.append({"status": "Error", "confidence": None, "frame_path": frame_path})
                    continue
                
                with torch.no_grad():
                    output = model(face_tensor.unsqueeze(0).to(device))
                    probs = torch.nn.functional.softmax(output, dim=1)
                    predicted = torch.argmax(probs, dim=1).item()
                    confidence = probs[0][predicted].item()
                    label = "Fake" if predicted == 0 else "Real"
                
                faces = mtcnn.detect(frame_pil)
                if faces[0] is not None:
                    for box in faces[0]:
                        x, y, w, h = [int(coord) for coord in box]
                        x, y = max(0, x), max(0, y)
                        color = (0, 0, 255) if predicted == 0 else (0, 255, 0)
                        cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
                        cv2.putText(frame, f"{label} ({confidence * 100:.2f}%)", (x, y - 10),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
                
                cv2.imwrite(frame_path, frame)
                results.append({"status": label, "confidence": float(confidence), "frame_path": frame_path})
                print(f"Frame {idx} result: {label}, Confidence: {confidence}")
            
            # Filter valid results (exclude "Error" frames)
            valid_results = [r for r in results if r["status"] != "Error"]
            if not valid_results:
                return {"error": "No valid frames processed"}, 400
            
            # Calculate overall status: majority vote (more than 50% Fake -> Fake)
            deepfake_count = sum(1 for r in valid_results if r["status"] == "Fake")
            total_valid = len(valid_results)
            overall_status = "Fake" if total_valid > 0 and deepfake_count > total_valid // 2 else "Real"
            
            # Calculate overall confidence: average of valid confidences
            valid_confidences = [r["confidence"] for r in valid_results if r["confidence"] is not None]
            overall_confidence = sum(valid_confidences) / len(valid_confidences) if valid_confidences else 0.0
            
            print(f"Overall status: {overall_status}, Overall confidence: {overall_confidence}")
            
            # Save to database
            db.session.add(new_content)
            db.session.commit()
            content_id = new_content.ContentID
            print(f"Video Content ID after commit: {content_id}")
            
            file_size_kb = os.path.getsize(video_path) / 1024
            new_video = Video(ContentID=content_id, Duration=duration)
            db.session.add(new_video)
            
            new_result = Result(ContentID=content_id, Status=overall_status, Confidence=overall_confidence)
            db.session.add(new_result)
            db.session.commit()
            print(f"Video Result ID: {new_result.ResultID}")
            
            for idx, r in enumerate(results):
                new_detail = Detail(
                    ResultID=new_result.ResultID,
                    ConfidenceScore=r["confidence"] if r["confidence"] is not None else 0.0,
                    Frame=r["frame_path"],
                    Status=r["status"],
                    # nose=False,
                    # eyes=False,
                    # lips=False,
                    # faceswap=False,
                    # nose_conf=0.0,
                    # eyes_conf=0.0,
                    # lips_conf=0.0,
                    # faceswap_conf=0.0
                )
                print(
                    f"Saving Detail {idx}: Frame={r['frame_path']}, Status={r['status']}, Confidence={r['confidence']}")
                db.session.add(new_detail)
            
            db.session.commit()
            print("Video database operations completed")
            
            return {
                "message": "Video Processed Successfully!",
                "details": {
                    "content_id": content_id,
                    "result_id": new_result.ResultID,
                    "result": overall_status,
                    "confidence_score": float(overall_confidence),
                    "frame_results": [
                        {
                            "frame": os.path.basename(r["frame_path"]),
                            "status": r["status"],
                            "confidence_score": r["confidence"] if r["confidence"] is not None else None
                        } for r in results
                    ]
                }
            }, 200
        
        except Exception as e:
            print(f"Process Video Exception: {str(e)}")
            import traceback
            print(f"Stack trace: {traceback.format_exc()}")
            db.session.rollback()
            return {"error": str(e)}, 500
    
    @staticmethod
    def save_video_content(file, user_id):
        try:
            print(f"Saving video file for user_id: {user_id}")
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            file_extension = os.path.splitext(file.filename)[1]
            file_name = f"{timestamp}{file_extension}"
            file_path = os.path.join(UPLOAD_FOLDER, file_name)
            print(f"Saving video to: {file_path}")
            file.save(file_path)
            print(f"Video file saved successfully at: {file_path}")
            
            new_content = Content(
                UserID=user_id,
                Path=file_name,
                Type='Video'
            )
            print(f"Created Video Content object: {new_content}")
            
            return ContentController.process_video(file_path, new_content)
        
        except Exception as e:
            print(f"Save Video Content Exception: {str(e)}")
            db.session.rollback()
            return {"error": f"Error saving video content: {str(e)}"}, 500
        
    
#
#
# --------------------- multiple face detection function -------------------------------------
# --------------------------------------------------------------------------------------------
    
    # @staticmethod
    # def preprocess_face_2(face):
    #     """Convert OpenCV image to PIL and preprocess for model."""
    #     try:
    #         logger.debug("Preprocessing face image")
    #         face = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
    #         face = PILImage.fromarray(face)
    #         face_tensor = mtcnn(face)
    #         if face_tensor is None:
    #             logger.warning("MTCNN failed to detect a face in the cropped region")
    #             return None
    #         face_tensor = face_tensor.unsqueeze(0).to(device)
    #         logger.debug("Face preprocessed successfully")
    #         return face_tensor
    #     except Exception as e:
    #         logger.error(f"Error in preprocess_face: {str(e)}", exc_info=True)
    #         return None
    #
    #
    # @staticmethod
    # def detect_faces_2(image_path):
    #     try:
    #         logger.debug(f"Loading image from {image_path}")
    #         # img = cv2.imread(image_path)
    #         # if img is None:
    #         #     logger.error(f"Could not load image at {image_path}")
    #         #     return {"error": f"Could not load image at {image_path}"}, 400
    #         try:
    #             img_pil = PILImage.open(image_path).convert("RGB")
    #             img = np.array(img_pil)
    #         except Exception as e:
    #             logger.error(f"Could not load image at {image_path}: {e}")
    #             return {"error": f"Could not load image at {image_path}"}, 400
    #
    #         img_pil = PILImage.open(image_path).convert("RGB")
    #         logger.debug("Detecting faces with MTCNN")
    #         faces, _ = mtcnn.detect(img_pil)
    #         if faces is None or len(faces) == 0:
    #             logger.warning("No faces detected in the image")
    #             return {"error": "No faces detected in the image."}, 400
    #
    #         results = []
    #         # for i, box in enumerate(faces[:2]):  # Process up to two faces
    #         for i, box in enumerate(faces):
    #             logger.debug(f"Processing face {i + 1}")
    #             x, y, w, h = [int(coord) for coord in box]
    #             x, y = max(0, x), max(0, y)
    #             face_img = img[y:y + h, x:x + w]
    #             if face_img.size == 0:
    #                 logger.warning(f"Empty cropped region for face {i + 1}")
    #                 results.append({"error": f"Empty cropped region for face {i + 1}"})
    #                 continue
    #
    #             # Preprocess and predict
    #             face_tensor = ContentController.preprocess_face_2(face_img)
    #             if face_tensor is None:
    #                 logger.warning(f"No face detected in cropped region {i + 1}")
    #                 results.append({"error": f"No face detected in cropped region {i + 1}"})
    #                 continue
    #
    #             logger.debug(f"Running model prediction for face {i + 1}")
    #             with torch.no_grad():
    #                 output = model(face_tensor)
    #                 probs = torch.nn.functional.softmax(output, dim=1)
    #                 predicted = torch.argmax(probs, dim=1).item()
    #                 confidence = probs[0][predicted].item()
    #                 label = "Fake" if predicted == 0 else "Real"
    #             logger.debug(f"Prediction for face {i + 1}: {label}, Confidence: {confidence}")
    #
    #             # Annotate the cropped face
    #             cv2.rectangle(face_img, (0, 0), (w, h), (0, 0, 255) if predicted == 0 else (0, 255, 0), 2)
    #             cv2.putText(face_img, f"{label} ({confidence * 100:.2f}%)", (10, 20),
    #                         cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255) if predicted == 0 else (0, 255, 0), 2)
    #
    #             # Save the annotated face image
    #             timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    #             print("✅ datetime working:", datetime.now())
    #             filename = f"face_{i + 1}_{timestamp}.jpg"  # ✅ define filename
    #             save_path = os.path.join(app.config['RESULT_FOLDER'], filename)
    #             logger.debug(f"Saving annotated face {i + 1} to {save_path}")
    #
    #             cv2.imwrite(save_path, face_img)
    #             print(f"Saved face {i + 1} as {filename}")  # ✅ no error now
    #
    #             results.append({
    #                 "result": label,
    #                 "confidence_score": float(confidence),
    #                 "result_image": f"face_{i + 1}_{timestamp}.jpg",
    #
    #                 "face_index": i + 1
    #             })
    #
    #
    #         if not results:
    #             logger.warning("No valid faces processed")
    #             return {"error": "No valid faces processed."}, 400
    #
    #         logger.debug(f"Face detection completed: {len(results)} faces processed")
    #         return {"results": results}, 200
    #
    #     except Exception as e:
    #         logger.error(f"Error in detect_faces: {str(e)}", exc_info=True)
    #         return {"error": str(e)}, 500
    #
    # @staticmethod
    # def test_and_visualize_2(image_path, new_content):
    #     try:
    #         logger.debug(f"Starting test_and_visualize for {image_path}")
    #         result, status_code = ContentController.detect_faces_2(image_path)
    #         if status_code != 200:
    #             logger.error(f"Face detection failed: {result['error']}")
    #             return result, status_code
    #
    #         logger.debug("Adding content to database")
    #         db.session.add(new_content)
    #         db.session.commit()
    #         content_id = new_content.ContentID
    #         logger.debug(f"Content saved with ContentID: {content_id}")
    #
    #         file_size_kb = os.path.getsize(image_path) / 1024
    #         if new_content.Type == 'Image':
    #             new_image = Image(ContentID=content_id, Size=file_size_kb)
    #             db.session.add(new_image)
    #             logger.debug("Image metadata added to database")
    #
    #         face_results = []
    #         for face_data in result["results"]:
    #             if "error" in face_data:
    #                 face_results.append(face_data)
    #                 continue
    #
    #             logger.debug(f"Saving result for face {face_data['face_index']}")
    #             new_result = Result(
    #                 ContentID=content_id,
    #                 Status=face_data["result"],
    #                 Confidence=face_data["confidence_score"]
    #             )
    #             db.session.add(new_result)
    #             db.session.commit()
    #             logger.debug(f"Result saved with ResultID: {new_result.ResultID}")
    #
    #             new_result_details = Detail(
    #                 ResultID=new_result.ResultID,
    #                 ConfidenceScore=face_data["confidence_score"],
    #                 Frame=face_data["result_image"],
    #                 Status=face_data["result"],
    #                 # nose=False,
    #                 # eyes=False,
    #                 # lips=False,
    #                 # faceswap=False,
    #                 # nose_conf=0.0,
    #                 # eyes_conf=0.0,
    #                 # lips_conf=0.0,
    #                 # faceswap_conf=0.0
    #             )
    #             db.session.add(new_result_details)
    #             face_results.append({
    #                 "content_id": content_id,
    #                 "result_id": new_result.ResultID,
    #                 "result": face_data["result"],
    #                 "confidence_score": face_data["confidence_score"],
    #                 "result_image": face_data["result_image"],
    #                 "face_index": face_data["face_index"]
    #             })
    #
    #         db.session.commit()
    #         logger.debug("Database operations completed")
    #
    #         return {
    #             "message": "Processing completed successfully.",
    #             "results": face_results
    #         }, 200
    #
    #     except Exception as e:
    #         logger.error(f"Error in test_and_visualize: {str(e)}", exc_info=True)
    #         db.session.rollback()
    #         return {"error": str(e)}, 500
    #
    #
    # from datetime import datetime
    #
    # @staticmethod
    # def save_content_2(file, user_id, content_type):
    #     try:
    #         logger.debug(f"Saving file for user_id: {user_id}, content_type: {content_type}")
    #         timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    #         filename = f"image_{timestamp}.jpg"  # ✅ filename defined
    #         print(f"✅ File will be saved as: {filename}")
    #         print(f"✅ datetime test: {datetime.now()}")
    #
    #         file_extension = os.path.splitext(secure_filename(file.filename))[1]
    #         file_name = f"{timestamp}{file_extension}"
    #         file_path = os.path.join(app.config['UPLOAD_FOLDER'], file_name)
    #         logger.debug(f"Saving file to {file_path}")
    #         file.save(file_path)
    #         logger.debug(f"File saved successfully: {file_path}")
    #
    #         new_content = Content(
    #             UserID=user_id,
    #             Path=file_name,
    #             Type=content_type
    #         )
    #         logger.debug("Content object created")
    #         # return ContentController.test_and_visualize_2(file_path, new_content)
    #
    #         # Run face detection and DB saving
    #         result_data, status_code = ContentController.test_and_visualize_2(file_path, new_content)
    #
    #         # ✅ Inject original image path into response
    #         if status_code == 200:
    #             result_data["original_path"] = file_name  # This will be used to show the uploaded image
    #
    #         return result_data, status_code
    #
    #     except Exception as e:
    #         logger.error(f"Error in save_content: {str(e)}", exc_info=True)
    #         db.session.rollback()
    #         return {"error": f"Error saving content: {str(e)}"}, 500
    #
    #


# ----------------------------------------------------------------------------------------------------
# --------------------------------merge faceswap-------------------------------------------------------
    
    # print("🔧 get_lee defined")
    #
    # def get_lee(image, face_rect, predictor):
    #     landmarks = predictor(image, face_rect)
    #     return np.array([(p.x, p.y) for p in landmarks.parts()], dtype=np.int32)
    #
    # def swap_faces_2(source_img, target_img, predictor):
    #     detector = dlib.get_frontal_face_detector()
    #
    #     source_img = cv2.resize(source_img, (512, 512))
    #     target_img = cv2.resize(target_img, (512, 512))
    #
    #     gray1 = cv2.cvtColor(source_img, cv2.COLOR_BGR2GRAY)
    #     gray2 = cv2.cvtColor(target_img, cv2.COLOR_BGR2GRAY)
    #
    #     faces1 = detector(gray1)
    #     faces2 = detector(gray2)
    #
    #     if len(faces1) == 0 or len(faces2) == 0:
    #         raise ValueError("No faces found")
    #
    #     # ✅ Use the correct function name here
    #     landmarks1 = get_lee(gray1, faces1[0], predictor)
    #     landmarks2 = get_lee(gray2, faces2[0], predictor)
    #
    #     hull_index = cv2.convexHull(landmarks2, returnPoints=False)
    #     landmarks1_hull = np.array([landmarks1[idx[0]] for idx in hull_index])
    #     landmarks2_hull = np.array([landmarks2[idx[0]] for idx in hull_index])
    #
    #     h_matrix, _ = cv2.findHomography(landmarks1_hull, landmarks2_hull, cv2.RANSAC)
    #     warped_image = cv2.warpPerspective(source_img, h_matrix, (target_img.shape[1], target_img.shape[0]))
    #
    #     mask = np.zeros_like(gray2)
    #     cv2.fillConvexPoly(mask, landmarks2_hull, 255)
    #     mask = cv2.GaussianBlur(mask, (15, 15), 10)
    #
    #     center = (faces2[0].center().x, faces2[0].center().y)
    #     output = cv2.seamlessClone(warped_image, target_img, mask, center, cv2.NORMAL_CLONE)
    #
    #     return output
    #
    #
    @staticmethod
    def swap_faces_features(image1_path, image2_path, result_folder, feature_type=1):
        try:
            # Load images
            img1 = cv2.imread(image1_path)
            img2 = cv2.imread(image2_path)
            if img1 is None or img2 is None:
                raise ValueError("Could not load one or both images")
            
            # Initialize dlib detector and predictor
            predictor_path = "C:/Users/Samia/Downloads/DeepfakeProject/shape_predictor_68_face_landmarks.dat"
            if not os.path.exists(predictor_path):
                raise FileNotFoundError(f"Predictor file not found: {predictor_path}")
            
            detector = dlib.get_frontal_face_detector()
            predictor = dlib.shape_predictor(predictor_path)
            
            # Resize images
            image1 = cv2.resize(img1, (512, 512))
            image2 = cv2.resize(img2, (512, 512))
            
            # Convert to grayscale
            gray1 = cv2.cvtColor(image1, cv2.COLOR_BGR2GRAY)
            gray2 = cv2.cvtColor(image2, cv2.COLOR_BGR2GRAY)
            
            # Detect faces
            faces1 = detector(gray1)
            faces2 = detector(gray2)
            if len(faces1) == 0 or len(faces2) == 0:
                raise ValueError("No faces detected in one or both images.")
            
            # Function to extract facial landmarks
            def get_landmarks(image, face):
                landmarks = predictor(image, face)
                return np.array([(p.x, p.y) for p in landmarks.parts()], dtype=np.int32)
            
            landmarks1 = get_landmarks(gray1, faces1[0])
            landmarks2 = get_landmarks(gray2, faces2[0])
            
            # Define landmark indices for features
            feature_indices = {
                1: [27, 28, 29, 30, 31, 32, 33, 34, 35],  # Nose
                2: [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67],  # Lips
                3: [36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47],  # Eyes
                4: list(range(68))  # Full face (all landmarks)
            }
            
            # Validate feature_type
            if feature_type not in [1, 2, 3, 4]:
                raise ValueError("Invalid feature_type. Must be 1 (nose), 2 (lips), 3 (eyes), or 4 (full face)")
            
            # Get feature landmarks
            feature1 = landmarks1[feature_indices[feature_type]]
            feature2 = landmarks2[feature_indices[feature_type]]
            
            # Function to create a rectangular region for the feature (fallback to avoid hull issues)
            def get_feature_region(landmarks):
                try:
                    hull = cv2.convexHull(landmarks, returnPoints=True)
                    if hull.shape[0] < 3:
                        print(
                            f"Warning: Convex hull for feature is degenerate (less than 3 points). Using bounding box.")
                        x, y, w, h = cv2.boundingRect(landmarks)
                        return np.array([[x, y], [x + w, y], [x + w, y + h], [x, y + h]], dtype=np.int32)
                    return hull
                except Exception as e:
                    print(f"Error computing convex hull: {e}. Using bounding box.")
                    x, y, w, h = cv2.boundingRect(landmarks)
                    return np.array([[x, y], [x + w, y], [x + w, y + h], [x, y + h]], dtype=np.int32)
            
            # Get feature regions
            feature_hull1 = get_feature_region(feature1)
            feature_hull2 = get_feature_region(feature2)
            
            # Debug: Print shapes
            print(f"Debug: feature_hull1 shape: {feature_hull1.shape}")
            print(f"Debug: feature_hull2 shape: {feature_hull2.shape}")
            
            # Ensure hulls have the same number of points
            if feature_hull1.shape[0] != feature_hull2.shape[0]:
                print("Warning: Source and destination hulls have different number of points.")
                x1, y1, w1, h1 = cv2.boundingRect(feature1)
                x2, y2, w2, h2 = cv2.boundingRect(feature2)
                feature_hull1 = np.array([[x1, y1], [x1 + w1, y1], [x1 + w1, y1 + h1], [x1, y1 + h1]], dtype=np.int32)
                feature_hull2 = np.array([[x2, y2], [x2 + w2, y2], [x2 + w2, y2 + h2], [x2, y2 + h2]], dtype=np.int32)
                print(f"Debug: Adjusted feature_hull1 shape: {feature_hull1.shape}")
                print(f"Debug: Adjusted feature_hull2 shape: {feature_hull2.shape}")
            
            # Function to warp and swap feature region
            def warp_feature_region(src_img, src_hull, dst_hull, dst_img_shape):
                try:
                    h_matrix, _ = cv2.findHomography(src_hull, dst_hull, cv2.RANSAC)
                    if h_matrix is None:
                        print("Error: Homography computation failed.")
                        return None, None
                    warped_feature = cv2.warpPerspective(src_img, h_matrix, (dst_img_shape[1], dst_img_shape[0]))
                    return warped_feature, dst_hull
                except Exception as e:
                    print(f"Error in warp_feature_region: {e}")
                    return None, None
            
            # Warp feature from image1 to image2
            warped_feature1, feature_hull2 = warp_feature_region(image1, feature_hull1, feature_hull2, image2.shape)
            if warped_feature1 is None:
                raise ValueError("Feature warping failed.")
            
            # Create mask for feature region
            feature_mask = np.zeros_like(gray2)
            cv2.fillConvexPoly(feature_mask, feature_hull2, 255)
            feature_mask = cv2.GaussianBlur(feature_mask, (15, 15), 10)
            
            # Compute center for seamless cloning
            try:
                if len(feature_hull2.shape) == 3:  # Shape is (n, 1, 2) from convexHull
                    feature_center = (int(np.mean(feature_hull2[:, :, 0])), int(np.mean(feature_hull2[:, :, 1])))
                else:  # Shape is (n, 2) from bounding box
                    feature_center = (int(np.mean(feature_hull2[:, 0])), int(np.mean(feature_hull2[:, 1])))
            except IndexError as e:
                raise ValueError(f"Error computing feature center: {e}")
            
            # Perform seamless cloning
            output = image2.copy()
            try:
                output = cv2.seamlessClone(warped_feature1, output, feature_mask, feature_center, cv2.NORMAL_CLONE)
            except Exception as e:
                raise ValueError(f"Error in seamless cloning: {e}")
            
            # Save the output file
            result_path = os.path.join(result_folder, "temp_result.jpg")
            try:
                if not cv2.imwrite(result_path, output):
                    raise ValueError("Failed to save result image")
            except Exception as e:
                raise ValueError(f"Error saving result image: {e}")
            
            return result_path
        
        except Exception as e:
            raise ValueError(f"Face swap failed: {str(e)}")
    #     ------------------------------------------------------------------------------------------------------------

    
    # Load once
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor(predictor)
    
    # Landmark indices for features
    FEATURES = {
        "eyes": list(range(36, 48)),
        "nose": list(range(27, 36)),
        "lips": list(range(48, 68)),
        "full_face": list(range(0, 68)),
    }
    
    @staticmethod
    def get_landmarks(image):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = ContentController.detector(gray)
        if len(faces) == 0:
            raise ValueError("No face detected in image")
        landmarks = ContentController.predictor(gray, faces[0])
        return np.array([(p.x, p.y) for p in landmarks.parts()], dtype=np.int32), faces[0]
    
    @staticmethod
    def swap_feature(source_img, src_landmarks, target_img, tgt_landmarks, feature_name):
        if feature_name not in ContentController.FEATURES:
            raise ValueError(f"Invalid feature name: {feature_name}")
        
        idx = ContentController.FEATURES[feature_name]
        src_pts = src_landmarks[idx]
        tgt_pts = tgt_landmarks[idx]
        
        # Create feature mask from target
        mask = np.zeros_like(target_img)
        cv2.fillConvexPoly(mask, cv2.convexHull(tgt_pts), (255, 255, 255))
        target_feature = cv2.bitwise_and(target_img, mask)
        
        # Warp target feature onto source
        H, _ = cv2.findHomography(tgt_pts, src_pts, cv2.RANSAC)
        warped_feature = cv2.warpPerspective(target_feature, H, (source_img.shape[1], source_img.shape[0]))
        warped_mask = cv2.warpPerspective(mask, H, (source_img.shape[1], source_img.shape[0]))
        
        # Compute center for seamless clone
        center = tuple(np.mean(src_pts, axis=0).astype(int))
        
        result = cv2.seamlessClone(
            warped_feature,
            source_img,
            cv2.cvtColor(warped_mask, cv2.COLOR_BGR2GRAY),
            center,
            cv2.NORMAL_CLONE
        )
        
        return result
    #-------------------------------------------------------- detection new function--------------------
    @staticmethod
    def preprocess_region(region, target_size=(128, 128)):
        """Preprocess a cropped region for model input."""
        region = cv2.resize(region, target_size)
        region = region.astype('float32') / 255.0  # Normalize to [0, 1]
        region = np.expand_dims(region, axis=0)  # Add batch dimension
        return region
    
    @staticmethod
    def extract_facial_regions(image, landmarks):
        """Extract nose, lips, and eyes regions using landmarks."""
        # Nose: indices 27-35
        nose_points = np.array([(landmarks.part(i).x, landmarks.part(i).y) for i in range(27, 36)], dtype=np.int32)
        # Lips: indices 48-67
        lips_points = np.array([(landmarks.part(i).x, landmarks.part(i).y) for i in range(48, 68)], dtype=np.int32)
        # Eyes: left (36-41), right (42-47)
        left_eye_points = np.array([(landmarks.part(i).x, landmarks.part(i).y) for i in range(36, 42)], dtype=np.int32)
        right_eye_points = np.array([(landmarks.part(i).x, landmarks.part(i).y) for i in range(42, 48)], dtype=np.int32)
        
        # Calculate bounding boxes with padding
        padding = 10
        nose_box = cv2.boundingRect(nose_points)
        lips_box = cv2.boundingRect(lips_points)
        left_eye_box = cv2.boundingRect(left_eye_points)
        right_eye_box = cv2.boundingRect(right_eye_points)
        
        # Extract regions
        x, y, w, h = nose_box
        nose_crop = image[max(0, y - padding):y + h + padding, max(0, x - padding):x + w + padding]
        x, y, w, h = lips_box
        lips_crop = image[max(0, y - padding):y + h + padding, max(0, x - padding):x + w + padding]
        x, y, w, h = left_eye_box
        left_eye_crop = image[max(0, y - padding):y + h + padding, max(0, x - padding):x + w + padding]
        x, y, w, h = right_eye_box
        right_eye_crop = image[max(0, y - padding):y + h + padding, max(0, x - padding):x + w + padding]
        
        return nose_crop, lips_crop, left_eye_crop, right_eye_crop
    
    @staticmethod
    def detect_all_models(image_path, user_id, content_type):
        """Process image through all four models and return aggregated results."""
        try:
            # Read the image
            img = cv2.imread(image_path)
            if img is None:
                return {"error": f"Could not load image at {image_path}"}, 400
            
            # Detect faces using MTCNN
            faces = detector.detect_faces(img)
            if not faces:
                return {"error": "No faces detected in the image."}, 400
            
            # Use dlib for landmarks
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            dlib_faces = dlib_detector(gray)
            if not dlib_faces:
                return {"error": "No faces detected by dlib."}, 400
            
            # Get landmarks for the first face
            landmarks = predictor(gray, dlib_faces[0])
            
            # Extract regions
            nose_crop, lips_crop, left_eye_crop, right_eye_crop = ContentController.extract_facial_regions(img,
                                                                                                           landmarks)
            
            # Preprocess regions
            nose_input = ContentController.preprocess_region(nose_crop)
            lips_input = ContentController.preprocess_region(lips_crop)
            left_eye_input = ContentController.preprocess_region(left_eye_crop)
            right_eye_input = ContentController.preprocess_region(right_eye_crop)
            face_input = ContentController.preprocess_region(img)  # Full face for face swap model
            
            # Predict using models
            nose_pred = nose_model.predict(nose_input)[0][0]
            lips_pred = lips_model.predict(lips_input)[0][0]
            eyes_pred = (eyes_model.predict(left_eye_input)[0][0] + eyes_model.predict(right_eye_input)[0][
                0]) / 2  # Average for both eyes
            face_swap_pred = face_swap_model.predict(face_input)[0][0]
            
            # Determine labels and confidences
            results = [
                {"model": "Nose", "status": "Fake" if nose_pred > 0.5 else "Real",
                 "confidence": float(nose_pred if nose_pred > 0.5 else 1 - nose_pred)},
                {"model": "Lips", "status": "Fake" if lips_pred > 0.5 else "Real",
                 "confidence": float(lips_pred if lips_pred > 0.5 else 1 - lips_pred)},
                {"model": "Eyes", "status": "Fake" if eyes_pred > 0.5 else "Real",
                 "confidence": float(eyes_pred if eyes_pred > 0.5 else 1 - eyes_pred)},
                {"model": "Face Swap", "status": "Fake" if face_swap_pred > 0.5 else "Real",
                 "confidence": float(face_swap_pred if face_swap_pred > 0.5 else 1 - face_swap_pred)},
            ]
            
            # Calculate average confidence
            avg_confidence = np.mean([r["confidence"] for r in results]) * 100
            
            # Determine overall status
            fake_count = sum(1 for r in results if r["status"] == "Fake")
            overall_status = "Fake" if fake_count > 2 else "Real"
            
            # Visualize results
            face = faces[0]
            x, y, w, h = face['box']
            color = (0, 0, 255) if overall_status == "Fake" else (0, 255, 0)
            cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
            cv2.putText(img, f"Overall: {overall_status}", (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            
            # Save result image
            if not os.path.exists(RESULT_FOLDER):
                os.makedirs(RESULT_FOLDER)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            save_path = os.path.join(RESULT_FOLDER, f"result_{timestamp}.jpg")
            cv2.imwrite(save_path, img)
            
            # Save to database
            content = Content(UserID=user_id, Path=os.path.basename(image_path),
                              Type=content_type)  # Adjust UserID as needed
            db.session.add(content)
            db.session.commit()
            
            file_size_kb = os.path.getsize(image_path) / 1024
            new_image = Image(ContentID=content.ContentID, Size=file_size_kb)
            new_result = Result(ContentID=content.ContentID, Status=overall_status)
            db.session.add(new_image)
            db.session.add(new_result)
            db.session.commit()
            
            for result in results:
                new_detail = Detail(
                    ResultID=new_result.ResultID,
                    ConfidenceScore=result["confidence"],
                    Frame=save_path,
                    Status=result["status"]
                )
                db.session.add(new_detail)
            db.session.commit()
            
            return {
                "message": "Image processed successfully!",
                "details": {
                    "results": results,
                    "overall_status": overall_status,
                    "average_confidence": f"{avg_confidence:.2f}%",
                    "result_image": save_path
                }
            }, 200
        
        except Exception as e:
            db.session.rollback()
            return {"error": str(e)}, 500
    
    @staticmethod
    def save_and_detect(file, user_id, content_type):
        """API endpoint to handle file upload and process through all models."""
        try:
            if not os.path.exists(UPLOAD_FOLDER):
                os.makedirs(UPLOAD_FOLDER)
            
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            file_extension = os.path.splitext(file.filename)[1]
            file_name = f"{timestamp}{file_extension}"
            file_path = os.path.join(UPLOAD_FOLDER, file_name)
            file.save(file_path)
            
            return ContentController.detect_all_models(file_path, user_id, content_type)
        
        except Exception as e:
            db.session.rollback()
            return {"error": str(e)}, 500

