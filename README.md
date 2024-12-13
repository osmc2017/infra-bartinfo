# Projet d'infrastructure réseau fictive : BartInfo

Bienvenue dans le projet **BartInfo**, une infrastructure réseau fictive conçue pour simuler le fonctionnement d'une entreprise. L'objectif de ce projet est de mettre en place une architecture réseau comprenant des services essentiels pour une entreprise moderne, tout en structurant le travail en sprints pour une gestion efficace du projet.

## Description du projet

L’infrastructure BartInfo inclura les éléments suivants :

- **Serveur Active Directory (AD)** : Comprenant un contrôleur de domaine (DC) pour la gestion centralisée des utilisateurs, des ordinateurs et des politiques.
- **pfSense** : Pour la gestion du pare-feu et du routage.
- **Serveur GLPI** : Outil de gestion des tickets et inventaire, intégré à Active Directory.
- **Clients** :
  - 10 utilisateurs organisés dans des Unités d’Organisation (3 UO).
  - 3 postes physiques (2 pour les clients et 1 pour l’administrateur).

L'infrastructure sera mise en place sur des Vms Proxmox.

## Objectifs du projet

1. **Formation et pratique** : Approfondir les compétences en infrastructure réseau et en gestion des services IT.
2. **Planification Agile** : Structurer le travail en sprints pour une gestion optimale.

## Planification des sprints

### Sprint 1 : Mise en place générale
- Créer la liste des serveurs et la table de routage.
- Installer la VM pfSense sur Proxmox.
- Configurer un switch virtuel avec des VLANs sur Proxmox.

### Sprint 2 : Installation et configuration de l'Active Directory
- Installer et configurer le serveur Active Directory avec un contrôleur de domaine.
- Créer et importer les utilisateurs dans l’AD.
- Configurer les Unités d’Organisation (3 UO).
- Définir et appliquer des règles de GPO.
- Configurer le serveur DHCP dans pfSense pour gérer les adresses IP dynamiques.

### Sprint 3 : Installation de GLPI et intégration
- Installer le serveur GLPI.
- Intégrer GLPI à l'Active Directory pour l’authentification.
- Déployer l’agent GLPI sur les machines clients (2 postes utilisateurs et 1 poste administrateur).

### Sprint 4 : À définir
Ce sprint sera réservé à l’optimisation, la mise en place d’outils supplémentaires, ou d’autres éléments en fonction des besoins identifiés au cours des sprints précédents.

## Ressources requises

- **Proxmox** : Pour l’hébergement des VM.
- **pfSense** : Pour la gestion du pare-feu.
- **Windows Server** : Pour l’installation de l’Active Directory.
- **Serveur GLPI** : Pour la gestion des actifs et des tickets.
- **Matériel client** : VMs pour les utilisateurs et postes physiques.

---
Ce fichier sera complété au fur et à mesure de l’avancement du projet. 
