import datetime
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
    """
    Transforme les analyses sorties de la base de données en JSON pour l'API, et ajoute les champs de confiance moyenne
    et somme en centimes.
    :param analyzes_dto:  Analyse provenant de la BDD
    :return: Objet JSON de l'analyse
    """
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
    """
    Cette méthode est utilisée pour enregistrer des nouvelles images dans le dataset
    :param images:
    :param directory:
    :return:
    """
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
    """
    Prend l'image venant de la requête, détecte les cercles et utilise le modèle de machine learning pour trouver
    les pièces. Renvoie le JSON du résultat de l'analyse.
    :param image: Image Flask de la requête
    :param token: ID utilisateur
    :return: None | dict
    """

    # Conversion de l'image flask vers OpenCV, étape nécessaire pour les traitements
    image = ImageUtils.ConvertFlaskImageToOpenCV(image)

    # On effectue différents traitements sur l'image
    (resized_image, blured_image, eroded_image, dilated_image, edges_image) = ImageUtils.ProcessImage(image)

    # on génère un id unique sur 6 chiffres
    uuid = (str(uuid4())[0:6]).upper()

    # le machine learning analyse l'image et renvoie un résultat
    result = AI.AnalyzeImage(resized_image, edges_image, uuid, token)

    # s'il n'y en a pas c'est car aucun cercle n'a été trouvé
    if result is None:
        return

    # toutes les variations d'images sont enregistrées sur firebase pour que l'utilisateur y ait accès
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
    """
    récupère les analyses de l'utilisateur selon son ID et les renvoie
    :param token:
    :return:
    """
    user_analyses_dto = Database.GetAnalysesOfUser(token)

    return __parseanalyzes__(user_analyses_dto)


def DeleteUserAnalyze(user_id, analyze_id):
    """
    supprime l'analyse de la BDD locale ainsi que les images sur Firebase
    :param user_id:
    :param analyze_id:
    :return:
    """

    # on vérifie que l'ID de l'utilisateur correspond à celui enregistré pour l'analyse
    if not Database.UserOwnAnalyze(user_id, analyze_id):
        return 'Not enough permission', 403

    analyze_dto = Database.GetAnalyzeById(analyze_id)
    analyze = __parseanalyzes__(analyze_dto)[0]

    Firebase.RemoveImage(f'#{analyze_id}-original')
    Firebase.RemoveImage(f'#{analyze_id}-blur')
    Firebase.RemoveImage(f'#{analyze_id}-erode')
    Firebase.RemoveImage(f'#{analyze_id}-dilate')
    Firebase.RemoveImage(f'#{analyze_id}-canny')
    Firebase.RemoveImage(f'#{analyze_id}-circles')

    for item in analyze['items']:
        Firebase.RemoveImage(f'{item["id"]}')

    Database.RemoveUserAnalyse(analyze_id)
