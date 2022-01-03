# le-juste-coin app mobile

## Installation

1. Installer le projet depuis Git

2. Installer les dépendences
`flutter pub get`

3. Définir l'URL de l'API dans le fichier `.env`


4. *(si l'API est en local)* Lancer la commande adb afin d'accéder au serveur
`adb reverse tcp:5000 tcp:5000`

5. Démarrer le projet avec le fichier `main.dart`

## Roadmap

### Utilisateurs

- [x] Création de compte
- [x] Connexion
- [ ] Suppression de compte

### Traitements images

- [ ] Envoyer la photo au serveur
- [ ] Récupérer la gallerie
- [ ] Récupérer la photo originale d'un item
- [ ] Récupérer les photos traitées d'un item

### UI/UX

- [x] Gallerie
- [ ] Item (manque "Réeffectuer l'analyse")
- [ ] Fenêtre de validation d'analyse
- [ ] Tri de la gallerie (date, confiance...)