from flask import Flask, request

from src.controller.Analyzer import ProceedToAnalyse

app = Flask(__name__)

# CNN.create_dataset()

@app.route('/analyse', methods=['POST'])
def proceed_analyse():
    authorization = request.headers.get('Authorization')
    image = request.files.get('image', '')

    if not authorization or authorization == '':
        return 'Authorization token not provided', 401

    if not image:
        return 'Image not provided', 400

    json = ProceedToAnalyse(image, token=authorization, debug=request.args.get('debug') is not None)

    if not json:
        return 'No coins found', 204

    return json, 200


if __name__ == '__main__':
    app.run()
