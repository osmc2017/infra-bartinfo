# User Guide : Configuration des GPO pour Mapper les Dossiers Utilisateurs

Ce guide explique comment configurer des **GPO (Group Policy Objects)** pour mapper automatiquement les lecteurs réseau, permettant aux utilisateurs d’accéder facilement à leurs dossiers personnels

---

## **Objectif**
1. Mapper un lecteur réseau pour les dossiers personnels des utilisateurs.


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
   - **Lettre du lecteur** : Par exemple `I:` (pour utilisateur).
   - **Reconnecter** : Oui.
   - **Masquer ce lecteur** : Non.
   - **Rendre ce lecteur uniquement visible** : Non.
3. **Appliquez la GPO aux utilisateurs concernés :**
   - Liez cette GPO à une OU contenant les utilisateurs qui doivent recevoir ce mappage.
     
![Capture d'écran 2024-12-30 104807](https://github.com/user-attachments/assets/c67b885d-94b1-4ac2-8ed5-11eca1fbe78b)

---

