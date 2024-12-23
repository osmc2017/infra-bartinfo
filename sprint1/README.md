# sprint 1


Dans ce sprint on va mettre en place les bases de notre infrastructure:

- Liste des serveurs nécessaires OK voir readme initiale
- Table de routage OK
- Mise en place de la Vm PfSense et création switch + Vlan (dans proxmox) OK
- configurer dhcp pfsense ok 
- installer l'AD 


Point du sprint 1:

Aujourd'hui nous avons mit en place le routeur pfsense ainsi que toutes les règles de firewall nécessaire. Les Vlans ont été créé.

Le Serveur DC avec le service a été installé avec ce [tutoriel](mettre le lien)

Le serveur GLPI est installé via ce [script](rajouter le lien).

Tout fonctionne correctement:
- les vlans peuvent communiquer ensemble,
- le serveur DC a bien internet et est isolé dans un vlan seul
- le serveur GLPI est bien en IP fix (192.168.0.35) et il peut être contacter par un utilisateur du vlan 40.
- les règles de pare feu mises en place respectent le tiering.
- la table de routage a été mise en place

Pour le sprint 2:

- Configurer et intégrer le serveur GLPI au DC;
- Créer les utilisateurs (dont un admin) et les groupes dans le DC
- Configurer un client pour le DC et tester des utilisateurs
- Installer windows server sur une nouvelle machine en vue d'une mise en place d'un serveur de fichier.
- Si possible parametrer le serveur DNS.