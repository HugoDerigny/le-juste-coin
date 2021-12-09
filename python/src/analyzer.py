import cv2
import os
import src.utils.ImageUtils as ImageUtils
import src.utils.AI as AI

TMP_PATH = os.path.join(os.getcwd(), 'tmp')

values = {
    "1": 200,
    "2": 100,
    "3": 50,
    "4": 20,
    "5": 10,
    "6": 5
}


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
        id = str(len([name for name in os.listdir(os.path.join(os.path.join(TMP_PATH, '..', 'models', model))) if
                      name[0] == side]) + 1)
        id = id.zfill(6 - len(id))
        cv2.imwrite(os.path.join(TMP_PATH, '..', 'models', model) + '/' + side + id + '.jpg', crop_img)
        cv2.destroyAllWindows()


def test():
    img = cv2.imread(TMP_PATH + '/base.jpg')
    resized_image = ImageUtils.Resize(img, width=512)
    blurred_image = ImageUtils.ProcessImage(resized_image)

    AI.AnalyzeImage(resized_image, blurred_image)
    # define_images(AI.AnalyzeImage(resized_image, blurred_image))

    return 0
