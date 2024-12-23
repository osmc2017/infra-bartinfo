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

![Capture d'écran 2024-12-23 115116](https://github.com/user-attachments/assets/f89210cd-94c8-4d8b-bd4a-50e972a1bca0)

    - Dans pfsense

![Capture d'écran 2024-12-23 115156](https://github.com/user-attachments/assets/de82e9a9-a4f1-4823-9f98-f0bc3ac4d242)


    * La première interface wan nous permet d'avoir accés à internet 

    * L'interface réseau LAn vmbr1 nous permet d'avoir ccés à la configuration de pfsense via une machine extérieur à nos Vlan.

    * L'interface em0 (Switchvlan dans proxmox) représente notre switch et nous permet ensuite de paramétrer nos Vlans

---

## Configuration des vlans dans pfsense

Pour configurer les vlans nous avons procédé de la façon suivante

- On ajoute une interface vlan et on la configure
- 
![Capture d'écran 2024-12-23 113918](https://github.com/user-attachments/assets/6b380dc1-4251-4370-bc5b-b84e7d144c36)
![Capture d'écran 2024-12-23 113927](https://github.com/user-attachments/assets/375dde0e-aa9e-42c4-a60d-7ffbe3370a32)

- Il faut ensuite assigner l'interface ajouté

![Capture d'écran 2024-12-23 113940](https://github.com/user-attachments/assets/016bada7-4ab1-48f9-94c4-46e1db3cd968)

- Ensuite il faut activer et configurer le nouveau vlan

![Capture d'écran 2024-12-23 114043](https://github.com/user-attachments/assets/a347ef05-fe24-4116-a449-de45c3aca6e2)

![Capture d'écran 2024-12-23 114101](https://github.com/user-attachments/assets/a1393d30-2ef1-4a68-846c-0d0c89da281f)

![Capture d'écran 2024-12-23 114133](https://github.com/user-attachments/assets/6834bc13-54c5-4165-a730-5af032b047b5)

![Capture d'écran 2024-12-23 114144](https://github.com/user-attachments/assets/f1fa978c-bf58-4e8f-8475-ef61220f8015)

![Capture d'écran 2024-12-23 114156](https://github.com/user-attachments/assets/02cc61a9-7479-44b2-b66d-d7a270af87f3)

- Si besoin on active le service DHCP pour le vlan

![Capture d'écran 2024-12-23 114231](https://github.com/user-attachments/assets/a5739eab-8f8c-4af3-b1c8-3d35ae48b3ac)

![Capture d'écran 2024-12-23 114244](https://github.com/user-attachments/assets/e61d2301-846d-479d-84b3-e3ba5f6e3317)


