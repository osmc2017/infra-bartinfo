# User Guide : Mappage Automatique des Dossiers Départementaux par GPO (Sans Script)

Ce guide explique comment configurer une **GPO unique** pour mapper automatiquement les lecteurs réseau des dossiers départementaux en fonction des **groupes de sécurité** associés à vos OUs Active Directory.

---

## **Prérequis**

1. **Structure Active Directory (AD)** :
   - Une OU principale contenant les OUs pour chaque département.
     Exemple :
     ```
     OU=Departements,DC=bartinfo,DC=com
         ├── OU=RH
         ├── OU=IT
         └── OU=Finance
     ```

2. **Groupes de Sécurité** :
   - Chaque OU a un groupe de sécurité correspondant :
     - `G_RH` pour `OU=RH`
     - `G_IT` pour `OU=IT`
     - `G_Finance` pour `OU=Finance`

3. **Structure des Dossiers Partagés** :
   - Les dossiers partagés des départements sont situés sur le serveur de fichiers, avec une structure comme :
     ```
     C:\Partage\Departements\RH
     C:\Partage\Departements\IT
     C:\Partage\Departements\Finance
     ```

4. **Permissions** :
   - Chaque groupe de sécurité (`G_RH`, `G_IT`, etc.) doit avoir **Lecture/Écriture** sur le dossier correspondant.

---

## **Étapes de Configuration**

### **Étape 1 : Créer une Nouvelle GPO**
1. Ouvrez la console **GPMC** :
   - Tapez `gpmc.msc` dans une invite de commande.

2. Créez une nouvelle GPO :
   - Faites un clic droit sur le domaine ou l’OU principale > **Créer une GPO dans ce domaine et la lier ici**.
   - Donnez un nom à la GPO, par exemple : **Mapping Lecteurs Départementaux**.

---

### **Étape 2 : Configurer le Mappage des Lecteurs Réseau**

#### **A. Accéder aux Paramètres de Drive Maps**
1. Dans la GPO, accédez à :
   ```
   Configuration utilisateur > Preferences > Windows Settings > Drive Maps
   ```

#### **B. Créer une Règle par Département**
1. **Créez une nouvelle règle pour chaque département** :
   - Faites un clic droit > **Nouveau > Lecteur réseau**.
2. Configurez les paramètres pour chaque règle :
   - **Action** : Créer.
   - **Emplacement** :
     - Exemple pour le département RH :
       ```
       \\SRV_FICHIER\Partage\Departements\RH
       ```
     - Remplacez `RH` par le nom du département correspondant.
   - **Lettre de lecteur** : K: (ou une autre lettre libre).
   - **Reconnecter** : Oui.
   - 
![Capture d'écran 2024-12-30 104953](https://github.com/user-attachments/assets/46643e8f-5393-4fdb-b4f6-916bd3667901)

![Capture d'écran 2024-12-30 105006](https://github.com/user-attachments/assets/2838db5d-6d62-4399-817e-8e4f4b54e2e4)

#### **C. Ajouter un Filtrage Dynamique**
1. Cliquez sur l'onglet **Common** (Commun) en haut de la fenêtre de configuration du lecteur.
2. Activez **Item-level Targeting** (Ciblage au niveau de l’élément).
3. Cliquez sur **Targeting...** pour ouvrir l’éditeur.
4. Configurez une règle pour chaque département :
   - Cliquez sur **New Item > Security Group**.
   - Entrez le nom exact du groupe de sécurité correspondant :
     - Exemple :
       - Pour `\\SRV_FICHIER\Partage\Departements\RH`, entrez `G_RH`.
       - Pour `\\SRV_FICHIER\Partage\Departements\IT`, entrez `G_IT`.
       - 
![Capture d'écran 2024-12-30 105014](https://github.com/user-attachments/assets/9a682489-444d-4109-b6c7-17d72eb777b9)

![Capture d'écran 2024-12-30 105022](https://github.com/user-attachments/assets/957b8d6e-cd48-4cd9-b245-e9bcee9fbba7)

---

### **Étape 3 : Lier la GPO**
1. Liez la GPO à l’OU principale contenant vos utilisateurs :
   - Exemple : `OU=Departements,DC=bartinfo,DC=com`.

2. Assurez-vous que tous les utilisateurs sont correctement membres des groupes de sécurité correspondant à leur département.

---

### **Étape 4 : Tester et Valider**

1. Forcez l’application de la GPO sur un poste client avec la commande suivante :
   ```cmd
   gpupdate /force
   ```

2. Connectez-vous avec un utilisateur appartenant à un groupe de sécurité (par exemple, `G_RH`).
3. Vérifiez que :
   - Le lecteur réseau `K:` est mappé à :
     ```
     \\SRV_FICHIER\Partage\Departements\RH
     ```

4. Testez avec un utilisateur appartenant à un autre groupe de sécurité pour valider le mappage correct.
5. 
![Capture d'écran 2024-12-30 105224](https://github.com/user-attachments/assets/e940dfc9-5ca2-4187-879b-c0e01457ea7e)

---

## **Maintenance**

1. **Ajout d’un Nouvel Utilisateur** :
   - Ajoutez l’utilisateur au groupe de sécurité correspondant à son département. Le lecteur réseau sera mappé automatiquement lors de sa prochaine connexion.

2. **Ajout d’un Nouveau Département** :
   - Créez un nouveau dossier pour le département sur le serveur.
   - Configurez les permissions NTFS et de partage pour le nouveau groupe de sécurité.
   - Ajoutez une nouvelle règle dans la GPO pour le mappage du nouveau département.

---

## **Résumé**
- **GPO Unique** : Une seule GPO gère tous les départements.
- **Drive Maps** : Chaque lecteur réseau est configuré avec un ciblage basé sur les groupes de sécurité.
- **Dynamisme** : Les utilisateurs obtiennent automatiquement le bon lecteur réseau en fonction de leur groupe de sécurité.


