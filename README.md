## Projet d'Infrastructure Réseau : BartInfo

Bienvenue dans le projet **BartInfo**, une infrastructure réseau fictive conçue pour simuler le fonctionnement d'une entreprise. L'objectif de ce projet est de mettre en place une architecture réseau comprenant des services essentiels pour une entreprise moderne, tout en structurant le travail en sprints pour une gestion efficace du projet.

---

## Description du Projet

L’infrastructure BartInfo inclura les éléments suivants :

- **Serveur Active Directory (AD) sous Windows Server 2022** : Comprenant un contrôleur de domaine (DC) pour la gestion centralisée des utilisateurs, des ordinateurs et des politiques. Nom du DC : bartinfo.com.
- **pfSense** : Pour la gestion du pare-feu et du routage.
- **Serveur GLPI sous Debian** : Outil de gestion des tickets et inventaire, intégré à Active Directory.
- **Serveur de fichiers sous Windows Server** : Serveur Windows permettant de stocker les dossiers partagés.
- **Serveur de sauvegarde sous Debian** : Serveur destiné à la sauvegarde des dossiers partagés et du serveur AD sur des disques en RAID 1.
- **Clients** : Postes utilisateurs pour tester l’intégration des services.

L’infrastructure sera mise en place sur des VMs Proxmox.

---

## Organisation des Sprints

Voici une description synthétique des travaux réalisés pour chaque sprint dans le cadre de la mise en place de l'infrastructure.

### Sprint 1 : Mise en place des bases de l'infrastructure

- **Liste des serveurs nécessaires** : Analyse et définition des besoins serveurs effectuée (voir README initial).
- **Table de routage** : Table configurée et validée.
- **Configuration PfSense** : 
  - Installation de la VM PfSense.
  - Création des switchs et VLAN dans Proxmox.
- **Configuration DHCP** : Service DHCP configuré sur PfSense.
- **Installation de l’Active Directory (AD)** : Service AD installé et opérationnel.

### Sprint 2 : Gestion des utilisateurs et intégration GLPI

- **Utilisateurs et groupes** :
  - Scripts pour la création des OU et utilisateurs rédigés et exécutés.
- **Serveur DNS** : Paramétrage effectué avec succès.
- **Intégration GLPI** :
  - Installation et configuration de GLPI.
  - Intégration de GLPI au domaine Active Directory (DC).

### Sprint 3 : Documentation et gestion des fichiers

- **Documentation** : Rédaction de tutoriels et fiches complétés.
- **GLPI** : Importation des clients dans GLPI réalisée.
- **Serveur de fichiers** :
  - Installation de Windows Server sur une nouvelle VM.
  - Mise en place du service de partage de fichiers avec intégration au domaine.
  - Automatisation de la création de fichiers via scripts.

### Sprint 4 : Automatisation et déploiement

- **Agent GLPI** : Déploiement via GPO effectué sur les machines client.
- **Mappage automatique des dossiers** :
  - Mise en place du mappage des dossiers personnels (GPO simple).
  - Mappage des dossiers départementaux et services (via scripts).
- **Tests utilisateurs** :
  - Configuration et validation d’un client pour le DC.
  - Tests des utilisateurs pour les fichiers et GPO concluants.
- **Mise à jour de la documentation** : Documentation mise à jour sur GitHub.
- **Schéma logique** : Schéma logique de l’infrastructure validé.

### Sprint à venir : Mise en place d’un serveur de sauvegarde

- **Serveur de sauvegarde** : Mise en place d’un serveur de sauvegarde configuré en RAID 1.
- **Gestion des administrateurs** : Définition et configuration des rôles administrateurs.
- **Règles GPO** : Création et implémentation des règles GPO pour la gestion des utilisateurs.

---

## Tableau Récapitulatif des Sprints

| Sprint      | Objectifs Principaux                                         | Résultats Clés                                                                                  |
|-------------|-------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| **Sprint 1** | Mise en place des bases de l’infrastructure                  | Serveurs listés, table de routage configurée, PfSense et AD installés et configurés.             |
| **Sprint 2** | Gestion des utilisateurs et intégration de GLPI             | Utilisateurs et groupes créés, DNS configuré, GLPI intégré au domaine Active Directory.         |
| **Sprint 3** | Documentation et gestion des fichiers                       | Tutoriels rédigés, clients importés dans GLPI, serveur de fichiers installé et configuré.       |
| **Sprint 4** | Automatisation et tests utilisateurs                        | Agent GLPI déployé, mappage des dossiers configuré, tests utilisateurs validés, documentation et schéma logique mis à jour. |
| **Sprint à venir** | Mise en place d'un serveur de sauvegarde et GPO           | Serveur RAID 1 configuré, administrateurs définis, règles GPO implémentées.                       |

---

## Ressources Requises

- **Proxmox** : Pour l’hébergement des VM.
- **pfSense** : Pour la gestion du pare-feu.
- **Windows Server** : Pour l’installation de l’Active Directory.
- **Serveur GLPI** : Pour la gestion des actifs et des tickets.
- **Matériel client** : VMs pour les utilisateurs et postes physiques.

---

Ce fichier sera complété au fur et à mesure de l’avancement du projet.

