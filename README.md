# Projet d'infrastructure réseau fictive : BartInfo

Bienvenue dans le projet **BartInfo**, une infrastructure réseau fictive conçue pour simuler le fonctionnement d'une entreprise. L'objectif de ce projet est de mettre en place une architecture réseau comprenant des services essentiels pour une entreprise moderne, tout en structurant le travail en sprints pour une gestion efficace du projet.

## Description du projet

L’infrastructure BartInfo inclura les éléments suivants :

- **Serveur Active Directory (AD) sous Windows server 2022** : Comprenant un contrôleur de domaine (DC) pour la gestion centralisée des utilisateurs, des ordinateurs et des politiques. Nom du DC: bartinfo.com
- **pfSense** : Pour la gestion du pare-feu et du routage.
- **Serveur GLPI sous Debian** : Outil de gestion des tickets et inventaire, intégré à Active Directory.
- **Serveur de fichier sous Windows server** : Serveur windows qui permettra de stocker les dossiers partagés
- **Serveur de sauvegarde sous Debian** : Ce serveur sauvegardera les dossier partager et le serveur AD sur des disques en raid 1
- **Clients** 


L'infrastructure sera mise en place sur des Vms Proxmox.

## Objectifs du projet

1. **Formation et pratique** : Approfondir les compétences en infrastructure réseau et en gestion des services IT.
2. **Planification Agile** : Structurer le travail en sprints pour une gestion optimale.

## Etape dans l'ordre chronologique

- Installation et configuration de la Vm pfsense
- Installation et configuration de la Vm ADDC
  - Configuration du DNS
  - Mise en place des OU 
  - Mise en Place des Utilisateurs
  - Mise en place des groupes
- Installation et configuration de la Vm GLPI:
  - Integration à l'AD
  - Importation de la base données LDAP
- Installation et configuration du Serveur de fichier:
  - Intégration à l'AD
  - Utilisation des scripts pour la création des dossiers
- Mise en place des GPO:
  - GPO pour le mappage des dossiers partagés
  - GPO pour le déploiement de l'outils GLPI sur les clients
- Installation ett configuration de la Vm sauvegarde


## Ressources requises

- **Proxmox** : Pour l’hébergement des VM.
- **pfSense** : Pour la gestion du pare-feu.
- **Windows Server** : Pour l’installation de l’Active Directory.
- **Serveur GLPI** : Pour la gestion des actifs et des tickets.
- **Matériel client** : VMs pour les utilisateurs et postes physiques.

---
Ce fichier sera complété au fur et à mesure de l’avancement du projet. 
