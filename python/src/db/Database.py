import datetime
import os
import sqlite3


def __getconn__():
    """
    renvoie la connexion à la DB locale SQLITE
    :return:
    """
    dir_path = os.path.dirname(os.path.realpath(__file__))

    conn = sqlite3.connect(os.path.join(dir_path, 'db.db'))
    cursor = conn.cursor()

    return conn, cursor


def CreateAnalyse(uuid, token):
    """
    ajoute une analyse pour un utilisateur
    :param uuid:
    :param token:
    :return:
    """
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
    """
    ajoute un détail d'analyse à une analyse
    :param uuid:
    :param index:
    :param cents:
    :param confidence:
    :return:
    """
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
    """
    renvoie les analyses d'un utilisateur
    :param token:
    :return:
    """
    (conn, cursor) = __getconn__()

    try:
        data = cursor.execute('SELECT id, created_at, "index" as item, cents, confidence FROM analyse a INNER JOIN analyse_item ai on a.id = ai.analyse_id WHERE user_id = ? ORDER BY a.created_at DESC', [token])

        analyses = data.fetchall()

        if analyses is None:
            return []

        return analyses

    except Exception as e:
        print('Erreur:', e)
        return []


def UserOwnAnalyze(user_id, analyze_id):
    """
    renvoie true ou false selon si le user_id lié à l'analyse_id est le même que user_id passé en paramètre
    :param user_id:
    :param analyze_id:
    :return:
    """
    (conn, cursor) = __getconn__()

    try:
        data = cursor.execute('SELECT id FROM analyse WHERE id = ? AND user_id = ?', [analyze_id, user_id])

        row_count = len(data.fetchall())

        return row_count > 0

    except Exception:
        return False


def GetAnalyzeById(id):
    """
    renvoie une analyse selon son id
    :param id:
    :return:
    """
    (conn, cursor) = __getconn__()

    try:
        data = cursor.execute('SELECT id, created_at, "index" as item, cents, confidence FROM analyse a INNER JOIN analyse_item ai on a.id = ai.analyse_id WHERE a.id = ?', [id])

        return data.fetchall()

    except Exception as e:
        print('Erreur:', e)
        return None


def RemoveUserAnalyse(id):
    """
    supprime les détails et l'analyse
    :param id:
    :return:
    """
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