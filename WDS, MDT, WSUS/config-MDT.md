# Tutoriel : Installation et configuration de MDT pour Windows 11 24H2

## I. Installer Windows ADK pour Windows 11 24H2

#### Références pour résoudre cette erreur (si nécessaire) :
- [Microsoft Learn - Erreur WinPE (VBScript)](https://learn.microsoft.com)
- [DeploymentResearch Blog](https://deploymentresearch.com)

Si vous avez installé la dernière version de l'ADK et de l'add-on WinPE, désinstallez-les avant de réinstaller une version compatible.

### B. Installer Windows ADK

#### Étapes :
1. **Téléchargez** la version d'ADK compatible avec Windows 11 24H2 depuis le site officiel.
2. Lancez le fichier `adksetup.exe` et suivez l'assistant d'installation. Conservez l'emplacement par défaut.
3. Dans la liste des fonctionnalités, sélectionnez uniquement celles nécessaires pour MDT :
   - Outils de déploiement
   - Concepteur de fonctions d'acquisition d'image...
   - Concepteur de configuration
   - OUtils de migration utilisateur (USMT)

   > **Note :** L'installation nécessite environ 800 Mo d'espace disque.
4. Patientez jusqu'à la fin de l'installation et cliquez sur **Fermer**.

### C. Installer l'add-on Windows PE pour Windows 11 24H2

#### Étapes :
1. **Téléchargez** l'add-on Windows PE compatible avec Windows 11 24H2.
2. Lancez l'assistant d'installation. Cet add-on sera installé dans le même répertoire que Windows ADK.
3. Sélectionnez la fonctionnalité disponible et cliquez sur **Installer**.

Une fois l'installation terminée, passez à la configuration de MDT.

---

## II. Installer MDT sur Windows Server 2022

### A. Installer le composant MDT
1. **Téléchargez MDT** (Microsoft Deployment Toolkit) en version 64 bits depuis le site officiel.
2. Lancez l’installation avec les options par défaut. MDT peut être installé sur le disque `C:`, tandis que les données peuvent être stockées sur un autre volume.
3. À la fin de l’installation, un nouveau dossier **Microsoft Deployment Toolkit** est disponible dans le menu Démarrer. La console **Deployment Workbench** se trouve dans ce dossier.

### B. Créer le Deployment Share
1. Ouvrez la console **Deployment Workbench**.
2. Effectuez un clic droit sur **Deployment Shares** > **New Deployment Share**.
3. Indiquez l’emplacement du Deployment Share (ex. : `D:\DeploymentShare`). Ce dossier contiendra les données de MDT : images, pilotes, applications, etc.
4. Configurez les options selon vos besoins. Les paramètres peuvent être modifiés ultérieurement.
5. Patientez pendant la création du Deployment Share.
6. Une fois créé, vérifiez son contenu dans la console MDT ou dans l’Explorateur Windows.

---

## III. Créer un utilisateur dédié

On va créer un utilisateur dédié avec les droits nécessaires pour la connexion au du Deployment Share via ce script (pensez à adapter l'utilisateur et le mdp)

```powershell
# Spécifier le nom et le mot de passe du compte de service
$ServiceAccountName = "Service_MDT"
$ServiceAccountPassword = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force

# Créer le compte local
New-LocalUser $ServiceAccountName -Password $ServiceAccountPassword -FullName "MDT" -Description "Compte de service pour MDT"

# Ajouter les droits en lecture sur le partage
Grant-SmbShareAccess -Name "DeploymentShare$" -AccountName "Service_MDT" -AccessRight Read -Force

# Attribuer au compte de service les permissions nécessaires pour accéder aux fichiers de déploiement MDT
$MDTSharePath = "\\$env:COMPUTERNAME\DeploymentShare$"
$Acl = Get-Acl $MDTSharePath
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Service_MDT","ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Rule)
Set-Acl $MDTSharePath $Acl

```

On peut maintenant vérifier les droits de l'utilisateurs sur le doqssier DeploymentShare

---

## IV. Importer une image Windows 11 dans MDT

1. **Montez l’ISO de Windows 11 24H2** sur le serveur.
2. Dans MDT, effectuez un clic droit sur **Operating Systems** > **Import Operating System**.
3. Sélectionnez **Full set of source files** et indiquez le chemin vers l’ISO monté.
4. Nommez l’image, puis patientez pendant l’importation.
5. Une fois terminé, supprimez les éditions inutiles pour ne conserver que celles nécessaires (ex. : `Windows 11 Pro`).

---

## V. Créer une séquence de tâches pour Windows 11

1. Effectuez un clic droit sur **Task Sequences** > **New Folder** pour organiser vos tâches.
2. Créez une nouvelle séquence de tâches :
   - ID : Un identifiant unique (ex. : `INSTW11Pro24H2`).
   - Nom : `Déployer Windows 11 Pro 24H2`.
   - Modèle : **Standard Client Task Sequence**.
   - Image : Sélectionnez l’image importée précédemment.
3. Configurez les paramètres optionnels (clé produit, utilisateur Administrateur, mot de passe, etc.).
4. Finalisez et éditez les propriétés pour personnaliser les étapes si nécessaire:
    * ex update: L'onglet le plus intéressant s'appelle "Task Sequence" : il contient l'ensemble des tâches qui seront exécutées pendant le déploiement de la machine. Cela va du partitionnement du disque de la machine, à la configuration post-installation du système d'exploitation (pour installer des applications par exemple). Chaque tâche peut être activée ou désactivée, et si une tâche est considérée comme critique, on peut dire à l'assistant d'arrêter le déploiement si elle échoue. On peut créer, modifier et supprimer des tâches.

    Par exemple, il est possible d'activer la tâche "Windows Update (Post-Application Installation)" pour mettre à jour la machine (Windows et applications Microsoft) après l'installation éventuelle d'applications. Ainsi, une fois que la machine terminera son déploiement, elle sera entièrement à jour. Pour activer cette tâche actuellement désactivée, il faut cliquer dessus et sur la droite cliquer sur "Options" et décocher la case "Disable this step". La case "Continue on error" doit être cochée pour que le déploiement se poursuive même si cette tâche échoue.

---

## VII. Configurer MDT pour Windows 11 (et éviter des problèmes)

Pour déployer Windows 11 avec MDT, il y a quelques ajustements à effectuer dans la configuration de MDT, sinon c'est l'échec assuré... Car vous êtes susceptibles de rencontrer plusieurs erreurs bloquantes.

### A. Bug de la console MMC avec l'onglet Windows PE

Tout d'abord, lorsque l'on accède aux propriétés du Deployment Share (via un clic droit sur le Deployment Share) et que l'on clique sur l'onglet "Windows PE", on obtient l'erreur "La console MMC a détecté une erreur dans un composant logiciel enfichable et va le décharger".Pour résoudre cette erreur, et comme le x86 est actif par défaut, il faut créer cette structure de dossiers vide :

```Powershell

mkdir "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs"

```

En plus, dans les propriétés du Deployment Share, il faut décocher le support du x86 (32 bits) dans l'onglet General.

### B. Lancement d'une tâche : Script Error
Autre problématique que vous pouvez rencontrer par la suite, l'erreur Script Error avec le texte "An error has occured in the script on this page" au moment de lancer un déploiement (ou une capture) sur une machine.

Pour corriger cette erreur, Microsoft vous demande de modifier le fichier "Unatted_PE_x64.xml" situé par défaut dans : C:\Program Files\Microsoft Deployment Toolkit\Templates

L'idée est de supprimer le contenu de ce fichier pour mettre un nouveau contenu à la place. Le contenu à intégrer est indiqué sur le site de Microsoft, à [cet endroit](https://learn.microsoft.com/en-us/mem/configmgr/mdt/known-issues?WT.mc_id=AZ-MVP-5004580#hta-applications-report-script-error-after-upgrading-to-adk-for-windows-11-version-22h2?WT.mc_id=AZ-MVP-5004580). 

## VII. Configurer MDT pour Windows 11 24H2

### A. Modifier les fichiers Bootstrap.ini et CustomSettings.ini

Pour accéder au contenu du fichier "CustomSettings.ini", effectuez un clic droit sur le Deployment Share via la console MDT et cliquez sur "Propriétés". Cliquez sur l'onglet "Rules".

1. **Bootstrap.ini** :
   ```ini
   [Settings]
   Priority=Default

   [Default]
   DeployRoot=\\SRV-WDS\DeploymentShare$
   UserID=Service_MDT
   UserPassword=Azerty1*
   UserDomain=SRV-WDS
   SkipBDDWelcome=YES
   KeyboardLocalePE=040c:0000040c
   ```
2. **CustomSettings.ini** :
   ```ini
   [Settings]
   Priority=Default
   Properties=MyCustomProperty

   [Default]
   OSInstall=Y
   SkipCapture=NO
   SkipAdminPassword=YES
   SkipProductKey=YES
   SkipComputerBackup=NO
   SkipBitLocker=NO

   _SMSTSORGNAME=bartinfo.com
   TimeZone=105
   TimeZoneName=Romance Standard Time
   ```
3. Enregistrez les modifications.

---

## IX. Générer l'image Lite Touch
1. Dans MDT, effectuez un clic droit sur le Deployment Share > **Update Deployment Share**.
2. Sélectionnez l’option par défaut pour optimiser la mise à jour.
3. Patientez pendant la génération de l’image Lite Touch.

### Importer l'image dans WDS
1. Dans WDS, ajoutez l’image générée : `W:\DeploymentShare\Boot\LiteTouchPE_x64.wim`.
2. Vérifiez que l’image est en ligne.

---

## X. Déployer Windows 11 24H2 avec MDT
1. Démarrez une machine en mode PXE.
2. Chargez l’image Lite Touch Windows PE.
3. Suivez l’assistant pour sélectionner la séquence de tâches et les paramètres de déploiement.
4. Patientez pendant le déploiement. MDT enchaînera toutes les étapes configurées, y compris les mises à jour post-installation.

---
