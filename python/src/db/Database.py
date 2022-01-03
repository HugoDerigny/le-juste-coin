import datetime
import os
import sqlite3


# Connexion à la BDD incluse dans le projet et renvoie celle-ci
def __getconn__():
    dir_path = os.path.dirname(os.path.realpath(__file__))

    conn = sqlite3.connect(os.path.join(dir_path, 'db.db'))
    cursor = conn.cursor()

    return conn, cursor


# AJoute un élève en BDD selon son modèle.
# Vérification qu'il n'y a pas de doublon de prénom.
def CreateAnalyse(uuid, token):
    (conn, cursor) = __getconn__()

    now = datetime.datetime.now()

    try:
        cursor.execute('INSERT INTO analyse VALUES (?, ?, ?, ?)', [uuid, token, now, now])

        conn.commit()
        conn.close()

        return True

    except Exception as e:
        print('Erreur:', e)
        return False


def AddItemsToAnalyse(uuid, index, cents, confidence):
    (conn, cursor) = __getconn__()

    try:
        cursor.execute('INSERT INTO analyse_item VALUES (?, ?, ?, ?)', [uuid, index, cents, confidence])

        conn.commit()
        conn.close()

        return True

    except Exception as e:
        print('Erreur:', e)
        return False

def GetAnalysesOfUser(token=''):
    (conn, cursor) = __getconn__()

    try:
        data = cursor.execute('SELECT id, created_at, "index" as item, cents, confidence FROM analyse a INNER JOIN analyse_item ai on a.id = ai.analyse_id WHERE user_id = ?', [token])

        analyses = data.fetchall()

        if analyses is None:
            return []

        return analyses

    except Exception as e:
        print('Erreur:', e)
        return []


def UserOwnAnalyze(user_id, analyze_id):
    (conn, cursor) = __getconn__()

    try:
        data = cursor.execute('SELECT id FROM analyse WHERE id = ? AND user_id = ?', [analyze_id, user_id])

        row_count = len(data.fetchall())

        return row_count > 0

    except Exception:
        return False


def GetAnalyzeById(id):
    (conn, cursor) = __getconn__()

    try:
        data = cursor.execute('SELECT id, created_at, "index" as item, cents, confidence FROM analyse a INNER JOIN analyse_item ai on a.id = ai.analyse_id WHERE a.id = ?', [id])

        return data.fetchone()

    except Exception as e:
        print('Erreur:', e)
        return None


def RemoveUserAnalyse(id):
    (conn, cursor) = __getconn__()

    try:
        cursor.execute('DELETE FROM analyse_item WHERE analyse_id = ?', [id])
        cursor.execute('DELETE FROM analyse WHERE id = ?', [id])

        conn.commit()
        conn.close()

        return True

    except Exception as e:
        print('Erreur:', e)
        return False