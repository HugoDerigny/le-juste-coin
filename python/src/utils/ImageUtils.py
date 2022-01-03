import os

import cv2
import numpy as np

import src.db.Firebase as Firebase

dir_path = os.path.dirname(os.path.realpath(__file__))


def GetPathFromTmp(file):
    return os.path.join(dir_path, '..', '..', 'tmp', file)


def GetPathToData(coin_directory, file_name):
    return os.path.join(dir_path, '..', '..', 'models', coin_directory, file_name)


def ShowImage(image):
    cv2.imshow('Showing image', image)
    cv2.waitKey(0)


def WriteTmpImage(img, name):
    cv2.imwrite(GetPathFromTmp(name + '.jpg'), img)


def WriteDataImage(image, directory, name):
    cv2.imwrite(GetPathToData(directory, name + '.jpg'), image)


def DeleteTmpImage(name):
    os.remove(GetPathFromTmp(name + '.jpg'))


def LoadImage(path):
    return cv2.imread(GetPathFromTmp(path))


def ConvertFlaskImageToOpenCV(img_stream):
    img_stream.seek(0)
    img_array = np.asarray(bytearray(img_stream.read()), dtype=np.uint8)
    return cv2.imdecode(img_array, cv2.IMREAD_COLOR)


def ProcessImage(image):
    resized = Resize(image, width=512)

    kernel = np.ones((6, 6), np.uint8)

    blured = cv2.medianBlur(resized, 5)
    eroded = cv2.erode(blured, kernel, iterations=1)
    dilated = cv2.dilate(eroded, kernel, iterations=2)
    edges = cv2.Canny(dilated, 100, 200)

    return resized, blured, eroded, dilated, edges


# Prend une image et redimensionne en gardant les dimensions
# Il faut seulement préciser la width ou la height
def Resize(image, width=None, height=None, inter=cv2.INTER_AREA):
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
