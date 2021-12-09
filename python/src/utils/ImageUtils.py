import os
import cv2
import numpy as np

tmp_path = os.path.join(os.getcwd(), 'tmp')


def WriteTmpImage(img, name):
    cv2.imwrite(tmp_path + '/' + name + '.jpg', img)


def ProcessImage(image):
    kernel = np.ones((6, 6), np.uint8)

    processed = cv2.medianBlur(image, 5)
    WriteTmpImage(processed, 'processed_blur')
    processed = cv2.erode(processed, kernel, iterations=1)
    WriteTmpImage(processed, 'processed_erode')
    processed = cv2.dilate(processed, kernel, iterations=2)
    WriteTmpImage(processed, 'processed_dilate')

    processed = cv2.Canny(processed, 100, 200)
    WriteTmpImage(processed, 'processed_canny')

    return processed


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
