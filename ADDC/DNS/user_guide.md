# Configuration des DNS sur un serveur Active Directory (AD)

Configurer correctement le service DNS sur un serveur AD est crucial pour le bon fonctionnement du domaine. **Lors de l'installation d'Active Directory et de la promotion en contrôleur de domaine (DC), le service DNS est configuré automatiquement.** Cependant, ce guide vous permet de vérifier cette configuration et d'ajouter des zones ou enregistrements supplémentaires si nécessaire, y compris une zone de recherche inversée (reverse lookup zone).

---

## Pré-requis
- Un serveur Windows avec Active Directory installé.
- Les rôles DNS installés (souvent configurés automatiquement avec l’installation d’Active Directory).
- Accès administrateur sur le serveur.

---

## Étapes de configuration

### 1. Vérifier l’installation automatique du DNS
1. Lors de l'installation d'Active Directory et de la promotion en contrôleur de domaine :
    - Le rôle DNS est installé automatiquement si non présent.
    - Une zone de recherche directe est créée automatiquement avec le même nom que votre domaine (ex. `test.lan`).
    - Les enregistrements DNS essentiels sont configurés, comme les enregistrements **SRV**, **A**, et **NS**.
    
2. Pour vérifier cette configuration :
    - Ouvrez le **Gestionnaire de serveur**.
    - Allez dans **Outils** > **DNS**.
    - Vérifiez que votre domaine est présent dans **Zones de recherche directe**.

Si vous devez personnaliser ou compléter cette configuration, suivez les étapes ci-dessous.

---

### 2. Créer une zone de recherche directe (Forward Lookup Zone)
1. Dans la console DNS, faites un clic droit sur **Zones de recherche directe** > **Nouvelle zone**.
2. Suivez l’assistant :
    - **Type de zone** : Sélectionnez **Zone principale**.
    - **Nom de la zone** : Entrez le nom de votre domaine (par ex. `test.lan`).
    - **Fichiers de zone** : Gardez les paramètres par défaut (ex. `test.lan.dns`).
    - **Mises à jour dynamiques** : Sélectionnez **Autoriser uniquement les mises à jour sécurisées** pour sécuriser les enregistrements DNS.
3. Terminez l’assistant.

### 3. Créer une zone de recherche inversée (Reverse Lookup Zone) *(Optionnelle)*
1. Faites un clic droit sur **Zones de recherche inversée** > **Nouvelle zone**.
2. Suivez l’assistant :
    - **Type de zone** : Sélectionnez **Zone principale**.
    - **ID réseau** : Entrez les trois premiers octets de votre sous-réseau IP (par exemple, pour `192.168.1.0/24`, entrez `192.168.1`).
    - **Fichiers de zone** : Gardez les paramètres par défaut.
    - **Mises à jour dynamiques** : Sélectionnez **Autoriser uniquement les mises à jour sécurisées**.
3. Terminez l’assistant.

### 4. Configurer les enregistrements DNS *(Optionnel)*

#### a. Ajouter des enregistrements A (Forward Lookup)
1. Dans **Zones de recherche directe**, faites un clic droit sur votre zone (ex. `test.lan`) > **Nouvel hôte (A ou AAAA)**.
2. Remplissez les champs :
    - **Nom** : Entrez le nom de l’hôte (par ex. `srv-ad`).
    - **Adresse IP** : Entrez l’adresse IP de l’hôte (par ex. `192.168.1.10`).
3. Cochez **Créer un pointeur PTR (si possible)** pour automatiquement créer l’enregistrement inversé.
4. Cliquez sur **Ajouter un hôte**.

#### b. Ajouter des enregistrements PTR (Reverse Lookup)
1. Si l’enregistrement PTR n’a pas été créé automatiquement, rendez-vous dans votre zone de recherche inversée.
2. Faites un clic droit > **Nouvel enregistrement de pointeur (PTR)**.
3. Remplissez les champs :
    - **Adresse IP** : Entrez l’adresse IP de l’hôte (par ex. `192.168.1.10`).
    - **Nom de l’hôte** : Entrez le nom complet de l’hôte (par ex. `srv-ad.test.lan`).
4. Cliquez sur **OK**.

### 5. Tester la configuration DNS *(Optionnel)*

#### a. Avec `nslookup`
1. Ouvrez une invite de commande sur un client ou le serveur.
2. Testez la résolution directe :
    ```cmd
    nslookup srv-ad.test.lan
    ```
3. Testez la résolution inversée :
    ```cmd
    nslookup 192.168.1.10
    ```

#### b. Vérifier la réplication (si plusieurs contrôleurs de domaine)
- Utilisez l’outil **Repadmin** :
    ```cmd
    repadmin /showrepl
    ```

---

## Conseils supplémentaires
- Activez l’intégration avec Active Directory lors de la création des zones pour sécuriser et simplifier la réplication DNS.
- Sur les clients, configurez le serveur DNS pour qu’il pointe vers l’adresse IP du contrôleur de domaine.
- Sur le serveur, vérifiez que le service DNS démarre automatiquement.

---

Vous avez maintenant un DNS fonctionnel et sécurisé pour votre environnement Active Directory !
