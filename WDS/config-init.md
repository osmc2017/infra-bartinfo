## Installation et configuration initiale de WDS (Windows Deployment Services)

### **1. Prérequis**
- Un serveur Windows avec le rôle ADDS et DHCP configuré.
- Une partition NTFS disponible pour stocker les images d'installation.
- Accès à une image Windows (ISO ou fichier d'installation).

---

### **2. Installation du rôle WDS**

1. **Ouvrir le Gestionnaire de serveur :**
   - Cliquez sur **Gérer** > **Ajouter des rôles et fonctionnalités**.

2. **Démarrer l’assistant :**
   - Sélectionnez **Installation basée sur un rôle ou une fonctionnalité**.
   - Cliquez sur **Suivant**.

3. **Sélection du serveur :**
   - Choisissez votre serveur dans la liste.

4. **Ajout du rôle WDS :**
   - Sélectionnez **Services de déploiement Windows**.
   - Cliquez sur **Ajouter des fonctionnalités** lorsque demandé.

5. **Configurer les services WDS :**
   - Sélectionnez les deux rôles suivants :
     - **Serveur de déploiement**
     - **Serveur de transport**
   - Cliquez sur **Suivant** et terminez l'installation.

---

### **3. Configuration initiale de WDS**

1. **Ouvrir le gestionnaire WDS :**
   - Allez dans **Outils** > **Services de déploiement Windows**.

2. **Configurer le serveur WDS :**
   - Faites un clic droit sur le serveur > **Configurer le serveur**.

3. **Sélectionner si intégrer à l'AD**

4. **Sélectionner l’emplacement de stockage :**
   - Choisissez un emplacement NTFS pour le dossier de répertoire distant (exemple : `D:\RemoteInstall`).

5. **Choisir à quel ordinateur client répondre**

6. **décocher l'option ajouter image immédiatement**

7. **Terminer la configuration :**
   - Le serveur WDS est maintenant prêt à être utilisé.

---

### **4. Ajout d’images d’installation**

1. **Ajouter une image de boot :**
   - Dans le gestionnaire WDS, faites un clic droit sur **Images de démarrage** > **Ajouter une image de démarrage**.
   - Parcourez jusqu’au fichier `sources\boot.wim` de votre image Windows.

2. **Ajouter une image d'installation :**
   - Faites un clic droit sur **Images d'installation** > **Ajouter un groupe d'images**.
   - Ajoutez les fichiers `sources\install.wim` correspondant à votre image Windows.

---

### **5. Test du déploiement**

1. **Configurer un client PXE :**
   - Configurez un poste client pour démarrer via le réseau (Boot PXE).

2. **Démarrage du déploiement :**
   - Le client devrait obtenir une adresse IP via DHCP et accéder au serveur WDS pour démarrer l'installation Windows.

---

### **5. WDS : Boot PXE en mode UEFI (et BIOS)**

Pour permettre aux clients PXE de booter en mode UEFI ou BIOS, le serveur DHCP doit être configuré pour utiliser les options DHCP suivantes :

- **Option 60** : Permet de déclarer le client PXE.
- **Option 66** : Spécifie l’adresse IP du serveur WDS.
- **Option 67** : Définit le fichier de boot approprié (différent pour UEFI et BIOS).

Dans la liste des options DHCP, l'option 60 n'est pas disponible dans la liste. À l'aide de PowerShell, nous allons pouvoir remédier à cela avec cette commande:
```powershell
Add-DhcpServerv4OptionDefinition -ComputerName SRV-ADDS-01 -Name PXEClient -Description "PXE Support" -OptionId 060 -Type String
```

Nous allons configurer cela en regroupant les étapes dans un script PowerShell.

#### **Script PowerShell : Configuration des classes de fournisseurs et des stratégies DHCP**

Voici un script PowerShell complet pour déclarer les classes de fournisseurs et créer les stratégies associées :

```powershell
# Variables principales
$DhcpServerName = "SERVER-DC"              # Serveur DHCP
$PxeServerIp = "192.168.0.2"               # Adresse IP du serveur WDS (SERVER-WDS)
$Scope = "192.168.14.0"                    # Plage DHCP

# 1. Ajouter les classes de fournisseurs
Add-DhcpServerv4Class -ComputerName $DhcpServerName -Name "PXEClient - UEFI x64" -Type Vendor -Data "PXEClient:Arch:00007" -Description "PXEClient:Arch:00007"
Add-DhcpServerv4Class -ComputerName $DhcpServerName -Name "PXEClient - UEFI x86" -Type Vendor -Data "PXEClient:Arch:00006" -Description "PXEClient:Arch:00006"
Add-DhcpServerv4Class -ComputerName $DhcpServerName -Name "PXEClient - BIOS x86 et x64" -Type Vendor -Data "PXEClient:Arch:00000" -Description "PXEClient:Arch:00000"

# 2. Créer les stratégies DHCP
# Stratégie pour le mode BIOS
$PolicyNameBIOS = "PXEClient - BIOS x86 et x64"
Add-DhcpServerv4Policy -Computername $DhcpServerName -ScopeId $Scope -Name $PolicyNameBIOS -Description "Options DHCP pour boot BIOS x86 et x64" -Condition Or -VendorClass EQ, "PXEClient - BIOS x86 et x64*"
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 066 -Value $PxeServerIp -PolicyName $PolicyNameBIOS
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 067 -Value boot\x64\wdsnbp.com -PolicyName $PolicyNameBIOS

# Stratégie pour le mode UEFI x86
$PolicyNameUEFIx86 = "PXEClient - UEFI x86"
Add-DhcpServerv4Policy -Computername $DhcpServerName -ScopeId $Scope -Name $PolicyNameUEFIx86 -Description "Options DHCP pour boot UEFI x86" -Condition Or -VendorClass EQ, "PXEClient - UEFI x86*"
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 060 -Value PXEClient -PolicyName $PolicyNameUEFIx86
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 066 -Value $PxeServerIp -PolicyName $PolicyNameUEFIx86
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 067 -Value boot\x86\wdsmgfw.efi -PolicyName $PolicyNameUEFIx86

# Stratégie pour le mode UEFI x64
$PolicyNameUEFIx64 = "PXEClient - UEFI x64"
Add-DhcpServerv4Policy -Computername $DhcpServerName -ScopeId $Scope -Name $PolicyNameUEFIx64 -Description "Options DHCP pour boot UEFI x64" -Condition Or -VendorClass EQ, "PXEClient - UEFI x64*"
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 060 -Value PXEClient -PolicyName $PolicyNameUEFIx64
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 066 -Value $PxeServerIp -PolicyName $PolicyNameUEFIx64
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 067 -Value boot\x64\wdsmgfw.efi -PolicyName $PolicyNameUEFIx64
```

#### **Explication des modules :**

1. **Add-DhcpServerv4Class** :
   - Permet de déclarer des classes de fournisseurs pour différencier les clients PXE en fonction de leur architecture (BIOS ou UEFI).

2. **Add-DhcpServerv4Policy** :
   - Crée des stratégies basées sur les classes de fournisseurs afin d’appliquer des options DHCP spécifiques.

3. **Set-DhcpServerv4OptionValue** :
   - Configure les options DHCP (60, 66, et 67) pour chaque stratégie.
     - **Option 60** : Déclare le client PXE.
     - **Option 66** : Définit l’IP du serveur WDS.
     - **Option 67** : Spécifie le fichier de boot approprié (différent pour UEFI et BIOS).

Avec ce script, le serveur DHCP (SERVER-DC) et le serveur WDS (SERVER-WDS) sont configurés pour gérer les boots PXE en mode UEFI et BIOS.

