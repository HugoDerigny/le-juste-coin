"""
[
    {
        "id": "#123546-1",
        "real_coin": 200,
        "side": "OBVERSE"
    },
    {
        "id": "#123456-2",
        "real_coin": 50,
        "side": "REVERSE"
    }
]
"""
from src.utils.ImageUtils import WriteDataImage, GetPathToData
import src.db.Firebase as Firebase
import json
import os

VALUES_TO_DATA_DIRECTORY_MAP = {
    "200": "01",
    "100": "02",
    "50": "03",
    "20": "04",
    "10": "05",
    "5": "06"
}

SIDES_MAP = {
    "OBVERSE": "F",
    "REVERSE": "P"
}


def SaveFeedbackForAnalyse(feedback):
    if not feedback:
        print('No feedback')
        return None

    for item in json.loads(feedback):
        firebase_file_id = item['id'] + '.jpg'
        save_directory = VALUES_TO_DATA_DIRECTORY_MAP[str(item['real_coin'])]
        coin_side = SIDES_MAP[item['side']]

        data_file_name = GetUniqueNameForNewFile(save_directory, coin_side)

        print(item, save_directory, data_file_name)

        file_path = GetPathToData(save_directory, data_file_name)
        Firebase.DownloadImage(firebase_file_id, file_path)

    return True


def GetUniqueNameForNewFile(save_directory, coin_side):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    data_directory_path = os.path.join(dir_path, '..', '..', 'models', save_directory)

    directory_files = os.listdir(data_directory_path)

    next_file_name = str(len([name for name in directory_files if name[0] == coin_side]) + 1)
    next_file_name = next_file_name.zfill(5)

    return coin_side + next_file_name + '.jpg'
