import cv2
import dlib
import numpy as np

# Initialize dlib's face detector and facial landmarks predictor
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("/Users/apple/DeepfakeProject/Controller/shape_predictor_68_face_landmarks.dat")

# Load input images
image1 = cv2.imread("/Users/apple/DeepfakeProject/add_face/input/image1.jpg")
image2 = cv2.imread("/Users/apple/DeepfakeProject/add_face/input/image2.jpg")

# Resize images to a standard size (optional)
image1 = cv2.resize(image1, (512, 512))
image2 = cv2.resize(image2, (512, 512))

# Convert to grayscale
gray1 = cv2.cvtColor(image1, cv2.COLOR_BGR2GRAY)
gray2 = cv2.cvtColor(image2, cv2.COLOR_BGR2GRAY)

# Detect faces
faces1 = detector(gray1)
faces2 = detector(gray2)

if len(faces1) == 0 or len(faces2) == 0:
    print("No faces detected in one or both images.")
    exit()

# Function to extract facial landmarks
def get_landmarks(image, face):
    landmarks = predictor(image, face)
    return np.array([(p.x, p.y) for p in landmarks.parts()], dtype=np.int32)

landmarks1 = get_landmarks(gray1, faces1[0])
landmarks2 = get_landmarks(gray2, faces2[0])

# Create convex hulls for the full face
hull_index = cv2.convexHull(landmarks2, returnPoints=False)
landmarks1_hull = np.array([landmarks1[idx[0]] for idx in hull_index])
landmarks2_hull = np.array([landmarks2[idx[0]] for idx in hull_index])

# Compute the transformation matrix for full-face warping
h_matrix, _ = cv2.findHomography(landmarks1_hull, landmarks2_hull, cv2.RANSAC)

# Warp the entire face region from image1 to align with image2
warped_image = cv2.warpPerspective(image1, h_matrix, (image2.shape[1], image2.shape[0]))

# Create a full mask for the warped face
mask = np.zeros_like(gray2)
cv2.fillConvexPoly(mask, landmarks2_hull, 255)

# Refine mask edges with Gaussian blur
mask = cv2.GaussianBlur(mask, (15, 15), 10)

# Use seamlessClone for natural blending
center = (faces2[0].center().x, faces2[0].center().y)
output = cv2.seamlessClone(warped_image, image2, mask, center, cv2.NORMAL_CLONE)

# Display and save the final result
cv2.imshow("orignal image",image1)
cv2.imshow("orignal image2",image2)
cv2.imshow("Full Face Swap", output)
cv2.imwrite("full_face_swap_result.jpg", output)
cv2.waitKey(0)
cv2.destroyAllWindows()