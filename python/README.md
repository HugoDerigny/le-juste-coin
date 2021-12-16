# le-juste-coin

Ce server flutter a pour but d'analyser une image envoyé par un utilisateur, renvoyer les résultats
et stocker ceux-ci dans Firebase ainsi quand dans une BDD locale SQLite.

## Todo...

### Web serveur
- [x] Envoyer une image pour analyse
- [x] L'utilisateur récupère ses résultats
- [ ] L'utilisateur effectue un retour sur un résultat pour indiquer s'il est correct. 

### Machine learning
- [ ] *Remplir le dataset (40%...)*
- [x] Créer le modèle
- [ ] Gérer le retour utilisateur par rapport aux résultats d'une image

### Gestion des images
- [x] Traiter les images (transformations et détection des cercles)
- [x] Sauvegar les images dans Firebase Storage

## API Rest documentation

### GET /analyse/:uid

**Description**

Renvoie les différentes analyses d'un utilisateurs.

**Requête**

- Headers

```json
{
  "Authorization": <firebase_token>
}
```

**Réponse**

````json
[
  {
    "id": "#123456",
    "created_at": "2021-12-16 11:38:14.687588",
    "items": [
      {
        "id": "#123456-1",
        "cents": 50,
        "confidence": 76
      },
      {
        "id": "#123456-2",
        "cents": 200,
        "confidence": 54
      }
    ],
    "sum_of_coins": 250,
    "average_confidence": 65
  },
  ...
]
````

### POST /analyse

**Description**

Récupère l'image dans la requête, effectue l'analyse et renvoie un objet json:

En parrallèle, les images sont enregistrées dans le Storage Firebase.

**Requête**

- Headers

```json
{
  "Authorization": <firebase_token>,
  "Content-Type": "multipart/form-data"
}
```

- Body

```json
{
  "image": <image_file>
}
```

**Réponse**
```json
{
  "items": {
    "#123456-1": {
      "cents": 50,
      "confidence": 76
    },
    "#123456-2": {
      "cents": 200,
      "confidence": 54
    }
  },
  "sum_of_coins": 250,
  "average_confidence": 65
}
```

## Modèle de données

Définitions des différentes tables ...

**analyse**

| id     | user_id | created_at                 | updated_at                  |
|--------|---------|----------------------------|-----------------------------|
| 123456 | USER_1  | 2021-12-16 11:38:14.687588 | 2021-12-16 11:38:14.687588  |
| ABCDEF | USER_2  | 2021-12-16 11:38:14.687588 | 2021-12-16 11:38:14.687588  |


**analyse_item**

| analyse_id | cents | confidence   | index |
|------------|-------|--------------|-------|
| 123456     | 50    | 62.123901284 | 1     |
| 123456     | 10    | 12.583750197 | 2     |
| ABCDEF     | 200   | 98.531953191 | 1     |
