import json
import locale
import os
from uuid import uuid4

import cv2

import src.utils.AI as AI
import src.utils.ImageUtils as ImageUtils

locale.setlocale(locale.LC_ALL, 'fr-FR')

dir_path = os.path.dirname(os.path.realpath(__file__))
models_dir_path = os.path.join(dir_path, '../..', 'models')


def define_images(images):
    for crop_img in images:
        cv2.imshow('Define', crop_img)
        cv2.waitKey(0)
        model = input('Enter corresponding value (01: 2€, 02: 1€, 03: 50cts, 04: 20cts, 05: 10cts, 06: 5cts, S: skip)')

        if model.upper() == 'STOP':
            cv2.destroyAllWindows()
            break

        if model.upper() == 'S':
            cv2.destroyAllWindows()
            continue

        side = input('Pile (P) ou Face (F) ?')
        id = str(len([name for name in os.listdir(os.path.join(models_dir_path, model)) if
                      name[0] == side]) + 1)
        id = id.zfill(6 - len(id))
        cv2.imwrite(os.path.join(models_dir_path, model) + '/' + side + id + '.jpg', crop_img)
        cv2.destroyAllWindows()


def ProceedToAnalyse(image, token='', debug=False):
    image = ImageUtils.ConvertFlaskImageToOpenCV(image)

    uuid = (str(uuid4())[0:6]).upper()

    (resized_image, blurred_image) = ImageUtils.ProcessImage(image, uuid, debug)

    result = AI.AnalyzeImage(resized_image, blurred_image, uuid, token, debug)

    if result is None:
        return

    items, sum_of_coins, average_confidence = result

    json_data = {
        'items': items,
        'sum_of_cents': sum_of_coins,
        'average_confidence': average_confidence
    }

    print(
        json.dumps(json_data, sort_keys=True, indent=4),
    )

    return json_data

def FetchUserAnalyses(token):
    return []