import os
import pickle
import cv2
import numpy as np
from keras.models import load_model
import src.db.Database as Database
import src.db.Firebase as Firebase
from src.utils.CNN import classify

dir_path = os.path.dirname(os.path.realpath(__file__))
ROOT_PATH = os.path.join(dir_path, '..', '..')

model = load_model(os.path.join(ROOT_PATH, 'dataset.h5'))
lb = pickle.loads(open(os.path.join(ROOT_PATH, "lab.pickle"), "rb").read())


def ClassifyImages(images, uuid='', token=''):
    """
    effectue l'analyse d'une image, la créé en base et enregistre les images sur firebase
    :param images: les images des pièces cropés
    :param uuid: l'id de l'analyse
    :param token: l'id de l'utilisateur
    :return:
    """

    sum_of_coins = 0
    confidences = []
    results = []

    # on créé l'analyse en base
    Database.CreateAnalyse(uuid, token)

    for index, image in enumerate(images):
        # notre modèle match l'image avec ses connaissances
        data = classify(image, model, lb)
        image_uuid = f'#{uuid}-{index + 1}'

        if not data:
            continue

        coin, score, image = data

        # on sauvegarde l'analyse en base et sur firebase
        Database.AddItemsToAnalyse(uuid, index + 1, coin, score)
        Firebase.SaveImage(image, image_uuid)

        # on ajoute le résultat au reste
        results.append({
            'id': image_uuid,
            'coin': coin,
            'confidence': round(score)
        })

        sum_of_coins += coin
        confidences.append(score)

    average_confidence = round(sum(confidences) / len(confidences))

    return results, sum_of_coins, average_confidence


def AnalyzeImage(original_image, processed_image, uuid='', token=''):
    """
    détecte les cercles d'une image, enregistre sur firebase s'il y en a et classifie les différentes pièces trouvées
    :param original_image:
    :param processed_image:
    :param uuid:
    :param token:
    :return:
    """

    circles = DetectCircles(processed_image)

    if len(circles) == 0:
        return None

    # s'il y a des cercles, on les dessine et on enregistre l'image sur firebase
    Firebase.SaveImage(DrawCircles(original_image, circles), f'#{uuid}-circles')

    cropped_images = GetCroppedImages(original_image, circles)

    return ClassifyImages(cropped_images, uuid, token)


def DetectCircles(img):
    """
    on utilise une méthode d'open cv pour détecter les cercles sur notre image
    :param img:
    :return:
    """
    circles = cv2.HoughCircles(img, cv2.HOUGH_GRADIENT, 2, 30, param1=30, param2=60, minRadius=30, maxRadius=100)

    if circles is None:
        return []

    circles = np.uint16(np.around(circles))

    return circles


def DrawCircles(image, circles):
    """
    dessine les cercles sur l'image avec le numéro d'index
    :param image:
    :param circles:
    :return:
    """
    j = 0

    imagesWithCircles = image.copy()

    for i in circles[0, :]:
        j += 1
        (centerX, centerY, radius) = i

        cv2.circle(imagesWithCircles, (centerX, centerY), radius, (0, 255, 0), 4)

        cv2.putText(imagesWithCircles, str(j), color=(0, 0, 255), org=(centerX, centerY), fontScale=3,
                    fontFace=cv2.FONT_HERSHEY_SIMPLEX, thickness=3)

    return imagesWithCircles


def GetCroppedImages(image, circles):
    """
    crop l'image pour toutes les pièces trouvées
    :param image:
    :param circles:
    :return:
    """
    cropped = []

    for circle in circles[0, :]:
        (centerX, centerY, radius) = circle

        cropped.append(image[centerY - radius:centerY + radius, centerX - radius:centerX + radius])

    return cropped
