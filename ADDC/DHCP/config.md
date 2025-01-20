## Configuration d'un serveur DHCP et DNS sur Active Directory avec pfSense en relais

Ce tutoriel détaille comment configurer votre serveur Active Directory (AD) `bartinfo.com` pour fournir les services DHCP et DNS sur plusieurs VLANs (10, 20 et 40) avec pfSense configuré comme relais DHCP.

### **1. Configuration de base du serveur DHCP sur le serveur AD**

1. **Installation du service DHCP sur le serveur AD :**
   - Ouvrez le **Gestionnaire de serveur**.
   - Cliquez sur **Ajouter des rôles et fonctionnalités**.
   - Ajoutez le rôle **DHCP Server** et terminez l'installation.

2. **Configuration des plages DHCP (une pour chaque VLAN) :**
   - Ouvrez **Gestionnaire DHCP**.
   - Faites un clic droit sur le serveur DHCP et sélectionnez **New Scope**.
   - Créez une portée pour chaque VLAN :

     - **VLAN 10** :
       - Plage d’adresses : `192.168.0.17 - 192.168.0.30`
       - Masque de sous-réseau : `255.255.255.240`
       - Passerelle par défaut : `192.168.0.17`
     - **VLAN 20** :
       - Plage d’adresses : `192.168.0.33 - 192.168.0.62`
       - Masque de sous-réseau : `255.255.255.224`
       - Passerelle par défaut : `192.168.0.33`
     - **VLAN 40** :
       - Plage d’adresses : `192.168.2.1 - 192.168.2.254`
       - Masque de sous-réseau : `255.255.255.0`
       - Passerelle par défaut : `192.168.2.1`

3. **Configurer les options DNS pour chaque étendue :**
   - Dans chaque portée, faites un clic droit sur **Options de l’étendue** > **Configurer les options**.
   - Configurez les options suivantes :
     - **Option 003 (Passerelle par défaut)** : Ajoutez l’IP de l’interface pfSense pour le VLAN.
     - **Option 006 (Serveurs DNS)** : Ajoutez l’IP du serveur AD (`192.168.0.2`).


4. **Autoriser le service DHCP sur le domaine :**
   - Exécutez la commande suivante sur le serveur AD pour l'autoriser :
     ```cmd
     netsh dhcp server authorize 192.168.0.2
     ```

---

### **2. Configuration DNS sur le serveur AD**

1. **Configurer les redirecteurs DNS :**
   - Ouvrez **DNS Manager**.
   - Faites un clic droit sur le serveur DNS > **Propriétés**.
   - Allez dans l’onglet **Redirecteurs**.
   - Ajoutez les serveurs DNS publics (ex. `8.8.8.8`, `8.8.4.4`).

2. **Tester la résolution DNS :**
   - Ouvrez une invite de commandes sur le serveur AD et testez une résolution de nom :
     ```cmd
     nslookup google.com
     ```

---

### **3. Configuration du relais DHCP dans pfSense**

1. **Activer le relais DHCP :**
   - Allez dans **Services > DHCP Relay**.
   - Activez l’option **Enable DHCP Relay**.
   - Configurez les paramètres suivants :
     - **Interfaces** : Sélectionnez les interfaces pour VLAN 10, VLAN 20, et VLAN 40.
     - **Serveur de destination** : `192.168.0.2` (adresse IP du serveur AD).

2. **Désactiver le serveur DHCP natif de pfSense :**
   - Allez dans **Services > DHCP Server**.
   - Désactivez le DHCP pour les interfaces VLAN concernées.

---

### **4. Configuration des règles de pare-feu dans pfSense**

#### **Règles pour les VLANs clients (10, 20, 40)**
1. Allez dans **Firewall > Rules**, puis sélectionnez l’interface de chaque VLAN (par ex., VLAN 10).
2. Ajoutez une règle pour autoriser les requêtes DHCP relayées :
   - **Action** : Pass
   - **Protocol** : UDP
   - **Source** : Any ou `192.168.x.0/24` (sous-réseau du VLAN concerné).
   - **Source Port** : Any
   - **Destination** : `192.168.0.2`
   - **Destination Port** : 67-68
   - **Description** : "Relais DHCP vers AD pour VLAN x".
3. Répétez cette configuration pour chaque VLAN (10, 20, 40).

#### **Règles pour le VLAN du serveur DHCP (VLAN 5)**
1. Allez dans **Firewall > Rules**, puis sélectionnez l’interface du VLAN 5.
2. Ajoutez une règle pour autoriser les réponses DHCP :
   - **Action** : Pass
   - **Protocol** : UDP
   - **Source** : `192.168.0.2`
   - **Source Port** : 67-68
   - **Destination** : Any ou les sous-réseaux des VLANs clients (`192.168.10.0/24`, `192.168.20.0/24`, etc.).
   - **Destination Port** : 68
   - **Description** : "Autoriser les réponses DHCP depuis le serveur AD".

---

### **5. Test final**

1. Connectez une machine à un VLAN client (10, 20 ou 40).
2. Configurez la machine pour obtenir une adresse IP via DHCP.
3. Exécutez les commandes suivantes pour tester la connectivité :
   - **Vérifiez l’adresse IP attribuée :**
     ```cmd
     ipconfig /all
     ```
   - **Testez la résolution DNS :**
     ```cmd
     nslookup google.com
     ```
   - **Testez l’accès Internet :**
     Essayez de naviguer sur un site web.



