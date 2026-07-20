#
# import os
# import cv2
# import numpy as np
# import tensorflow as tf
# from mtcnn import MTCNN
#
# # Load the trained model
# model = tf.keras.models.load_model('deepfake_detection_model.h5')
#
# # MTCNN face detector
# detector = MTCNN()
#
# # Helper function to preprocess faces
# def preprocess_face(face, target_size=(224, 224)):
#     # Resize and normalize the face
#     face = cv2.resize(face, target_size)
#     face = face.astype('float32') / 255.0  # Normalize to [0, 1]
#     face = np.expand_dims(face, axis=0)  # Add batch dimension
#     return face
#
# # Function to classify and visualize results
# def test_and_visualize(image_path):
#     # Read the image
#     img = cv2.imread(image_path)
#
#     if img is None:
#         print(f"Error: Could not load image at {image_path}")
#         return
#
#     # Detect faces in the image
#     faces = detector.detect_faces(img)
#
#     if len(faces) == 0:
#         print("No faces detected in the image.")
#         return
#
#     for face in faces:
#         # Extract bounding box coordinates
#         x, y, w, h = face['box']
#         x, y = max(0, x), max(0, y)  # Ensure coordinates are within bounds
#         face_crop = img[y:y + h, x:x + w]
#
#         # Preprocess the face
#         processed_face = preprocess_face(face_crop)
#
#         # Predict using the trained model
#         prediction = model.predict(processed_face)[0][0]
#
#         # Determine label and color
#         label = "Fake" if prediction > 0.5 else "Real"
#         color = (0, 0, 255) if label == "Fake" else (0, 255, 0)  # Red for fake, Green for real
#
#         # Draw the bounding box and label
#         cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
#         cv2.putText(img, f"{label} (Face Swap)", (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
#
#     # Display the image
#     cv2.imshow("Deepfake Detection", img)
#     cv2.waitKey(0)
#     cv2.destroyAllWindows()
#
# # Test the function with an example image
# test_image_path = '/Users/apple/Desktop/Data_set/real/1.jpg'  # Replace with the path to your test image
# test_and_visualize(test_image_path)


import os
import cv2
import numpy as np
import tensorflow as tf
from mtcnn import MTCNN

# Load the trained model
model = tf.keras.models.load_model('deepfake_detection_model.h5')

# MTCNN face detector
detector = MTCNN()

# Helper function to preprocess faces
def preprocess_face(face, target_size=(224, 224)):
    # Resize and normalize the face
    face = cv2.resize(face, target_size)
    face = face.astype('float32') / 255.0  # Normalize to [0, 1]
    face = np.expand_dims(face, axis=0)  # Add batch dimension
    return face

# Function to classify and visualize results
def test_and_visualize(image_path):
    # Read the image
    img = cv2.imread(image_path)

    if img is None:
        print(f"Error: Could not load image at {image_path}")
        return

    # Detect faces in the image
    faces = detector.detect_faces(img)

    if len(faces) == 0:
        print("No faces detected in the image.")
        return

    for face in faces:
        # Extract bounding box coordinates
        x, y, w, h = face['box']
        x, y = max(0, x), max(0, y)  # Ensure coordinates are within bounds
        face_crop = img[y:y + h, x:x + w]

        # Preprocess the face
        processed_face = preprocess_face(face_crop)

        # Predict using the trained model
        prediction = model.predict(processed_face)[0][0]

        # Determine label and color
        if prediction > 0.5:  # Fake
            label = "Fake (Face Swap)"  # Or "Fake (Copy-Move Forgery)" based on technique detection logic
            color = (0, 0, 255)  # Red for fake
        else:  # Real
            label = "Real"
            color = (0, 255, 0)  # Green for real

        # Draw the bounding box and label
        cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
        cv2.putText(img, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    # Display the image
    cv2.imshow("Deepfake Detection", img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# Test the function with an example image
# test_image_path = '/Users/apple/Desktop/Data_set/fake/109.jpg'
test_image_path = '/Users/apple/Desktop/Data_set/real/22.jpeg'
test_and_visualize(test_image_path)
