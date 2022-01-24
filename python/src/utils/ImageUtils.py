import base64
import os
import cv2
import numpy as np

dir_path = os.path.dirname(os.path.realpath(__file__))


def GetPathFromTmp(file):
    """
    renvoie le chemin vers un fichier dans le dossier tmp
    :param file:
    :return:
    """
    return os.path.join(dir_path, '..', '..', 'tmp', file)


def GetPathToData(coin_directory, file_name):
    """
    renvoie le chemin vers un ficheir dans le dossier du dataset
    :param coin_directory:
    :param file_name:
    :return:
    """
    return os.path.join(dir_path, '..', '..', 'models', coin_directory, file_name)


def ShowImage(image):
    """
    affiche une image (utile au debug)
    :param image:
    :return:
    """
    cv2.imshow('Showing image', image)
    cv2.waitKey(0)


def WriteTmpImage(img, name):
    """
    enregistre une image dans le dossier tmp
    :param img:
    :param name:
    :return:
    """
    cv2.imwrite(GetPathFromTmp(name + '.jpg'), img)


def WriteDataImage(blob, directory, name):
    """
    enregistre une image dans le dossier du dataset, selon pièce spécifiée
    :param blob:
    :param directory:
    :param name:
    :return:
    """
    with open(GetPathToData(directory, name + '.jpg'), 'wb') as image:
        image.write(base64.b64encode(blob))


def DeleteTmpImage(name):
    """
    supprime une image dans le dossier tmp
    :param name:
    :return:
    """
    os.remove(GetPathFromTmp(name + '.jpg'))


def LoadImage(path):
    """
    charge une image depuis le dossier tmp
    :param path:
    :return:
    """
    return cv2.imread(GetPathFromTmp(path))


def ConvertFlaskImageToOpenCV(img_stream):
    """
    converti une image flask en image opencv
    :param img_stream:
    :return:
    """
    img_stream.seek(0)
    img_array = np.asarray(bytearray(img_stream.read()), dtype=np.uint8)
    return cv2.imdecode(img_array, cv2.IMREAD_COLOR)


def ProcessImage(image):
    """
    effectue différents traitement à l'image pour faciliter la détection de pièces.
    :param image:
    :return:
    """

    # on la redimensionne pour la  cohérence des photos et réduire la qualité
    resized = Resize(image, width=512)

    kernel = np.ones((6, 6), np.uint8)

    blured = cv2.medianBlur(resized, 5)
    eroded = cv2.erode(blured, kernel, iterations=1)
    dilated = cv2.dilate(eroded, kernel, iterations=2)
    edges = cv2.Canny(dilated, 100, 200)

    return resized, blured, eroded, dilated, edges



def Resize(image, width=None, height=None, inter=cv2.INTER_AREA):
    """
    Prend une image et redimensionne en gardant les dimensions
    Il faut seulement préciser la width ou la height
    :param image:
    :param width:
    :param height:
    :param inter:
    :return:
    """
    (h, w) = image.shape[:2]

    if width is None and height is None:
        return image

    if width is None:
        r = height / float(h)
        dim = (int(w * r), height)

    else:
        r = width / float(w)
        dim = (width, int(h * r))

    resized = cv2.resize(image, dim, interpolation=inter)

    return resized
