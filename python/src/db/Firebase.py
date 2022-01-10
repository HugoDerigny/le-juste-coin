import os.path

from firebase_admin import credentials, initialize_app, storage

import src.utils.ImageUtils as ImageUtils

dir_path = os.path.dirname(os.path.realpath(__file__))
certificate_path = os.path.join(dir_path, '..', '..', 'le-juste-coin-107107e80b4f.json')

initialize_app(credentials.Certificate(certificate_path), {'storageBucket': 'le-juste-coin.appspot.com'})
bucket = storage.bucket()


def SaveImage(image, name):
    ImageUtils.WriteTmpImage(image, name)

    filename = name + '.jpg'

    blob = bucket.blob(filename)
    blob.upload_from_filename(ImageUtils.GetPathFromTmp(filename))

    ImageUtils.DeleteTmpImage(name)


def GetImage(image_name):
    blob = bucket.get_blob(image_name)

    return blob


def DownloadImage(image_name, path_to_save):
    blob = bucket.get_blob(image_name)
    blob.download_to_filename(filename=path_to_save)

    return True


def RemoveImage(image_name):
    bucket.delete_blob(image_name + '.jpg')

    return True
