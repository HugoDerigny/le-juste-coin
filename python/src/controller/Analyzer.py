import datetime
import json
import locale
import os
from collections import defaultdict
from uuid import uuid4
import cv2
import src.db.Database as Database
import src.db.Firebase as Firebase
import src.utils.AI as AI
import src.utils.ImageUtils as ImageUtils

locale.setlocale(locale.LC_ALL, '')

dir_path = os.path.dirname(os.path.realpath(__file__))
models_dir_path = os.path.join(dir_path, '../..', 'models')
data_dir_path = os.path.join(dir_path, '../..', 'data')


def __parseanalyzes__(analyzes_dto):
    user_analyses = []

    d = defaultdict(list)

    # Group analyses by UID
    for (uid, *analyse_items) in analyzes_dto:
        d.setdefault(uid, []).append(analyse_items)

    for (uid, analyse_items) in list(d.items()):
        row = {}

        confidences = []
        sum_of_coins = 0

        row = {
            'id': f'#{uid}',
            'items': [],
            'average_confidence': 0,
            'sum_of_coins': 0,
            'created_at': 0
        }

        for (created_at, index, coin, confidence) in analyse_items:
            confidences.append(confidence)
            sum_of_coins += coin

            row['created_at'] = created_at
            row['items'].append({
                'id': f'#{uid}-{index}',
                'coin': coin,
                'confidence': round(confidence)
            })

        average_confidence = round(sum(confidences) / len(confidences))

        row['average_confidence'] = average_confidence
        row['sum_of_coins'] = sum_of_coins

        user_analyses.append(row)

    return user_analyses

def DefineImages(images, directory):
    for image_name in images:
        crop_img = cv2.imread(os.path.join(data_dir_path, directory, image_name))
        cv2.imshow('Define', crop_img)
        cv2.waitKey(0)

        while True:
            side = input('P / F').upper()

            if ['P', 'F'].__contains__(side):
                break

        id = str(len([name for name in os.listdir(os.path.join(models_dir_path, directory)) if
                      name[0] == side]) + 1)
        id = id.zfill(5)
        cv2.imwrite(os.path.join(models_dir_path, directory) + '/' + side + id + '.jpg', crop_img)
        cv2.destroyAllWindows()

        os.remove(os.path.join(data_dir_path, directory, image_name))


def ProceedToAnalyse(image, token=''):
    image = ImageUtils.ConvertFlaskImageToOpenCV(image)

    (resized_image, blured_image, eroded_image, dilated_image, edges_image) = ImageUtils.ProcessImage(image)

    uuid = (str(uuid4())[0:6]).upper()

    result = AI.AnalyzeImage(resized_image, edges_image, uuid, token)

    if result is None:
        return

    Firebase.SaveImage(resized_image, f'#{uuid}-original')
    Firebase.SaveImage(blured_image, f'#{uuid}-blur')
    Firebase.SaveImage(eroded_image, f'#{uuid}-erode')
    Firebase.SaveImage(dilated_image, f'#{uuid}-dilate')
    Firebase.SaveImage(edges_image, f'#{uuid}-canny')

    items, sum_of_coins, average_confidence = result

    json_data = {
        'id': f'#{uuid}',
        'items': items,
        'sum_of_coins': sum_of_coins,
        'average_confidence': average_confidence,
        'created_at': str(datetime.datetime.now())
    }

    return json_data


def FetchUserAnalyses(token):
    user_analyses_dto = Database.GetAnalysesOfUser(token)

    return __parseanalyzes__(user_analyses_dto)


def DeleteUserAnalyze(user_id, analyze_id):
    if not Database.UserOwnAnalyze(user_id, analyze_id):
        return 'Not enough permission', 403

    analyze_dto = Database.GetAnalyzeById(analyze_id)
    analyze = (__parseanalyzes__([analyze_dto]))[0]

    Firebase.RemoveImage(f'#{analyze_id}-original')
    Firebase.RemoveImage(f'#{analyze_id}-blur')
    Firebase.RemoveImage(f'#{analyze_id}-erode')
    Firebase.RemoveImage(f'#{analyze_id}-dilate')
    Firebase.RemoveImage(f'#{analyze_id}-canny')

    for item in analyze['items']:
        Firebase.RemoveImage(f'#{item["id"]}')

    Database.RemoveUserAnalyse(analyze_id)
