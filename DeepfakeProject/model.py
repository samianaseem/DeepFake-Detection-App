
import os
import cv2
import numpy as np
import tensorflow as tf
from mtcnn import MTCNN
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras import layers, models
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.utils import to_categorical

# MTCNN face detector
detector = MTCNN()

# Path to dataset
dataset_path = '/Users/apple/Desktop/Dataset'

# Helper function to load and preprocess images
def preprocess_image(image_path, target_size=(224, 224)):
    img = cv2.imread(image_path)
    if img is None:
        return None

    # Detect faces
    faces = detector.detect_faces(img)
    if len(faces) == 0:
        return None  # Skip images without faces

    # Crop the first detected face
    x, y, w, h = faces[0]['box']
    face = img[y:y + h, x:x + w]

    # Resize and normalize
    face = cv2.resize(face, target_size)
    face = face.astype('float32') / 255.0

    return face

# Function to load dataset from folders
def load_dataset(folder_path):
    data, labels = [], []

    for label in ['real', 'fake']:
        label_dir = os.path.join(folder_path, label)
        if not os.path.exists(label_dir):
            continue  # Skip if the folder doesn't exist

        for img_name in os.listdir(label_dir):
            img_path = os.path.join(label_dir, img_name)
            face = preprocess_image(img_path)

            if face is not None:
                data.append(face)
                labels.append(0 if label == 'real' else 1)  # Real = 0, Fake = 1

    return np.array(data), np.array(labels)

# Load train, validation, and test sets
X_train, y_train = load_dataset(os.path.join(dataset_path, 'Train'))
X_val, y_val = load_dataset(os.path.join(dataset_path, 'Validation'))
X_test, y_test = load_dataset(os.path.join(dataset_path, 'Test'))

# Load EfficientNetB0
base_model = EfficientNetB0(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
base_model.trainable = False  # Freeze layers

# Build model
model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(1, activation='sigmoid')  # Binary classification
])

# Compile model
model.compile(optimizer=Adam(), loss='binary_crossentropy', metrics=['accuracy'])

# Data augmentation
datagen = ImageDataGenerator(
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest'
)

# Train model
model.fit(datagen.flow(X_train, y_train, batch_size=32),
          validation_data=(X_val, y_val),
          epochs=10)

# Evaluate on test data
test_loss, test_acc = model.evaluate(X_test, y_test)
print(f'Test Accuracy: {test_acc:.4f}')

# Save the trained model
model.save('deepfake_detection_new_1_model.h5')





# ------------------------------------------tensorflow -------------------------------------------------










# import os
# import cv2
# import numpy as np
# import tensorflow as tf
# from mtcnn import MTCNN
# from sklearn.model_selection import train_test_split
# from tensorflow.keras.preprocessing.image import ImageDataGenerator
# from tensorflow.keras.applications import EfficientNetB0
# from tensorflow.keras import layers, models
# from tensorflow.keras.optimizers import Adam
#
# # MTCNN face detector
# detector = MTCNN()
#
# # Path to dataset
# dataset_path = '/Users/apple/Desktop/Data_set'
#
# # Helper function to load and preprocess images
# def preprocess_image(image_path, target_size=(224, 224)):
#     # Load image
#     img = cv2.imread(image_path)
#
#     if img is None:  # Check if the image is successfully loaded
#         return None
#
#     # Detect faces
#     faces = detector.detect_faces(img)
#     if len(faces) == 0:
#         return None  # No face detected
#
#     # Assuming the first detected face is the correct one
#     x, y, w, h = faces[0]['box']
#     face = img[y:y + h, x:x + w]
#
#     # Resize and normalize the image
#     face = cv2.resize(face, target_size)
#     face = face.astype('float32') / 255.0  # Normalize to [0, 1]
#
#     return face
#
# # Prepare dataset
# def prepare_dataset(dataset_path):
#     data = []
#     labels = []
#
#     # Iterate over `real` and `fake` folders
#     for label in ['real', 'fake']:
#         label_dir = os.path.join(dataset_path, label)
#         for img_name in os.listdir(label_dir):
#             img_path = os.path.join(label_dir, img_name)
#             face = preprocess_image(img_path)
#
#             if face is not None:
#                 data.append(face)
#                 labels.append(0 if label == 'real' else 1)  # Real = 0, Fake = 1
#
#     # Convert lists to numpy arrays
#     data = np.array(data)
#     labels = np.array(labels)
#
#     return data, labels
#
# # Load dataset
# data, labels = prepare_dataset(dataset_path)
#
# # Split dataset into train and validation
# X_train, X_val, y_train, y_val = train_test_split(data, labels, test_size=0.2, random_state=42)
#
# # Load EfficientNetB0 model pre-trained on ImageNet
# base_model = EfficientNetB0(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
#
# # Freeze the base model layers
# base_model.trainable = False
#
# # Build the final model
# model = models.Sequential([
#     base_model,
#     layers.GlobalAveragePooling2D(),
#     layers.Dense(1, activation='sigmoid')  # Binary classification: Real vs Fake
# ])
#
# # Compile the model
# model.compile(optimizer=Adam(), loss='binary_crossentropy', metrics=['accuracy'])
#
# # Summary of the model
# model.summary()
#
# # Data Augmentation
# datagen = ImageDataGenerator(
#     rotation_range=20,
#     width_shift_range=0.2,
#     height_shift_range=0.2,
#     shear_range=0.2,
#     zoom_range=0.2,
#     horizontal_flip=True,
#     fill_mode='nearest'
# )
#
# # Fit model on augmented data
# model.fit(datagen.flow(X_train, y_train, batch_size=32),
#           validation_data=(X_val, y_val),
#           epochs=10)
#
# # Save the model
# model.save('deepfake_detection_model.h5')








# ------------------------------------------Using Torch -------------------------------------------------






#
# import os
# import cv2
# import numpy as np
# import torch
# import torch.nn as nn
# import torch.optim as optim
# from torch.utils.data import DataLoader, Dataset, random_split
# from torchvision import models, transforms
# from mtcnn import MTCNN
#
# # MTCNN face detector
# detector = MTCNN()
#
# # Path to dataset
# dataset_path = '/Users/apple/Desktop/Data_set'
#
# # Transformations for preprocessing
# transform = transforms.Compose([
#     transforms.ToPILImage(),
#     transforms.Resize((224, 224)),
#     transforms.ToTensor(),
#     transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])  # Standard normalization for ImageNet
# ])
#
# # Custom Dataset Class
# class FaceDataset(Dataset):
#     def __init__(self, dataset_path, transform=None):
#         self.data = []
#         self.labels = []
#         self.transform = transform
#
#         # Iterate over `real` and `fake` folders
#         for label, folder in enumerate(['real', 'fake']):
#             label_dir = os.path.join(dataset_path, folder)
#             for img_name in os.listdir(label_dir):
#                 img_path = os.path.join(label_dir, img_name)
#                 face = self.preprocess_image(img_path)
#                 if face is not None:
#                     self.data.append(face)
#                     self.labels.append(label)
#
#     def preprocess_image(self, image_path):
#         # Load image
#         img = cv2.imread(image_path)
#
#         if img is None:  # Check if the image is successfully loaded
#             return None
#
#         # Detect faces
#         faces = detector.detect_faces(img)
#         if len(faces) == 0:
#             return None  # No face detected
#
#         # Assuming the first detected face is the correct one
#         x, y, w, h = faces[0]['box']
#         face = img[y:y + h, x:x + w]
#
#         return face
#
#     def __len__(self):
#         return len(self.data)
#
#     def __getitem__(self, idx):
#         img = self.data[idx]
#         label = self.labels[idx]
#
#         if self.transform:
#             img = self.transform(img)
#
#         return img, label
#
# # Load dataset
# dataset = FaceDataset(dataset_path, transform=transform)
#
# # Split dataset into train and validation
# train_size = int(0.8 * len(dataset))
# val_size = len(dataset) - train_size
# train_dataset, val_dataset = random_split(dataset, [train_size, val_size])
#
# # Data loaders
# batch_size = 32
# train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
# val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
#
# # Load EfficientNetB0 model pre-trained on ImageNet
# model = models.efficientnet_b0(pretrained=True)
#
# # Modify the classifier for binary classification
# model.classifier[1] = nn.Linear(model.classifier[1].in_features, 1)
#
# # Move model to GPU if available
# device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# model = model.to(device)
#
# # Define loss function and optimizer
# criterion = nn.BCEWithLogitsLoss()  # Binary Cross-Entropy Loss with logits
# optimizer = optim.Adam(model.parameters(), lr=0.001)
#
# # Training loop
# epochs = 10
# for epoch in range(epochs):
#     model.train()
#     running_loss = 0.0
#     for images, labels in train_loader:
#         images, labels = images.to(device), labels.to(device, dtype=torch.float32)
#
#         # Zero the parameter gradients
#         optimizer.zero_grad()
#
#         # Forward pass
#         outputs = model(images).squeeze()
#         loss = criterion(outputs, labels)
#
#         # Backward pass and optimize
#         loss.backward()
#         optimizer.step()
#
#         running_loss += loss.item()
#
#     # Validation loop
#     model.eval()
#     val_loss = 0.0
#     correct = 0
#     total = 0
#     with torch.no_grad():
#         for images, labels in val_loader:
#             images, labels = images.to(device), labels.to(device, dtype=torch.float32)
#             outputs = model(images).squeeze()
#             loss = criterion(outputs, labels)
#             val_loss += loss.item()
#
#             # Accuracy calculation
#             preds = torch.round(torch.sigmoid(outputs))
#             correct += (preds == labels).sum().item()
#             total += labels.size(0)
#
#     print(f"Epoch {epoch+1}/{epochs}, "
#           f"Train Loss: {running_loss/len(train_loader):.4f}, "
#           f"Val Loss: {val_loss/len(val_loader):.4f}, "
#           f"Val Accuracy: {correct/total:.4f}")
#
# # Save the model
# torch.save(model.state_dict(), 'deepfake_detection_model.pth')
