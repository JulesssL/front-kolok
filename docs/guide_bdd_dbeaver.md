# Guide : Accéder à la base de données Kolok (VPS) via DBeaver

La base de données PostgreSQL de Kolok est sécurisée dans un conteneur Docker sur votre VPS. Elle n'est accessible que localement (`127.0.0.1`) pour des raisons de sécurité. 

Pour y accéder depuis votre ordinateur sans ouvrir les ports du serveur au public, nous allons utiliser un **Tunnel SSH** intégré à DBeaver.

## 1. Créer une nouvelle connexion dans DBeaver
1. Ouvrez DBeaver.
2. Cliquez sur l'icône de prise électrique **"Nouvelle Connexion"** (en haut à gauche).
3. Sélectionnez **PostgreSQL** dans la liste et cliquez sur *Suivant*.

## 2. Configurer les paramètres de connexion (Onglet : Principal)
Dans cet onglet, vous indiquez comment vous connecter à la base de données *une fois que vous êtes virtuellement sur le serveur*.
- **Hôte (Host)** : `localhost` ou `127.0.0.1`
- **Port** : `5432`
- **Base de données (Database)** : `kolok_db` (ou le nom exact défini dans votre `.env`)
- **Utilisateur (User)** : `postgres` (ou défini dans votre `.env`)
- **Mot de passe (Password)** : Entrez le mot de passe de production défini dans votre fichier `.env` sur le serveur (ou `password123` par défaut).

## 3. Configurer le Tunnel SSH (Onglet : SSH)
C'est ici que la magie opère. DBeaver va d'abord se connecter en SSH à votre serveur, puis établir la connexion à la base de données.
1. Allez dans l'onglet **"SSH"** sur le menu de gauche de la fenêtre de connexion.
2. Cochez **"Utiliser un tunnel SSH"**.
3. **Hôte/IP (Host/IP)** : L'adresse IP de votre serveur VPS.
4. **Port** : `22` (Sauf si vous avez changé le port SSH).
5. **Nom d'utilisateur (User Name)** : Votre utilisateur serveur (souvent `root` ou `ubuntu`).
6. **Méthode d'authentification** : 
   - Si vous utilisez un mot de passe : Saisissez votre mot de passe serveur.
   - Si vous utilisez une clé SSH (recommandé) : Sélectionnez "Clé publique" et indiquez le chemin vers votre clé privée (`.pem` ou `id_rsa`).

## 4. Tester et Valider
1. Cliquez sur le bouton **"Test de connexion..."** en bas à gauche. 
2. Si DBeaver indique *Connecté*, cliquez sur **Terminer**.

---

## 5. Comment interagir et supprimer des données ?

Une fois connecté, la base de données apparaîtra dans votre panneau de gauche.
1. Déroulez : `Votre connexion` > `Bases de données` > `kolok_db` > `Schémas` > `public` > `Tables`.
2. Vous verrez vos tables (`users`, `tasks`, `koloks`, etc.).
3. **Double-cliquez** sur une table (par exemple `users`).
4. Dans le panneau de droite, allez dans l'onglet **"Données"** pour voir toutes les lignes.

### Pour supprimer un compte de test :
1. Cherchez la ligne du compte dans l'onglet "Données" de la table `users`.
2. Cliquez dessus pour la sélectionner, puis appuyez sur la touche `Suppr` (ou Clic droit > Supprimer la ligne).
3. La ligne deviendra rouge.
4. Cliquez sur le bouton **"Save"** (Disquette) en bas du tableau pour exécuter la requête de suppression.

*(Attention : Si cet utilisateur a créé des tâches ou des dépenses liées (Clés étrangères), la base de données pourrait refuser la suppression sauf si vous supprimez d'abord ses actions, ou si les contraintes `ON DELETE CASCADE` sont configurées).*
