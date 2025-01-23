# Tutoriel : Installation de WSUS 

## Introduction
Ce tutoriel vous guidera à travers l'installation et la configuration de base de Windows Server Update Services (WSUS). Nous commencerons par la création d'un disque de stockage dédié (D:) avec un dossier pour les fichiers WSUS.

---

## Étape 1 : Préparation du disque de stockage D:
1. **Ajout du disque** :
   - Ajoutez un nouveau disque à votre serveur .

2. **Initialisation et formatage du disque** :
   - Connectez-vous au serveur.
   - Ouvrez la console "Gestion des disques" :
     - `Windows + R` -> tapez `diskmgmt.msc` -> OK.
   - Identifiez le nouveau disque (non alloué).
   - Cliquez avec le bouton droit sur le disque et sélectionnez **Initialiser le disque**.
     - Sélectionnez le style de partition : **GPT** (recommandé).
   - Cliquez avec le bouton droit sur l'espace non alloué et sélectionnez **Nouveau volume simple**.
     - Suivez l'assistant pour :
       - Attribuer la lettre **D:**.
       - Formater en **NTFS** avec un nom de volume (ex. : "Stockage_WSUS").

3. **Création du dossier WSUS** :
   - Une fois le disque formaté et monté, ouvrez l'explorateur de fichiers.
   - Accédez au disque **D:**.
   - Créez un dossier nommé **WSUS**.

---

## Étape 2 : Installation de WSUS

1. **Ajout du rôle WSUS** :
   - Ouvrez le Gestionnaire de serveur (`Server Manager`).
   - Cliquez sur **Ajouter des rôles et des fonctionnalités**.
   - Dans l'assistant, sélectionnez :
     - **Type d'installation** : Installation basée sur un rôle ou une fonctionnalité.
     - **Serveur de destination** : Sélectionnez votre serveur.
     - **Rôle** : Cochez **Windows Server Update Services**.
       - Acceptez l'ajout des fonctionnalités requises.

2. **Configuration du rôle WSUS** :
   - Lors de l'installation du rôle :
     - **Services de rôle** : Laissez les options par défaut.
     - **Chemin d'accès au stockage** :
       - Sélectionnez le dossier créé précédemment : `D:\WSUS`.
   - Lancez l'installation et patientez jusqu'à la fin du processus.

---

## Étape 3 : Configuration post-installation de WSUS
1. **Lancement de la console WSUS** :
   - Une fois l'installation terminée, ouvrez la console WSUS :
     - `Outils` -> **Windows Server Update Services**.

2. **Assistant de configuration de WSUS** :
   - Dans la console, suivez les étapes de l'assistant de configuration initiale :
     - **Choisir le serveur de mise à jour en amont** :
       - Sélectionnez "Synchroniser à partir de Microsoft Update".
     - **Paramètres de connexion** : Laissez vide (sauf si vous utilisez un proxy) et cliquez sur Start Connecting.
     - **Choisir les langues** : Sélectionnez les langues nécessaires.
     - **Choisir les produits** : Cochez les produits à mettre à jour (ex. : Windows Server 2022, Windows 10).
     - **Choisir les classifications** : Sélectionnez les types de mises à jour (ex. : Mises à jour critiques, Définitions de sécurité). a changer
     - **Planifier la synchronisation** : Configurez la fréquence de synchronisation (ex. : quotidienne).
     - Lancez une première synchronisation.

3. **Validation** :
   - Pour voir l'état de la synchronisation, tu clic sur le nom de ton serveur dans la fenêtre, et tu as l'état de la synchronisation avec le widget Synchronization Status.

    - Va dans Options, puis Automatic Approvals.
    Dans l'onglet Update Rules, cocher Default Automatic Approval Rule.

    - Cela permet d'approuver automatiquement les mises à jour suivant les règles de la section Rule Properties se trouvant en dessous. Par défaut, une mise à jour Critique ou de Sécurité sont Approuvées sur tout les ordinateurs.

    - Cliquer sur Run Rules
    - Cliquer sur Apply et OK

---

## Étape 4 : Configuration des clients WSUS
1. **Configuration via stratégie de groupe (GPO)** :
   - Ouvrez la console de gestion des stratégies de groupe (GPMC).
   - Créez ou modifiez une stratégie appliquée aux ordinateurs cibles.
   - Configurez les paramètres suivants :
     - **Emplacement du serveur WSUS** :
       - `http://NomDuServeurWSUS` (remplacez par le nom ou l'IP de votre serveur).
     - **Planification des mises à jour automatiques** :
       - Activez les mises à jour automatiques et définissez un planning.

2. **Application de la stratégie** :
   - Appliquez la stratégie sur les clients.
   - Exécutez `gpupdate /force` sur un client pour valider l'application.
   - Vérifiez la connectivité avec le serveur WSUS :
     - Commande : `wuauclt /detectnow`.

---

## Conclusion
Vous avez maintenant installé et configuré un serveur WSUS de base avec un disque de stockage dédié pour les fichiers WSUS. Vous pouvez gérer les mises à jour et surveiller leur distribution à vos clients depuis la console WSUS.
