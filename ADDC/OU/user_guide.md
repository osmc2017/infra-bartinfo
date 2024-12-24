# Guide d'utilisation : Script de gestion des OUs dans Active Directory

## Introduction
Ce script PowerShell permet de créer automatiquement une structure hiérarchique d'Unités Organisationnelles (OUs) dans Active Directory (AD) à partir d'un fichier CSV. La structure créée est organisée comme suit :

- Une OU principale nommée **Departements**.
- Des OUs pour chaque **département** en tant que sous-OUs de **Departements**.
- Des OUs pour chaque **service**, créés sous leurs **départements respectifs**.

### Exemple de structure AD générée
```
OU=Departements,DC=bartinfo,DC=com
|
├── OU=Communication
│   └── (Pas de service)
|
├── OU=Direction Générale
│   └── (Pas de service)
|
├── OU=RH
│   ├── OU=Directeur RH
│   └── OU=Directeur-Adjoint RH
```

---

## Prérequis
### 1. Environnement requis
- Windows Server avec Active Directory installé.
- Module PowerShell **ActiveDirectory** disponible et importé.
- Droits d'administration sur Active Directory.

### 2. Fichier CSV
Le fichier CSV doit contenir au minimum deux colonnes :
- **Département** : Nom du département.
- **Service** : Nom du service (peut être vide ou contenir `-` si aucun service n'est présent).

#### Exemple de fichier CSV attendu :
```csv
Département,Service
Communication,-
Direction Générale,-
RH,Directeur RH
RH,Directeur-Adjoint RH
```

- Les départements et services doivent avoir des noms valides pour Active Directory (sans caractères spéciaux).

### 3. Chemin du fichier CSV
Le chemin du fichier CSV doit être défini correctement dans le script à la ligne suivante :
```powershell
$csvPath = "C:\Users\Administrator\Desktop\bartinfo.csv"
```
Adaptez ce chemin selon l’emplacement réel de votre fichier.

### 4. Donner les droits au script avec: 

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

### 5. Encodage du script: 

AINSI

---

## Fonctionnement du script

### 1. Chargement du module Active Directory
Le script commence par importer le module Active Directory nécessaire pour gérer les OUs :
```powershell
Import-Module ActiveDirectory
```

### 2. Lecture du fichier CSV
Le script charge le contenu du fichier CSV et filtre uniquement les colonnes **Département** et **Service** :
```powershell
$data = Import-Csv -Path $csvPath | Select-Object Département, Service
```

### 3. Création de l’OU principale
Une OU principale nommée **Departements** est créée si elle n'existe pas déjà :
```powershell
CreateOU -ouName "Departements" -parentPath "DC=bartinfo,DC=com"
```

### 4. Traitement des départements et services
Le script regroupe les entrées du fichier CSV par département et crée :
- Une OU pour chaque département sous l’OU principale **Departements**.
- Une OU pour chaque service valide sous son département parent.

#### Exemple de logique :
- Si `Département = "RH"` et `Service = "Directeur RH"` :
  - Créer OU `RH` sous `Departements`.
  - Créer OU `Directeur RH` sous `RH`.
- Si `Service = "-"` ou est vide :
  - Créer uniquement l’OU du département.

---

## Fonctions principales du script

### 1. Fonction `CreateOU`
Cette fonction crée une OU à un emplacement donné si elle n'existe pas déjà.
```powershell
function CreateOU {
    param (
        [string]$ouName,  # Nom de l'OU
        [string]$parentPath  # Chemin du conteneur parent
    )

    $ouDN = "OU=$ouName,$parentPath"

    if (-Not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouDN } -ErrorAction SilentlyContinue)) {
        try {
            New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ErrorAction Stop
            Write-Host "L'OU '$ouName' créée avec succès dans '$parentPath'."
        }
        catch {
            Write-Error "Erreur lors de la création de l'OU '$ouName'. Détails : $_"
        }
    } else {
        Write-Host "L'OU '$ouName' existe déjà dans '$parentPath'."
    }

    return $ouDN
}
```

### 2. Désactivation de la protection contre la suppression accidentelle
Toutes les OUs créées ont leur protection contre la suppression accidentelle désactivée pour permettre une gestion plus souple.

---

## Instructions pour exécuter le script

1. **Ouvrir PowerShell en tant qu’administrateur :**
   - Cliquez droit sur PowerShell et choisissez "Exécuter en tant qu’administrateur".

2. **Exécuter le script :**
   - Placez le fichier CSV à l'emplacement spécifié dans le script.
   - Modifiez le chemin du fichier CSV dans le script si nécessaire.
   - Exécutez le script dans la console PowerShell.

3. **Vérification des résultats :**
   - Ouvrez la console Active Directory Users and Computers (`dsa.msc`).
   - Naviguez jusqu'à **OU=Departements** pour voir les OUs créées.

---

## Messages affichés
Le script fournit des messages pour chaque étape :
- **Succès :**
  ```
  L'OU 'RH' créée avec succès dans 'OU=Departements,DC=bartinfo,DC=com'.
  ```
- **Déjà existant :**
  ```
  L'OU 'RH' existe déjà dans 'OU=Departements,DC=bartinfo,DC=com'.
  ```
- **Erreurs :**
  Les erreurs sont affichées en rouge avec des détails pour faciliter le diagnostic.

---

## Points de vigilance
- **Noms valides :** Les noms de départements et de services doivent respecter les restrictions de nommage d'Active Directory (pas de caractères interdits comme `/`, `\`, etc.).
- **Exécution en environnement de test :** Testez toujours le script dans un environnement de test avant de l'exécuter en production.

---

## Conclusion
Ce script automatise la création des OUs dans Active Directory en suivant une structure définie dans un fichier CSV. Il permet de gagner du temps tout en assurant une organisation cohérente et hiérarchique des Unités Organisationnelles.

