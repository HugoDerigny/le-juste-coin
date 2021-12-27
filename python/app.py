import os

from flask import Flask, request, jsonify

from src.controller.Analyzer import ProceedToAnalyse, FetchUserAnalyses, DefineImages
from src.controller.Feedback import SaveFeedbackForAnalyse
import src.utils.CNN as CNN

app = Flask(__name__)

# def update_data():
#     dir_path = os.path.dirname(os.path.realpath(__file__))
#
#     for directory in os.listdir(os.path.join(dir_path, 'data')):
#         DefineImages(os.listdir(os.path.join(dir_path, 'data', directory)), directory)
#
#
# update_data()


# CNN.create_dataset()

def VerifyAuthToken():
    authorization = request.headers.get('Authorization')

    if not authorization or authorization == '':
        return 'Authorization token not provided', 401

    return authorization


@app.route('/analyse', methods=['GET', 'POST'])
def proceed_analyse():
    authorization = VerifyAuthToken()

    if request.method == 'POST':
        image = request.files.get('image', '')

        if not image:
            return 'Image not provided', 400

        json = ProceedToAnalyse(image, token=authorization)

        if not json:
            return 'No coins found', 204

        return json, 201

    else:
        return jsonify(FetchUserAnalyses(authorization)), 200


@app.route('/feedback', methods=['POST'])
def save_feedback():
    authorization = VerifyAuthToken()

    SaveFeedbackForAnalyse(request.data)

    return 'OK', 200

if __name__ == '__main__':
    app.run()
