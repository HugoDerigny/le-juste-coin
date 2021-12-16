from flask import Flask, request, jsonify

from src.controller.Analyzer import ProceedToAnalyse, FetchUserAnalyses

app = Flask(__name__)

# CNN.create_dataset()

@app.route('/analyse', methods=['GET', 'POST'])
def proceed_analyse():
    authorization = request.headers.get('Authorization')

    if not authorization or authorization == '':
        return 'Authorization token not provided', 401

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


if __name__ == '__main__':
    app.run()
