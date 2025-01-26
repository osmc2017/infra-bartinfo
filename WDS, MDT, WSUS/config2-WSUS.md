# Lier les machines du domaine au serveur WSUS

## Prérequis
Avant de commencer, assurez-vous de disposer :
- D’un domaine Active Directory fonctionnel avec un contrôleur de domaine (par exemple, `SRV-ADDS-01`).
- D’un serveur WSUS configuré et fonctionnel.
- Des machines jointes à votre domaine Active Directory.

## Sommaire
1. Modifier la méthode d’affectation des ordinateurs
2. Créer des groupes d’ordinateurs dans WSUS
3. Lier les PC et les serveurs à WSUS par GPO
   - A. GPO WSUS pour les paramètres communs
   - B. GPO WSUS spécifique aux postes de travail
   - C. GPO WSUS spécifique aux serveurs
   - D. Tester la GPO WSUS

---

## 1. Modifier la méthode d’affectation des ordinateurs
Par défaut, WSUS place les nouveaux ordinateurs dans le groupe "Ordinateurs non attribués". Pour automatiser leur placement dans des groupes prédéfinis :

1. Ouvrez la console WSUS.
2. Cliquez sur **Options** dans le menu de gauche.
3. Cliquez sur **Computers** ou **Ordinateurs**.
4. Sélectionnez l’option **Use Group Policy or registry settings on computers** / **Utiliser les paramètres de stratégie de groupe ou de Registre sur les ordinateurs**.
5. Cliquez sur **OK**.

---

## 2. Créer des groupes d’ordinateurs dans WSUS

1. Ouvrez la console WSUS.
2. Faites un clic droit sur **Tous les ordinateurs** puis cliquez sur **Add Computer Group**.
3. Créez les groupes suivants :
   - **PC** (pour les postes de travail)
   - **Serveurs**
   - (Optionnel) **Tests** (pour tester les mises à jour avant leur déploiement général).
4. Une fois les groupes créés, vous devriez voir une arborescence reflétant cette organisation.

---

## 3. Lier les PC et les serveurs à WSUS par GPO

### A. GPO WSUS pour les paramètres communs

1. Sur votre contrôleur de domaine, ouvrez la **Gestion des stratégies de groupe**.
2. Créez une nouvelle GPO nommée **WSUS – Paramètres communs** et liez-la à la racine du domaine (ou à une OU ciblée).
3. Modifiez la GPO et parcourez l’arborescence suivante :
   - **Configuration ordinateur > Stratégies > Modèles d'administration > Composants Windows > Windows Update**.

#### Paramètres à configurer :
1. **Spécifier l’emplacement intranet du service de mise à jour Microsoft** :
   - Activez ce paramètre.
   - Entrez l’URL de votre serveur WSUS, par exemple : `http://srv-wsus.it-connect.local:8530`.
2. **Configuration du service Mises à jour automatique** :
   - Activez ce paramètre.
   - Choisissez l’option **4 - Téléchargement automatique et planification des installations**.
   - Définissez les plages horaires pour les mises à jour, par exemple : **12:00** tous les jours en fin de mois.
3. **Ne pas se connecter à des emplacements Internet Windows Update** :
   - Activez ce paramètre pour forcer l’utilisation du WSUS.

---

### B. GPO WSUS spécifique aux postes de travail

1. Créez une nouvelle GPO nommée **WSUS – PC** et liez-la à l’OU contenant vos postes de travail (ex. **PC**).
2. Modifiez la GPO et accédez aux mêmes paramètres que précédemment.
3. Configurez les paramètres suivants :
   - **Autoriser le ciblage côté client** :
     - Activez ce paramètre et entrez "PC" comme nom de groupe cible.
   - **Désactiver le redémarrage automatique pour les mises à jour pendant les heures d’activité** :
     - Activez ce paramètre et définissez une plage horaire (ex. **07:00 à 19:00**).

---

### C. GPO WSUS spécifique aux serveurs

1. Créez une nouvelle GPO nommée **WSUS – Serveurs** et liez-la aux OUs contenant vos serveurs (ex. **Serveurs** et **Domain Controllers**).
2. Modifiez la GPO et accédez aux mêmes paramètres que précédemment.
3. Configurez les paramètres suivants :
   - **Autoriser le ciblage côté client** :
     - Activez ce paramètre et entrez "Serveurs" comme nom de groupe cible.
   - **Désactiver le redémarrage automatique pour les mises à jour pendant les heures d’activité** :
     - Activez ce paramètre et définissez une plage horaire (ex. **05:00 à 23:00**).

---

### D. Tester la GPO WSUS

1. Connectez-vous sur une machine du domaine (ex. **PC-01**).
2. Actualisez les GPO avec la commande :
   ```
   gpupdate /force
   ```
3. Redémarrez la machine.
4. Vérifiez la présence de la machine dans WSUS :
   - Ouvrez la console WSUS.
   - Accédez au groupe "PC" ou "Serveurs".
   - Cliquez sur **Actualiser**.
5. Si la machine n’apparaît pas, forcez la détection des mises à jour sur le client :
   - Accédez à **Windows Update** dans les Paramètres.
   - Cliquez sur **Rechercher des mises à jour**.
6. Utilisez l’outil **gpresult** pour vérifier l’application de la GPO :
   ```
   gpresult /h resultat.html
   ```

Une fois la configuration validée, vos machines seront liées au serveur WSUS et gérées selon les paramètres définis.

