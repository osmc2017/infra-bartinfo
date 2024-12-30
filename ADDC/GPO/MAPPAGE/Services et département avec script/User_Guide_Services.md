# User Guide : Script PowerShell pour Mapper les Services Dynamiquement

Ce guide explique comment utiliser un script PowerShell pour mapper automatiquement les lecteurs réseau des services d’un utilisateur, en fonction de leur emplacement dans les **OUs Active Directory**. Ce script s’adapte à une structure où les dossiers de services sont directement situés sous `Services`.

---

## **Structure Requise**

### **1. Active Directory**

L’utilisateur doit être placé dans une hiérarchie Active Directory similaire à :

```plaintext
OU=Service1,OU=Service Juridique,OU=Departements,DC=bartinfo,DC=com
```

- Le service est contenu dans une **sous-OU** d’un département.

### **2. Dossiers Partagés**

Les dossiers des services doivent exister dans un dossier partagé sur le serveur de fichiers :

```plaintext
\\SRV_FICHIER\Partage\Services\<Nom_du_Service>
```

Exemples :
- `\\SRV_FICHIER\Partage\Services\Service1`
- `\\SRV_FICHIER\Partage\Services\Service2`

### **3. Permissions**

- Les utilisateurs doivent avoir des droits **Lecture/Écriture** sur les dossiers partagés correspondant à leur service.

---

## **Étapes de Déploiement du Script**

### **1. Placer le Script sur le Serveur**

1. Enregistrez le script sous un fichier, par exemple :
   ```plaintext
   \SRV_FICHIER\Scripts\MapServices.ps1
   ```

2. Assurez-vous que tous les utilisateurs ont des droits de lecture sur le dossier contenant le script.

---

### **2. Déployer via une GPO avec Tâche Planifiée**

![Capture d'écran 2024-12-30 105438](https://github.com/user-attachments/assets/06ccb6ef-a5bf-4a4d-bbb3-f864d572f2c6)

1. **Ouvrir la Console GPMC** :
   - Tapez `gpmc.msc` dans une invite de commande.

2. **Créer une Nouvelle GPO** :
   - Créez une GPO appelée par exemple : **Mapping Services**.
   - Liez cette GPO à l’OU contenant les utilisateurs.

3. **Configurer une Tâche Planifiée** :
   - Accédez à :
     ```plaintext
     Configuration utilisateur > Preferences > Control Panel Settings > Scheduled Tasks
     ```
   - Faites un clic droit > **New > Immediate Task (At least Windows 7)**.

4. **Paramètres de la Tâche** :

   - **General** :
     - Nom : `Map Services`.
     - Sécurité : **Run whether user is logged on or not**.
     - Cochez : **Do not store password**.

![Capture d'écran 2024-12-30 105547](https://github.com/user-attachments/assets/35bd3e73-8c22-4582-a42c-50610fd9571e)

   - **Triggers** :
     - Créez un nouveau déclencheur : **At log on**.

![Capture d'écran 2024-12-30 105553](https://github.com/user-attachments/assets/b43b8563-b7ff-4442-a445-81a82eab132b)

   - **Actions** :
     - **Program/script** : `powershell.exe`
     - **Arguments** :
       ```plaintext
       -ExecutionPolicy Bypass -File \SRV_FICHIER\Scripts\MapServices.ps1
       ```

![Capture d'écran 2024-12-30 105601](https://github.com/user-attachments/assets/8c3e65d2-ec83-4709-b7b3-ab6c43deb130)

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
     C:\Users\<NomUtilisateur>\MapDriveLog_Services.txt
     ```

![Capture d'écran 2024-12-30 105833](https://github.com/user-attachments/assets/8693a8b8-ae59-41ad-890a-412676445911)

3. **Testez le Mappage** :
   - Vérifiez dans l’Explorateur de fichiers si le lecteur réseau `Z:` est correctement mappé.

![Capture d'écran 2024-12-30 105224](https://github.com/user-attachments/assets/d199b8c5-a077-469e-93d2-5528b4dccbff)

---

## **Dépannage**

- **Problème de Chemin Réseau** :
  - Assurez-vous que le dossier partagé du service existe.

- **Problème de Droits** :
  - Vérifiez que l’utilisateur a les permissions nécessaires sur le dossier partagé.

- **Erreur dans les Logs** :
  - Consultez les logs pour identifier l’étape qui pose problème.

---

Ce guide détaille les étapes nécessaires pour déployer un script PowerShell via une tâche planifiée et mapper automatiquement les lecteurs réseau des services pour chaque utilisateur.
