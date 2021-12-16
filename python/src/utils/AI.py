import os
import pickle

import cv2
import numpy as np
from keras.models import load_model

import src.db.Database as Database
import src.db.Firebase as Firebase
import src.utils.ImageUtils as ImageUtils
from src.utils.CNN import classify

dir_path = os.path.dirname(os.path.realpath(__file__))
ROOT_PATH = os.path.join(dir_path, '..', '..')

model = load_model(os.path.join(ROOT_PATH, 'dataset.h5'))
lb = pickle.loads(open(os.path.join(ROOT_PATH, "lab.pickle"), "rb").read())


def ClassifyImages(images, uuid='', token='', debug=False):
    sum_of_coins = 0
    confidences = []
    results = {}

    if not debug:
        Database.CreateAnalyse(uuid, token)

    for index, image in enumerate(images):
        data = classify(image, model, lb)
        image_uuid = f'#{uuid}-{index + 1}'

        if not data:
            continue

        coin, score, image = data

        ImageUtils.WriteTmpImage(image, image_uuid)

        if not debug:
            Database.AddItemsToAnalyse(uuid, index + 1, coin, score)
            Firebase.UploadImage(image_uuid)
            ImageUtils.DeleteTmpImage(image_uuid)

        results[image_uuid] = {
            'cents': coin,
            'confidence': round(score)
        }

        sum_of_coins += coin
        confidences.append(score)

    average_confidence = round(sum(confidences) / len(confidences))

    return results, sum_of_coins, average_confidence


def AnalyzeImage(original_image, processed_image, uuid='', token='', debug=False):
    circles = DetectCircles(processed_image)

    if len(circles) == 0:
        return None

    if debug:
        ImageUtils.WriteTmpImage(DrawCircles(original_image, circles), 'circles')

    cropped_images = GetCroppedImages(original_image, circles)

    return ClassifyImages(cropped_images, uuid, token, debug)


def DetectCircles(img):
    circles = cv2.HoughCircles(img, cv2.HOUGH_GRADIENT, 2, 30, param1=30, param2=60, minRadius=30, maxRadius=100)

    if circles is None:
        print('warn - No circles detected')
        return []

    circles = np.uint16(np.around(circles))

    return circles


def DrawCircles(image, circles):
    j = 0

    imageToDraw = image.copy()

    for i in circles[0, :]:
        j += 1
        (centerX, centerY, radius) = i

        cv2.circle(imageToDraw, (centerX, centerY), radius, (0, 255, 0), 4)

        cv2.putText(imageToDraw, str(j), color=(0, 0, 255), org=(centerX, centerY), fontScale=3,
                    fontFace=cv2.FONT_HERSHEY_SIMPLEX, thickness=3)

    return imageToDraw


def GetCroppedImages(image, circles):
    cropped = []

    for circle in circles[0, :]:
        (centerX, centerY, radius) = circle

        cropped.append(image[centerY - radius:centerY + radius, centerX - radius:centerX + radius])

    return cropped
