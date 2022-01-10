import os

from flask import Flask, request, jsonify

from src.controller.Analyzer import ProceedToAnalyse, FetchUserAnalyses, DeleteUserAnalyze
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


CNN.create_dataset()

def VerifyAuthToken():
    authorization = request.headers.get('Authorization')

    if not authorization or authorization == '':
        raise ValueError('Authorization token not provided')

    return authorization


@app.route('/analyse', methods=['GET', 'POST', 'DELETE'])
def proceed_analyse():
    try:
        authorization = VerifyAuthToken()
    except ValueError as auth_error:
        return str(auth_error), 401

    if request.method == 'POST':
        image = request.files.get('image', '')

        if not image:
            return 'Image not provided', 400

        json = ProceedToAnalyse(image, token=authorization)

        if not json:
            return 'No coins found', 204

        return json, 201

    elif request.method == 'DELETE':
        try:
            analyze_id = request.json['analyze_id']

            error = DeleteUserAnalyze(authorization, analyze_id)

            if error:
                (err_message, err_code) = error
                return err_message, err_code

            return 'Analyze deleted', 204

        except TypeError as e:
            print('Typeerror', e)
            return 'Empty body', 422

        except KeyError as e:
            print('keyrror', e)
            return 'Analyze ID not provided', 400

    else:
        return jsonify(FetchUserAnalyses(authorization)), 200


@app.route('/feedback', methods=['POST'])
def save_feedback():
    try:
        VerifyAuthToken()
    except ValueError as auth_error:
        return auth_error, 401

    SaveFeedbackForAnalyse(request.data)

    return 'OK', 200


if __name__ == '__main__':
    app.run(host='172.20.10.2')
