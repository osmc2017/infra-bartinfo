# Configuration et installation Vlan avec proxmox et pfsense

## Configuration de Proxmox

En premier lieu nous avons configuré Proxmox et une carte réseau afin d'avoir un switch virtuel et ainsi nous permetre de configurer des Vlans à l'aide Pfsense. Pour cela nous avons suivi un tutoriel disponible en cliquant [ici](https://github.com/osmc2017/Tutos-et-Scripts-Apprenti-Technicien-Systeme-et-Reseau/blob/4add6ff69f184d02c771d787aa25b2210a56234c/TUTO/Tuto_Proxmox/Config_Vlans_PfSense.md)

* Pour l'exercice nous avons créé les vlans suivant:
    - Vlan 5 pour le DC
    - Vlan 10 pour les administrateurs réseaux
    - Vlan 20 pour les serveurs
    - Vlan 40 pour les utilisateurs classiques

* Identifiant et mdp de pfsense
**ID** : admin
**MDP** : Azerty1*
---

## Installation et configuration réseau de la Vm pfsense 

Nous avons ensuite installé et configurer une Vm pfsense en utilisant les réglages réseaux suivant:

    - Dans proxmox

(add image)

    - Dans pfsense

(ajouter capture differente carte réseau dans pfsense)

    * La première interface wan nous permet d'avoir accés à internet 

    * L'interface réseau LAn vmbr1 nous permet d'avoir ccés à la configuration de pfsense via une machine extérieur à nos Vlan.

    * L'interface em0 (Switchvlan dans proxmox) représente notre switch et nous permet ensuite de paramétrer nos Vlans

---

## Configuration des vlans dans pfsense

Pour configurer les vlans nous avons procédé de la façon suivante

(img1 2 3 4)
 a rediger
