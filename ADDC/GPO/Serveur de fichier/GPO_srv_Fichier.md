# User Guide : Configuration des GPO pour Mapper les Dossiers Utilisateurs et Groupes

Ce guide explique comment configurer des **GPO (Group Policy Objects)** pour mapper automatiquement les lecteurs réseau, permettant aux utilisateurs d’accéder facilement à leurs dossiers personnels et aux dossiers partagés des groupes.

---

## **Objectif**
1. Mapper un lecteur réseau pour les dossiers personnels des utilisateurs.
2. Mapper un lecteur réseau pour les dossiers partagés des groupes.
3. Utiliser **une seule GPO par usage** (dossiers personnels et dossiers de groupes) pour simplifier la gestion.

---

## **Prérequis**

1. **Partages Réseau Configurés** :
   - Les dossiers utilisateurs (`D:\Partage\Utilisateurs`) et groupes (`D:\Partage\Groupes`) doivent être partagés avec les bonnes permissions :
     - **Chemin réseau pour les utilisateurs** : `\\ServeurDeFichiers\Utilisateurs`
     - **Chemin réseau pour les groupes** : `\\ServeurDeFichiers\Groupes`
   - Permissions :
     - Les utilisateurs doivent avoir accès à leurs dossiers personnels (lecture/écriture).
     - Les groupes doivent avoir accès uniquement à leurs dossiers respectifs.

2. **Compte Administrateur avec GPMC** :
   - Vous devez disposer d’un compte administrateur du domaine pour configurer les GPO via la console **GPMC (Group Policy Management Console)**.

3. **Utilisateurs et Groupes AD Configurés** :
   - Les utilisateurs et groupes doivent exister dans Active Directory.

---

## **Étape 1 : Créer la GPO pour les Dossiers Personnels**

### **1. Accédez à la Console GPMC**
1. Ouvrez **GPMC (Group Policy Management Console)** sur le contrôleur de domaine.
2. Créez une nouvelle GPO ou modifiez-en une existante :
   - **Nom de la GPO** : `Mapper les dossiers personnels`

### **2. Configurer le Mappage Automatique des Dossiers Personnels**
1. **Allez dans :**
   ```plaintext
   Configuration utilisateur > Préférences > Paramètres Windows > Lecteurs réseau
   ```
2. **Ajoutez une nouvelle entrée :**
   - **Action** : Créer.
   - **Emplacement** : `\\ServeurDeFichiers\Utilisateurs\%USERNAME%`
     - La variable `%USERNAME%` utilise le nom d'utilisateur pour mapper automatiquement le dossier correspondant.
   - **Lettre du lecteur** : Par exemple `U:` (pour utilisateur).
   - **Reconnecter** : Oui.
   - **Masquer ce lecteur** : Non.
   - **Rendre ce lecteur uniquement visible** : Non.
3. **Appliquez la GPO aux utilisateurs concernés :**
   - Liez cette GPO à une OU contenant les utilisateurs qui doivent recevoir ce mappage.

---

## **Étape 2 : Créer la GPO pour les Dossiers de Groupes**

### **1. Créez une Nouvelle GPO**
1. Retournez dans **GPMC**.
2. Créez une nouvelle GPO :
   - **Nom de la GPO** : `Mapper les dossiers de groupes`

### **2. Configurer le Mappage Automatique des Dossiers de Groupes**
1. **Allez dans :**
   ```plaintext
   Configuration utilisateur > Préférences > Paramètres Windows > Lecteurs réseau
   ```
2. **Ajoutez une nouvelle entrée pour chaque groupe :**
   - **Pour le groupe `Marketing` :**
     - **Action** : Créer.
     - **Emplacement** : `\\ServeurDeFichiers\Groupes\Marketing`
     - **Lettre du lecteur** : Par exemple `G:` (pour groupe).
     - **Reconnecter** : Oui.
   - Répétez pour chaque groupe si nécessaire.
3. **Conditionner les Mappages aux Groupes AD :**
   - **Dans l’onglet Commun**, cochez **Arrêter le traitement si une erreur survient**.
   - Cliquez sur **Ciblage au niveau des éléments** > **Nouveau** > **Membre du groupe** :
     - **Groupe cible** : `BARTINFO\Marketing`.

4. **Appliquez la GPO aux utilisateurs concernés :**
   - Liez cette GPO à une OU contenant les utilisateurs appartenant à ces groupes.

---

## **Étape 3 : Validation des GPO**

### **1. Appliquez les GPO**
1. Connectez-vous à une machine cliente avec un compte utilisateur.
2. Exécutez la commande suivante pour forcer l'application des GPO :
   ```cmd
   gpupdate /force
   ```

### **2. Vérifiez les Lecteurs Réseau**
1. Ouvrez l’explorateur de fichiers.
2. Vérifiez que :
   - Le lecteur `U:` pointe vers le dossier personnel de l’utilisateur.
   - Le lecteur `G:` (ou autre lettre) pointe vers le dossier du groupe approprié.

---

## **Étape 4 : Dépannage**

### **Si les Lecteurs ne se Mappent Pas :**
1. **Testez l’accès réseau :**
   ```cmd
   net use
   ```
   Vérifiez que les chemins `\\ServeurDeFichiers\Utilisateurs` et `\\ServeurDeFichiers\Groupes` sont accessibles.
2. **Vérifiez les Permissions :**
   - Assurez-vous que les utilisateurs/groupes ont les permissions nécessaires sur les partages et les dossiers NTFS.
3. **Vérifiez l’Appartenance aux Groupes :**
   - Confirmez que l’utilisateur appartient bien au groupe cible.
4. **Vérifiez l’Application des GPO :**
   ```cmd
   gpresult /r
   ```
   Assurez-vous que les GPO `Mapper les dossiers personnels` et `Mapper les dossiers de groupes` sont appliquées.

---

## **Résumé**

### **Une GPO pour les Dossiers Personnels**
- Utilisez `%USERNAME%` pour mapper les dossiers utilisateurs.
- Une seule GPO s’applique à tous les utilisateurs de l’OU concernée.

### **Une GPO pour les Dossiers de Groupes**
- Configurez un mappage par groupe et utilisez le ciblage pour restreindre l’application à ses membres.
- Une seule GPO gère tous les groupes.

---
