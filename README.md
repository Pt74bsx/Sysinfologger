<div align="center">

# 🖥️ SysInfoLogger

### Collecte et journalisation d'informations système avec PowerShell

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Administration](https://img.shields.io/badge/administration-système-blue?style=for-the-badge)

</div>

## 📖 Présentation

**SysInfoLogger** est un script PowerShell qui collecte les principales informations d'une machine Windows, les affiche de manière lisible et les enregistre dans un fichier journal.

Le script peut analyser l'ordinateur local ou tenter d'interroger une machine distante à partir d'une adresse IP. Il a été développé dans le cadre d'un projet ETML consacré à l'automatisation et à l'administration système.

## ✨ Informations collectées

Selon la machine et les droits disponibles, le script récupère notamment :

- nom de l'ordinateur ;
- configuration réseau et adresses IP ;
- système d'exploitation ;
- processeur ;
- carte graphique ;
- mémoire vive totale, utilisée et disponible ;
- disques logiques ;
- langues du système ;
- programmes installés ;
- date et heure de la collecte.

Les résultats sont écrits dans un fichier `sysloginfo.log` placé à côté du script.

## 🌐 Analyse locale ou distante

### Machine locale

Sans paramètre, le script utilise les commandes PowerShell et CIM disponibles sur l'ordinateur courant.

```powershell
.\Romain-Theo-Get-SystemInfoLogger.ps1
```

### Machine distante

Le paramètre `-IPAddress` permet de cibler une autre machine :

```powershell
.\Romain-Theo-Get-SystemInfoLogger.ps1 -IPAddress 192.168.1.20
```

L'exécution distante dépend de la configuration PowerShell Remoting, de WinRM, du réseau et des autorisations sur la machine cible.

## ✅ Prérequis

- Windows ;
- PowerShell ;
- session exécutée avec des droits administrateur ;
- stratégie d'exécution autorisant le script ;
- pour une machine distante : connectivité réseau, WinRM/PowerShell Remoting configuré et identifiants autorisés.

## 🚀 Installation

1. Clone le dépôt :

   ```powershell
   git clone https://github.com/Pt74bsx/Sysinfologger.git
   cd Sysinfologger\scripts
   ```

2. Ouvre PowerShell **en tant qu'administrateur**.
3. Consulte la stratégie d'exécution :

   ```powershell
   Get-ExecutionPolicy
   ```

4. Lance le script localement ou avec le paramètre `-IPAddress`.

> Ne réduis pas durablement les protections PowerShell uniquement pour exécuter ce projet. Utilise une politique adaptée à ton environnement et vérifie toujours le contenu d'un script avant son lancement.

## 🗂️ Structure du dépôt

```text
Sysinfologger/
├── scripts/
│   └── Romain-Theo-Get-SystemInfoLogger.ps1
├── doc/
│   ├── rapport du projet
│   ├── journal de travail
│   └── diagramme d'analyse
└── README.md
```

## ⚙️ Fonctionnement

Le script suit les grandes étapes suivantes :

1. validation des droits administrateur ;
2. lecture du paramètre d'adresse IP ;
3. création des sessions nécessaires pour une cible distante ;
4. collecte des informations avec les commandes système et CIM ;
5. calcul de certaines valeurs, notamment l'utilisation de la RAM ;
6. formatage des lignes de sortie ;
7. affichage dans la console ;
8. ajout des informations au fichier journal ;
9. fermeture propre des sessions distantes.

## 🧱 Organisation du script

- `Write-Log` centralise l'écriture dans le journal ;
- `Line` aligne les libellés et les valeurs ;
- `Get-MachineInfo` collecte les informations locales ou distantes ;
- les variables de script partagent les résultats entre les étapes ;
- la section principale contrôle les permissions et orchestre l'exécution.

## 🔐 Sécurité

L'administration distante comporte des risques. Avant utilisation :

- exécute le script uniquement sur des machines que tu es autorisé à administrer ;
- évite d'enregistrer des identifiants dans le code ou le dépôt ;
- protège le fichier journal, qui peut contenir des informations sensibles ;
- limite les règles WinRM aux hôtes nécessaires ;
- vérifie les paramètres réseau et les listes d'hôtes de confiance ;
- supprime ou anonymise les journaux avant de les partager.

## 🧠 Compétences travaillées

- scripting PowerShell ;
- administration Windows ;
- requêtes CIM ;
- PowerShell Remoting ;
- paramètres de script ;
- contrôle des permissions ;
- gestion de fichiers journaux ;
- formatage des sorties ;
- travail collaboratif et documentation technique.

## ⚠️ Limites actuelles

- fonctionnement principalement prévu pour Windows ;
- besoin de privilèges élevés ;
- dépendance à la configuration des machines distantes ;
- volume potentiellement important de données pour la liste des logiciels ;
- absence de tests automatisés ;
- journal texte sans rotation ni politique de rétention.

## 🔭 Améliorations possibles

- exporter également en JSON ou CSV ;
- ajouter une rotation des journaux ;
- permettre de choisir les catégories collectées ;
- améliorer la gestion détaillée des erreurs ;
- produire un rapport HTML ;
- prendre en charge plusieurs machines en une seule commande ;
- ajouter des tests avec Pester ;
- signer numériquement le script.

## 📚 Documentation

Le dossier `doc` contient le rapport, le journal de travail et le diagramme d'analyse du projet.

## 👥 Auteurs

- [Romain-Augusto](https://github.com/Pt74bsx)
- Théo Tessari

## 📄 Licence

Le code source original est distribué sous licence MIT au nom des deux auteurs. Consulte le fichier [LICENSE](LICENSE).

---

Projet réalisé dans le cadre de la formation à l'ETML.
