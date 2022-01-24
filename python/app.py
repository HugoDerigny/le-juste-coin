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


#CNN.create_dataset()

"""
Vérification de la présence du token "Authorization" dans les headers.
S'il est présent il est renvoyé,
sinon une erreur est levé.
"""
def VerifyAuthToken():
    authorization = request.headers.get('Authorization')

    if not authorization or authorization == '':
        raise ValueError('Authorization token not provided')

    return authorization


"""
Route principale de l'API.
Elle va servir à récupérer (GET) analyses, en créer une (POST) et en supprime une (DELETE)
"""
@app.route('/analyse', methods=['GET', 'POST', 'DELETE'])
def proceed_analyse():
    """
    On vérifie la présence du token, sinon erreur 401 unauthorized
    :return:
    """
    try:
        authorization = VerifyAuthToken()
    except ValueError as auth_error:
        return str(auth_error), 401

    if request.method == 'POST':
        """
        Pour la création, on check la présence de l'image dans le formdata, sinon bad request 400.
        """
        image = request.files.get('image', '')

        if not image:
            return 'Image not provided', 400

        """
        Le controller nous renvoie un JSON qui correspond au détail de l'analyse, si le json est vide, cela signifie
        que la reconnaissance d'image n'a trouvé aucun cercle, et par conséquence aucune pièce.
        """
        json = ProceedToAnalyse(image, token=authorization)

        if not json:
            return 'No coins found', 204

        return json, 201

    elif request.method == 'DELETE':
        """
        pour la suppression, l'id de l'analyse a supprimer est dans le JSON
        """
        try:
            analyze_id = request.json['analyze_id']

            """
            le controller ne renvoie rien si tout se passe bien, s'il y a une erreur, alors on la renvoie
            """
            error = DeleteUserAnalyze(authorization, analyze_id)

            if error:
                (err_message, err_code) = error
                return err_message, err_code

            return 'Analyze deleted', 204

        except TypeError:
            """
            Il n'y a pas de body ou il n'est pas au format json
            """
            return 'Empty body', 422

        except KeyError:
            """
            L'id de l'analyse n'est pas fourni
            """
            return 'Analyze ID not provided', 400

    else:
        """
        la méthode GET renvoie les analyses de l'utilisateur
        """
        return jsonify(FetchUserAnalyses(authorization)), 200


"""
endpoint pour enregistrer un retour de l'utilisateur
"""
@app.route('/feedback', methods=['POST'])
def save_feedback():
    """
    vérification du token de l'utilisateur
    :return:
    """
    try:
        VerifyAuthToken()
    except ValueError as auth_error:
        return auth_error, 401

    """
    le controlleur utilise les données envoyées dans le JSON pour effectuer la vérif 
    """
    SaveFeedbackForAnalyse(request.data)

    return 'OK', 200


if __name__ == '__main__':
    """
    l'ip est à changer pour pouvoir y accéder depuis le téléphone (sur iPhone il faut que ce soit l'ip du réseau)
    """
    app.run(host='172.20.10.2')
