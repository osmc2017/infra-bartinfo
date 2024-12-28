# User Guide : Mappage Automatique des Lecteurs Réseau des Départements

Ce guide explique comment déployer une méthode automatique pour mapper les lecteurs réseau des **départements** d’un utilisateur, en fonction de leur emplacement dans les **OUs Active Directory**. Cette méthode repose sur un script PowerShell déployé via une tâche planifiée.

---

## **Structure Requise**

### **1. Active Directory**

L’utilisateur doit être placé dans une hiérarchie Active Directory similaire à :

```plaintext
OU=Service1,OU=RH,OU=Departements,DC=bartinfo,DC=com
```

- Le département doit se trouver dans une sous-OU de `OU=Departements`.

### **2. Dossiers Partagés**

Les dossiers des départements doivent exister dans un dossier partagé sur le serveur de fichiers :

```plaintext
\\SRV_FICHIER\Partage\Departements\<Nom_du_Departement>
```

Exemples :
- `\\SRV_FICHIER\Partage\Departements\RH`
- `\\SRV_FICHIER\Partage\Departements\IT`

### **3. Permissions**

- Les utilisateurs doivent avoir des droits **Lecture/Écriture** sur les dossiers partagés correspondant à leur département.

---

## **Étapes de Déploiement du Script**

### **1. Placer le Script sur le Serveur**

1. Enregistrez le script sous un fichier, par exemple :
   ```plaintext
   \SRV_FICHIER\Scripts\MapDepartements.ps1
   ```

2. Assurez-vous que tous les utilisateurs ont des droits de lecture sur le dossier contenant le script.

---

### **2. Déployer via une GPO avec Tâche Planifiée**

1. **Ouvrir la Console GPMC** :
   - Tapez `gpmc.msc` dans une invite de commande.

2. **Créer une Nouvelle GPO** :
   - Créez une GPO appelée par exemple : **Mapping Départements**.
   - Liez cette GPO à l’OU contenant les utilisateurs.

3. **Configurer une Tâche Planifiée** :
   - Accédez à :
     ```plaintext
     Configuration utilisateur > Preferences > Control Panel Settings > Scheduled Tasks
     ```
   - Faites un clic droit > **New > Immediate Task (At least Windows 7)**.

4. **Paramètres de la Tâche** :

   - **General** :
     - Nom : `Map Departements`.
     - Sécurité : **Run whether user is logged on or not**.
     - Cochez : **Do not store password**.

   - **Triggers** :
     - Créez un nouveau déclencheur : **At log on**.

   - **Actions** :
     - **Program/script** : `powershell.exe`
     - **Arguments** :
       ```plaintext
       -ExecutionPolicy Bypass -File \SRV_FICHIER\Scripts\MapDepartements.ps1
       ```

   - **Conditions** :
     - Décochez toutes les options liées à l’alimentation.

   - **Settings** :
     - Cochez : **Allow task to be run on demand**.

5. **Appliquer la GPO et Tester** :
   - Forcez l’application de la GPO sur un poste client avec :
     ```cmd
     gpupdate /force
     ```

---

## **Vérification**

1. **Forcer l’Application de la GPO** :
   - Sur un poste client, exécutez :
     ```cmd
     gpupdate /force
     ```

2. **Vérifiez les Logs** :
   - Consultez le fichier log généré sur le poste client :
     ```plaintext
     C:\Users\<NomUtilisateur>\MapDriveLog_Departements.txt
     ```

3. **Testez le Mappage** :
   - Vérifiez dans l’Explorateur de fichiers si le lecteur réseau `J:` est correctement mappé.

---

## **Dépannage**

- **Problème de Chemin Réseau** :
  - Assurez-vous que le dossier partagé du département existe.

- **Problème de Droits** :
  - Vérifiez que l’utilisateur a les permissions nécessaires sur le dossier partagé.

- **Erreur dans les Logs** :
  - Consultez les logs pour identifier l’étape qui pose problème.

---

