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

# Renvoie un élève et ses notes de la BDD selon son nom.
# def GetStudent(arg_name):
#     (conn, cursor) = __getconn__()
#
#     """ FETCHING STUDENT """
#
#     data = cursor.execute('SELECT * FROM students WHERE name= ?', [arg_name])
#     raw_student = data.fetchone()
#
#     if raw_student is None:
#         print('[DB] No student found with name', arg_name)
#         return None
#
#     print('[DB] Found students with name', arg_name, ':', raw_student)
#
#     (uuid, name, password, picture_name, addr, city) = raw_student
#
#     """ FETCHING STUDENT GRADES """
#
#     data = cursor.execute('SELECT * FROM grades WHERE user_id = ?', [uuid])
#     raw_grades = data.fetchall()
#
#     grades = []
#
#     print('[DB] Grades for student :', raw_grades)
#
#     if raw_grades is not None:
#         for (uuid, grade) in raw_grades:
#             grades.append(Grade(uuid, grade))
#
#     conn.close()
#
#     return Student(uuid, name, addr, city, password, picture_name, grades)
#
#
# # Supprime un élève en BDD selon son nom.
# def DeleteStudent(arg_name):
#     (conn, cursor) = __getconn__()
#
#     data = cursor.execute('DELETE FROM students WHERE name = ?', [arg_name])
#
#     print('[DB] Deleted student', arg_name)
#
#     conn.commit()
#     conn.close()
#
#     return True
#
#
# # Met à jour un élève en BDD selon son nom et avec les nouvelles valeurs du modèle passé en paramètre.
# def UpdateStudent(arg_name, student):
#     (conn, cursor) = __getconn__()
#
#     student_values = student.to_db()
#     """ Removing uid """
#     del student_values[0]
#
#     cursor.execute(
#         'UPDATE students SET name = ?, password = ?, picture = ?, addr = ?, city = ? WHERE name = ?',
#         [*student_values, arg_name])
#
#     print('[DB] Updated student', arg_name, 'with new values', student)
#
#     conn.commit()
#     conn.close()
#
#     return GetStudent(student.name)
#
#
# # Ajoute une note à un élève.
# def AddGradeToStudent(arg_name, grade):
#     (conn, cursor) = __getconn__()
#
#     student = GetStudent(arg_name)
#
#     if student is None:
#         return False
#
#     cursor.execute('INSERT INTO grades VALUES (?, ?)', [student.uuid, int(grade)])
#
#     print('[DB] Created grade', grade, 'for', student.name)
#
#     conn.commit()
#     conn.close()
#
#     return True
