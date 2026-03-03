# Prompt
Agis comme un architecte mobile senior spécialisé en Flutter (Clean Architecture, bonnes pratiques, code scalable).

Je veux concevoir une application mobile Flutter destinée à la collecte d’informations terrain pour des agents terrain.

OBJECTIF DE L’APPLICATION
Une application mobile permettant à des agents terrain de :
- Se connecter via une API REST
- Collecter des informations via un formulaire
- Joindre une photo (caméra ou galerie)
- Envoyer les données vers une API backend
- Visualiser la liste de leurs collectes avec statut

EXIGENCES FONCTIONNELLES

1) AUTHENTIFICATION
- Écran de connexion (email + mot de passe)
- Appel API POST /login
- L’API retourne :
    - token JWT
    - informations de l’agent (id, nom, email, zone)
- Stockage sécurisé du token (flutter_secure_storage)
- Gestion d’état connecté / non connecté
- Intercepteur HTTP pour ajouter automatiquement le token aux requêtes

2) FORMULAIRE DE COLLECTE
Écran permettant :
- Champ texte (nom client)
- Champ texte (prenom client)
- Champ téléphone
- Champ observation
- Champ Sélecteur (dropdown)
- Champ Sélecteur dropdown  (canal (campagne, normal))
- Champ téléphone secondaire
- Géolocalisation automatique (latitude, longitude)
- Champ Sélecteur dropdown  (Client ASAP (OUI, NOM))
- Champ texte (Immatriculation du vehicule)
- Champ texte (Lieu de prospection)
- Champ texte (Asuurence actuel)
- Champ texte (Date d echeance de l assurance)
- Champ fichier (Carte grise):
    - Choix caméra
    - Choix galerie
    - Compression d’image avant upload
- Champ fichier (Attesttation assurane):
    - Choix caméra
    - Choix galerie
    - Compression d’image avant upload
- Validation des champs
- Soumission via API POST /collect
- Envoi en multipart/form-data
- Gestion loading / erreur / succès

3) LISTE DES COLLECTES
- Écran listant les collectes de l’agent
- Appel API GET /my-collects
- Affichage :
    - Titre
    - Date
    - Statut (EN_ATTENTE, VALIDÉ, REJETÉ)
- Pull to refresh
- Gestion état vide

4) ARCHITECTURE
Je veux :
- Clean Architecture
- Séparation :
    - presentation
    - domain
    - data
- Utilisation de :
    - Riverpod ou Bloc (choisis la meilleure option et explique)
    - Dio pour les requêtes HTTP
    - Freezed pour les modèles si pertinent
- Gestion des erreurs propre
- Repository pattern
- DTO + Mapping vers entités

5) BONUS IMPORTANT
- Gestion mode offline :
    - Sauvegarde locale si pas d’internet
    - Sync automatique quand connexion revient
- Logging propre
- Gestion des exceptions centralisée

6) LIVRABLE ATTENDU
- Arborescence complète du projet
- Explication des choix techniques
- Code des fichiers principaux
- Exemple d’appel API avec Dio
- Exemple upload image multipart
- Exemple gestion token
- Exemple gestion état avec Riverpod/Bloc

Ne me donne pas un simple exemple basique.
Je veux une structure prête pour production et évolutive.
Explique les décisions techniques.
