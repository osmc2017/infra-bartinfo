# Tutoriel : Configurer l'accès à Internet pour un VLAN sur pfSense (ex: Vlan 05)

Ce tutoriel explique comment configurer un VLAN numéroté **5** sur pfSense, avec l'interface appelée `vlan05`. Le VLAN utilisera le réseau **192.168.0.0/30** et permettra aux clients du VLAN d'accéder à Internet.

---

## Étapes de configuration

### 1. Création et configuration du VLAN

1. Accédez à **Interfaces > Assignments > VLANs**.
2. Cliquez sur **Add** pour créer un nouveau VLAN :
   - **Parent Interface** : Choisissez l'interface physique connectée au switch ou au réseau du VLAN.
   - **VLAN Tag** : `5` (numéro de votre VLAN).
   - **Description** : `vlan05`.
3. Cliquez sur **Save** puis **Apply Changes**.

---

### 2. Assigner l'interface du VLAN

1. Accédez à **Interfaces > Assignments**.
2. Dans la section **Available Network Ports**, sélectionnez le VLAN créé (par exemple, `VLAN 5 on [Parent Interface]`) et cliquez sur **Add**.
3. Dans la liste des interfaces, éditez la nouvelle interface ajoutée :
   - **Enable Interface** : Cochez la case.
   - **Interface Name** : Renommez en `vlan05`.
   - **IPv4 Configuration Type** : Static IPv4.
   - **IPv4 Address** : `192.168.0.1/30`.
   - Cliquez sur **Save** puis **Apply Changes**.

---

### 3. Configuration du DHCP (optionnel)

Si vous souhaitez que les clients reçoivent une adresse IP dynamique :

1. Accédez à **Services > DHCP Server**.
2. Sélectionnez `vlan05` dans la liste des interfaces.
3. Activez le serveur DHCP pour cette interface :
   - **Range** : Saisissez une plage d'adresses IP (par exemple, `192.168.0.2` à `192.168.0.2`, car le réseau est très petit).
   - **Gateway** : `192.168.0.1`.
4. Cliquez sur **Save**.

---

### 4. Configuration des règles de pare-feu

Pour permettre l'accès à Internet :

1. Accédez à **Firewall > Rules**.
2. Cliquez sur l'onglet correspondant à `vlan05`.
3. Ajoutez une nouvelle règle :
   - **Action** : Pass
   - **Interface** : vlan05
   - **Protocol** : Any
   - **Source** : `vlan05 net`
   - **Destination** : Any
   - **Description** : "Autoriser l'accès à Internet pour vlan05"
4. Cliquez sur **Save** puis **Apply Changes**.

---

### 5. Configuration du NAT (Network Address Translation)

Pour autoriser le trafic Internet, le NAT doit être configuré :

1. Accédez à **Firewall > NAT > Outbound**.
2. Si le NAT est en mode "Automatic Outbound NAT rule generation", vous n'avez rien à faire.
3. Si le NAT est en mode "Manual Outbound NAT rule generation" :
   - Cliquez sur **Add** pour ajouter une règle.
   - **Interface** : WAN
   - **Source** : `192.168.0.0/30`
   - **Destination** : Any
   - Cliquez sur **Save** puis **Apply Changes**.

---

### 6. Configuration des clients

Pour les clients du VLAN, configurez leur adresse IP de cette manière :

1. **Adresse IP** : `192.168.0.2`
2. **Masque de sous-réseau** : `255.255.255.252` (/30)
3. **Passerelle** : `192.168.0.1`
4. **DNS** : `192.168.0.1` ou une adresse DNS publique (par exemple, `8.8.8.8`).

---

### 7. Test de la connectivité

1. Connectez un client au VLAN.
2. Effectuez les tests suivants :
   - Ping vers `192.168.0.1` (passerelle).
   - Ping vers `8.8.8.8` (adresse Internet).
   - Test DNS en accédant à un site web.

Si tout est correctement configuré, le client du VLAN `vlan05` aura accès à Internet.

---

## Récapitulatif

- VLAN ID : 5
- Réseau : 192.168.0.0/30
- Passerelle : 192.168.0.1
- Interface : vlan05

Vous avez maintenant un VLAN fonctionnel avec accès à Internet !

