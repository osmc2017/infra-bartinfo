# Tutoriel : Déploiement de l'agent GLPI sur Windows

## 1. Présentation

Ce tutoriel vous guide pour déployer l'agent GLPI sur des machines Windows afin de les inventorier dans GLPI.

L'agent GLPI (compatible GLPI 10) est basé sur FusionInventory et permet l'inventaire des ordinateurs, smartphones et tablettes (matériels, logiciels, etc.). Le serveur GLPI doit être opérationnel et accessible via HTTPS avant de commencer.

## 2. Systèmes compatibles

L'agent GLPI est compatible avec :
- **Windows** (32/64 bits)
- **macOS X** (Intel et Apple Silicon)
- **Linux** (Debian, Ubuntu, Red Hat, CentOS, etc.)
- **Android** (via l’application Google Play Store)

Les packages d'installation sont disponibles sur [GitHub](https://github.com/glpi-project/glpi-agent).

Dans ce tutoriel, nous allons déployer l'agent GLPI sur Windows avec une GPO.

## 3. Activer l'inventaire dans GLPI 11

1. Connectez-vous à l'interface d'administration de GLPI.
2. Naviguez vers : **Administrateur > Inventaire**.
3. Cochez : **Activer l’inventaire**.
4. Cliquez sur **Sauvegarder**.

![Capture d'écran 2024-12-30 104137](https://github.com/user-attachments/assets/a3acebce-dda8-4752-92ed-8bb597087beb)

Pour vérifier : Cliquez sur l'icône du robot dans GLPI. Si "Aucun élément trouvé" s'affiche, aucun agent n'est encore configuré.

## 4. Créer une GPO pour déployer l'agent GLPI

### A. Télécharger et partager le package MSI

1. Téléchargez le package MSI depuis [GitHub](https://github.com/glpi-project/glpi-agent).
2. Placez-le sur un partage réseau accessible par les machines du domaine.
   - Exemple : **P:\Applications** sur le serveur **SRV-ADDS-01**.
   - Partagez le répertoire avec les permissions suivantes :
     - **Ordinateurs du domaine** : Lecture seule
     - **Admins du domaine** : Contrôle total

### B. Installer l'agent GLPI par GPO

1. Ouvrez la console **Gestion de stratégie de groupe**.
2. Créez une nouvelle GPO (ex. : "Logiciel - Agent GLPI - Installer").
3. Liez cette GPO à l'OU contenant vos postes Windows (ex. : "PC").
4. Modifiez la GPO et accédez à :
   **Configuration ordinateur > Stratégies > Paramètres du logiciel > Installation de logiciel**.
5. Faites un clic droit, puis **Nouveau > Package**.
6. Indiquez le chemin UNC vers le package MSI :
   ```
   \\srv-adds-01\Applications$\GLPI-Agent-1.11-x64.msi
   ```
7. Choisissez "Attribué" comme type de déploiement et validez.

![Capture d'écran 2024-12-30 104232](https://github.com/user-attachments/assets/29082c17-1d99-413a-9523-cee5c8315b5f)

### C. Configurer l'agent GLPI avec le Registre Windows

1. Dans la même GPO, accédez à :
   **Configuration ordinateur > Préférences > Paramètres Windows > Registre**.
2. Créez deux nouvelles valeurs de Registre :

#### Valeur 1 : "server"
- **Action** : Mettre à jour
- **Ruche** : HKEY_LOCAL_MACHINE
- **Chemin** : SOFTWARE\GLPI-Agent
- **Nom** : server
- **Type** : REG_SZ
- **Données** : URL du serveur GLPI (ex. : `http://support.bartinfo.com/front/inventory.php`)

![Capture d'écran 2024-12-30 104300](https://github.com/user-attachments/assets/d2500314-2028-4f76-a452-1780473b06d3)

#### Valeur 2 : "tag"
- **Action** : Mettre à jour
- **Ruche** : HKEY_LOCAL_MACHINE
- **Chemin** : SOFTWARE\GLPI-Agent
- **Nom** : tag
- **Type** : REG_SZ
- **Données** : Nom de votre tag (ex. : "Parc Informatique")

![Capture d'écran 2024-12-30 104308](https://github.com/user-attachments/assets/e8bfe20e-9ac7-4548-80c8-5fcc4b1b0062)

![Capture d'écran 2024-12-30 104253](https://github.com/user-attachments/assets/1f61e3a5-bd4d-40be-91cb-301750f3518a)

3. Enregistrez la configuration.

### D. Tester la GPO

1. Appliquez les GPO sur une machine cible :
   ```
   gpupdate /force
   ```
2. Redémarrez la machine. L'agent GLPI doit être installé et visible dans les applications.
3. Accédez à l'interface de l'agent GLPI sur la machine :
   ```
   http://127.0.0.1:62354
   ```
4. Cliquez sur "Force an inventory" pour forcer un inventaire.
5. Vérifiez que la machine apparaît dans GLPI : **Parc > Ordinateurs**.

![Capture d'écran 2024-12-30 104346](https://github.com/user-attachments/assets/65d068ea-095c-4a70-9c48-32ce2dfc018f)

![Capture d'écran 2024-12-30 104410](https://github.com/user-attachments/assets/d64ed68f-2230-4db8-8eda-69cccb8c9598)

## 5. Conclusion

Ce tutoriel explique comment déployer et configurer l'agent GLPI 10 via GPO. Vous pouvez également ajuster les paramètres de configuration à l’avenir en modifiant les valeurs de Registre dans la GPO.

