import os.path

from firebase_admin import credentials, initialize_app, storage

import src.utils.ImageUtils as ImageUtils

dir_path = os.path.dirname(os.path.realpath(__file__))
certificate_path = os.path.join(dir_path, '..', '..', 'le-juste-coin-107107e80b4f.json')

initialize_app(credentials.Certificate(certificate_path), {'storageBucket': 'le-juste-coin.appspot.com'})
bucket = storage.bucket()

def UploadImage(name):
    filename = name + '.jpg'

    blob = bucket.blob(filename)
    blob.upload_from_filename(ImageUtils.GetPathFromTmp(filename))
