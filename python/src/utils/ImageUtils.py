import os

import cv2
import numpy as np

import src.db.Firebase as Firebase


def GetPathFromTmp(file):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    return os.path.join(dir_path, '..', '..', 'tmp', file)


def ShowImage(image):
    cv2.imshow('Showing image', image)
    cv2.waitKey(0)


def WriteTmpImage(img, name):
    cv2.imwrite(GetPathFromTmp(name + '.jpg'), img)


def DeleteTmpImage(name):
    os.remove(GetPathFromTmp(name + '.jpg'))


def LoadImage(path):
    return cv2.imread(GetPathFromTmp(path))


def ConvertFlaskImageToOpenCV(img_stream):
    img_stream.seek(0)
    img_array = np.asarray(bytearray(img_stream.read()), dtype=np.uint8)
    return cv2.imdecode(img_array, cv2.IMREAD_COLOR)


def ProcessImage(image, uuid, debug=False):
    resized = Resize(image, width=512)

    kernel = np.ones((6, 6), np.uint8)

    blured = cv2.medianBlur(resized, 5)
    eroded = cv2.erode(blured, kernel, iterations=1)
    dilated = cv2.dilate(eroded, kernel, iterations=2)
    edges = cv2.Canny(dilated, 100, 200)

    WriteTmpImage(blured, f'#{uuid}-blur')
    WriteTmpImage(eroded, f'#{uuid}-erode')
    WriteTmpImage(dilated, f'#{uuid}-dilate')
    WriteTmpImage(edges, f'#{uuid}-canny')

    Firebase.UploadImage(f'#{uuid}-blur')
    Firebase.UploadImage(f'#{uuid}-erode')
    Firebase.UploadImage(f'#{uuid}-dilate')
    Firebase.UploadImage(f'#{uuid}-canny')

    if not debug:
        DeleteTmpImage(f'#{uuid}-blur')
        DeleteTmpImage(f'#{uuid}-erode')
        DeleteTmpImage(f'#{uuid}-dilate')
        DeleteTmpImage(f'#{uuid}-canny')

    return resized, edges


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