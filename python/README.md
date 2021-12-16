# le-juste-coin

## Cas d'usage de l'api

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

1) L'utilisateur lance l'application et s'inscrit

- [x] Inscription dans Firebase
- [ ] Récupération des images uploadées
- [ ] Envoie du token d'authentification à l'API

2) Il prend une photos des pièces et valide l'envoi de la photo

- [ ] Upload de l'image dans le storage de Firebase : `/uploads/<uid>/<timestamp>/original.jpg`
- [ ] Enregistrement dans Firestore du timestamp.
- [ ] POST sur la route de traitement avec l'image

4) *L'API traite l'image et l'envoie*.

- [ ] L'API reçoit l'image
- [ ] Elle la traite
- [ ] Elle renvoie l'image avec les pièces entourées avec un numéro et leur valeur, et la somme de l'ensemble.

5) L'utilisateur reçoit l'image traitée.

*L'utilisateur indique si la somme est correcte ou non.*

**Si incorrecte**

- [ ] L'utilisateur va indique pour chaque pièce identifiée la valeur correcte.

**Si correcte**

*goto Fin*

**Fin**

- [ ] POST sur l'API qui va crop les pièces et les enregistrer dans le dataset.
- [ ]Upload de l'image dans le storage de Firebase : `/uploads/<uid>/<timesamp>/processed.jpg`
- [ ]Mise à jour de la gallerie qui affichage pour chaque `<timestamp>` la paire d'image (originale et traitée)

### Modèle de données

**Dataset**

```json
{
    "model": <01/F00344.jpg>,
    "user_id": <id>,
    "user_timestamp": <timestamp>
}
```

### Dataset

Votre dataset d’images de pièce de monnaie sera personnel, vous devrez être en mesure 
d’expliquer  les  difficultés  liées  à  vos  photos  ainsi  que  votre  méthodologie  afin  de  les 
résoudre. 
 
Vous organiserez votre structure de classes de la façon suivante : 
 
Chaque dossier de classe (01 à 08) contient des images de pièces de monnaie de 2 euros 
, 1 euro, 50 cent, 20 cent, 10 cent et 5 cent, respectivement. 
  
Le nom des images commence par la lettre F ou P selon si Pile ou Face suivi par un chiffre 
entre (00001 et 99999). Le format à privilégier sera le jpg. 
 
Ainsi  vous  pourrez  retrouver  le  chemin  suivant :  /data/06/F00002.jpg    qui  correspond  à 
l’image 00002 de type face de la classe 06 (5 cents). 
 
Le côté face est celui qui indique la valeur de la pièce de monnaie et est commun à toutes 
les pièces d’une même valeur quel que soit le pays d’origine de la pièce. 
 
Le coté PILE est différent selon le pays d’origine de la pièce.  
 
Les images de chaque pièce doivent être prises en variant : 
 
- La pièce de monnaie physique (utiliser différentes pièces de chaque classe) 
- Des conditions d’éclairage différentes (jour, ambiant, lampe de bureau, éclairage 
face, de côté, flash, etc.) 
- L’arrière-plan (utiliser des fonds de couleur et de textures différentes) 
- L’angle de prise de photo  
- La rotation de la pièce  
 
Ce travail de mise au point de la base de données peut être long, il est conseillé de travailler 
dessus dès le début du projet et remplir ce dataset au fur et à mesure.
