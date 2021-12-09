import src.utils.ImageUtils as ImageUtils
from src.utils.CNN import classify
from keras.models import load_model
import numpy as np
import pickle
import cv2

model = load_model('dataset.h5')
lb = pickle.loads(open("lab.pickle", "rb").read())


def ClassifyImage(image):
    image, name, score = classify(image, model, lb)

    print(name)

    return image


def AnalyzeImage(original_image, processed_image):
    circles = DetectCircles(processed_image)

    ImageUtils.WriteTmpImage(DrawCircles(original_image, circles), 'circles')

    cropped_images = GetCroppedImages(original_image, circles)

    i = 0
    for cropped_image in cropped_images:
        i += 1
        ImageUtils.WriteTmpImage(ClassifyImage(cropped_image), f'classified_{str(i)}')

    return cropped_images


def DetectCircles(img):
    circles = cv2.HoughCircles(img, cv2.HOUGH_GRADIENT, 2, 30, param1=30, param2=75)

    if circles is None:
        print('warn - No circles detected')
        exit(1)

    circles = np.uint16(np.around(circles))

    return circles


def DrawCircles(image, circles):
    j = 0

    imageToDraw = image.copy()
    # imageToDraw = cv2.cvtColor(imageToDraw, cv2.COLOR_GRAY2BGR)

    for i in circles[0, :]:
        j += 1
        (centerX, centerY, radius) = i
        # dessiner le cercle decouvert
        cv2.circle(imageToDraw, (centerX, centerY), radius, (0, 255, 0), 4)
        # numéroter les pièces
        cv2.putText(imageToDraw, str(j), color=(0, 0, 255), org=(centerX, centerY), fontScale=3,
                    fontFace=cv2.FONT_HERSHEY_SIMPLEX, thickness=3)
        # cv2.circle(cimg, (centerX, centerY), 2, (0, 0, 255), 20)

    return imageToDraw


def GetCroppedImages(image, circles):
    cropped = []

    for i in circles[0, :]:
        (centerX, centerY, radius) = i

        cropped.append(image[centerY - radius:centerY + radius, centerX - radius:centerX + radius])

    return cropped


