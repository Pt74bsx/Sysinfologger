<#
.NOTES
    —————————————————————————————————————————————————————————————————————————————
    ETML
    Nom du script:	P_SysLogger.ps1
    Auteur:	Romain Augusto && Théo Tessari
    Date:	24.04.2026
 	—————————————————————————————————————————————————————————————————————————————
    Modifications
 	Date  : -
 	Auteur: -
 	Raisons: -
 	—————————————————————————————————————————————————————————————————————————————
.SYNOPSIS
	Collecter des informations système à partir de l'ordinateur local ou d'une machine distante pour enregistrer ces informations dans un fichier journal (log).
 	
.DESCRIPTION
    Collecter des informations système à partir de l'ordinateur local ou d'une machine distante pour enregistrer ces informations dans un fichier journal (log).
  	
.PARAMETER IPAddress
    Paramètre optionnel qui sert à fournir une ip pour que le script puisse se connecter à cette IP.

.OUTPUTS
	Retourne des informations système à partir de l'ordinateur local ou d'une machine distante.
	
.EXAMPLE
	.\Romain-Write-Numbers.ps1 -IPAddress  172.28.128.1
	Résultat : 
	
.EXAMPLE
	.\P_SysLogger.ps1
	Résultat : Le script nous donne plain d'informations sur notre machine, puis le script stock tout dans un fichier de log.
#>

# ———— DÉFINITION DES PARAMÈTRES ——————————————————————————————————————————————————————————————————————————————————————————————
param(
    [System.Net.IPAddress]$IPAddress    # ———— Récupérer une IP
)

# ———— DÉFINITION DES VARIABLES ET FONCTIONS ——————————————————————————————————————————————————————————————————————————————————————————————
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8                        # ———— Encodage UTF-8

# ———— UTILISATEUR / PERMISSIONS ————————————————
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()               # ———— Récupère les informations de l'utilisateur
$principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)     # ———— Vérifie le rôle de l'utilisateur 

# ———— FICHIER DE LOG ————————————————
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "sysloginfo.log"

# ———— ÉCRIRE DES LOGS ————————————————
function Write-Log ([string]$text) {
    $text | Out-File -FilePath $script:logFile -Append -Encoding UTF8
}

# ———— ALLIGNER DES VALEURS ————————————————
function Line ($Label, $Value) {
    $Label = $Label.Trim()                  # ———— Supprime les espaces, tabulations et retours à la ligne
    $width = 14
    "{0,-$width}: {1}" -f $Label, $Value
}

# ———— RÉCUPÉRATION DES INFORMATIONS ————————————————
function Get-MachineInfo ($IPAddress) {
    if ($IPAddress) {
        # ———— MACHINE DISTANTE ————————————————
        $script:hostname = Invoke-Command -Session $script:session -ScriptBlock { $env:COMPUTERNAME }                                                   # ———— Nom 
        $script:ipLocal = Invoke-Command -Session $script:session -ScriptBlock { Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null } }   # ———— Réseau
        $script:os = Get-CimInstance -CimSession $script:cimSession -ClassName CIM_OperatingSystem                                                      # ———— OS
        $script:cpu = Get-CimInstance -CimSession $script:cimSession -ClassName CIM_Processor                                                           # ———— CPU
        $script:gpu = Get-CimInstance -CimSession $script:cimSession -ClassName CIM_VideoController                                                     # ———— GPU
        $script:disks = Get-CimInstance -CimSession $script:cimSession -ClassName CIM_LogicalDisk                                                       # ———— Disques
        $script:language = (Get-CimInstance -CimSession $script:cimSession -ClassName CIM_OperatingSystem | Select-Object -ExpandProperty MUILanguages) # ———— Langage
        $script:programInstalled = Get-CimInstance -CimSession $script:cimSession -ClassName CIM_Product                                                # ———— Programmes installés

        $script:hostname = Invoke-Command -Session $script:session -ScriptBlock { $env:COMPUTERNAME }                                                   # ———— Nom 
        $script:ipLocal = Invoke-Command -Session $script:session -ScriptBlock { Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null } }   # ———— Réseau
    }
    else {
        # ———— MACHINE LOCAL ————————————————
        $script:hostname = $env:COMPUTERNAME                                                                                # ———— Nom 
        $script:ipLocal = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null }                                # ———— Réseau
        $script:os = Get-CimInstance -ClassName CIM_OperatingSystem                                                         # ———— OS
        $script:cpu = Get-CimInstance -ClassName CIM_Processor                                                              # ———— CPU
        $script:gpu = Get-CimInstance -ClassName CIM_VideoController                                                        # ———— GPU
        $script:disks = Get-CimInstance -ClassName CIM_LogicalDisk                                                          # ———— Disques
        $script:language = (Get-CimInstance -ClassName CIM_OperatingSystem | Select-Object -ExpandProperty MUILanguages)    # ———— Langage
        $script:programInstalled = Get-CimInstance -ClassName CIM_Product                                                   # ———— Programmes installés

        $script:hostname = $env:COMPUTERNAME                                                                                # ———— Nom 
        $script:ipLocal = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null }                                # ———— Réseau
    }

    # ———— RAM 
    $script:totalRAM = [math]::Round($script:os.TotalVisibleMemorySize / 1MB, 2)
    $script:freeRAM  = [math]::Round($script:os.FreePhysicalMemory / 1MB, 2)
    $script:usedRAM  = [math]::Round($script:totalRAM - $script:freeRAM, 2)
    # ———— Date
    $script:date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# ———— ZONE DE TESTS ——————————————————————————————————————————————————————————————————————————————————————————————
#  ———— ADMIN ————————————————
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    throw [System.UnauthorizedAccessException] "Le script doit être exécuté avec les droits administrateur"
}

# ———— CORPS DU SCRIPT —————————————————————————————————————————————————————————————————————————————————————————————————————————————
if ($IPAddress) {
    $pingResult = Test-Connection -ComputerName $IPAddress.ToString() -Count 2 -Quiet   # ———— Envoie 2 pings à l'IP (retourne true/false)

    # ———— TRUE ————————————————
    if ($pingResult) {
        try {        
            # ———— Ouvre une session sur l'IP fournie en paramètre
            $cred = Get-Credential
            $script:session    = New-PSSession  -ComputerName $IPAddress.ToString() -Credential $cred -ErrorAction Stop
            $script:cimSession = New-CimSession -ComputerName $IPAddress.ToString() -Credential $cred -ErrorAction Stop

            Get-MachineInfo -IPAddress $IPAddress

            # ———— Fermeture de la session
            Remove-PSSession -Session $script:session
            Remove-CimSession -CimSession $script:cimSession
        }
        catch {    
            Write-Host "Erreur : impossible de se connecter à la machine distante" -ForegroundColor Red
            exit 1
        }
    }
    # ———— FALSE ————————————————
    else {
        Write-Host "Erreur : l'adresse IP $IPAddress ne répond pas aux pings" -ForegroundColor Red
        exit 1
    }
}
else {
    Get-MachineInfo
}

# ———— AFFICHAGE CONSOLE ————————————————
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════════════════════╗"
Write-Host "║                              SYSINFO LOGGER                                   ║"
Write-Host "╟═══════════════════════════════════════════════════════════════════════════════╣"
Write-Host "║                        Date : $script:date                             ║"     
Write-Host "╙━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╜"

# ———— INFORMATIONS SYSTEME
Write-Host "`n————— INFORMATIONS SYSTEME —————"
Write-Host (Line "Hostname" $script:hostname)                   # ———— Nom machine 

foreach ($i in $script:ipLocal) {
    Write-Host (Line "IP Address" $($i.IPv4Address.IPAddress))  # ———— IP
}

Write-Host ""
Write-Host (Line "OS Name" $script:os.Caption)                  # ———— Nom de l'OS
Write-Host (Line "OS Version" $script:os.Version)               # ———— Version de l'OS

# ———— HARDWARE 
Write-Host "`n————— HARDWARE —————"

foreach ($c in $script:cpu) {
    Write-Host (Line "CPU" $c.Name)                             # ———— CPU
}

foreach ($g in $script:gpu) {
    Write-Host (Line "GPU" $g.Name)                             # ———— GPU
}

Write-Host ""
Write-Host (Line "Total RAM" "$script:totalRAM GB")             # ———— Total (RAM)
Write-Host (Line "Used RAM"  "$script:usedRAM GB")              # ———— Utilisation (RAM)
Write-Host (Line "Free RAM"  "$script:freeRAM GB")              # ———— Espace libre (RAM)

# ———— INFORMATIONS SUPPLÉMENTAIRE ————————————————
Write-Host "`n————— INFORMATIONS SUPPLÉMENTAIRE —————"
Write-Host (Line "Langage" $script:language)                    # ———— Langage

# ———— PROGRAMMES ————————————————
Write-Host "`n————— PROGRAMMES INSTALLÉS —————"
$script:programInstalled | Select-Object Name, Version | Sort-Object Name | Format-Table -AutoSize  # ———— Programmes installés sous forme de liste (nom, version)

# ———— DISQUES ————————————————
Write-Host "————— DISQUES —————"
$script:disks | Select-Object DeviceID,
    @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}},
    @{Name='TotalGB';Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name='Free%';Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}} | Format-Table -AutoSize

# ———— AFFICHAGE LOGS ————————————————
Write-Log ""
Write-Log "╔═══════════════════════════════════════════════════════════════════════════════╗"
Write-Log "║                              SYSINFO LOGGER                                   ║"
Write-Log "╟═══════════════════════════════════════════════════════════════════════════════╣"
Write-Log "║                  Collecte faite le : $script:date                      ║"     
Write-Log "╙━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╜"

# ———— OPERATING SYSTEM ————————————————
Write-Log ""
Write-Log "┌ OPERATING SYSTEM"
Write-Log ("| " + (Line "Hostname" $script:hostname))           # ———— Nom machine 

foreach ($i in $script:ipLocal) {
    Write-Log ("| " + (Line "IP" $($i.IPv4Address.IPAddress)))  # ———— IP
}

Write-Log ("| " + (Line "OS" $script:os.Caption))               # ———— OS
Write-Log ("└ " + (Line "Version" $script:os.Version))          # ———— Version

# ———— HARDWARE ————————————————
Write-Log ""
Write-Log "┌ HARDWARE"

foreach ($c in $script:cpu) {
    Write-Log ("| " + (Line "CPU" $c.Name))                     # ———— CPU
}

$index = 0
foreach ($g in $script:gpu) {
    Write-Log ("| " + (Line "GPU $index" $g.Name))              # ———— GPU
    $index++
}

Write-Log ("└ " + (Line "RAM" "$script:usedRAM / $script:totalRAM GB"))     # ———— RAM

# ———— INFORMATIONS SUPPLÉMENTAIRE ————————————————
Write-Log ""
Write-Log "┌ INFORMATIONS SUPPLÉMENTAIRE"
Write-Log ("└ " + (Line "Langage" $script:language))                        # ———— Langage

# ———— PROGRAMMES INSTALLÉS ————————————————
Write-Log ""
Write-Log "┌ PROGRAMMES INSTALLÉS"

$apps = $script:programInstalled | Where-Object { $_.Name -and $_.Version } | Sort-Object Name, Version
$maxNameLength = ($apps.Name | Measure-Object -Maximum Length).Maximum
$index = 0
$count = $apps.Count

foreach ($app in $apps) {
    $index++
    $prefix = if ($index -eq $count) { "└" } else { "|" }
    $line = Line "App" "$($app.Name) | v$($app.Version)"
    Write-Log ("$prefix $line")                                             # ———— Programmes installés
}

# ———— DISQUES ————————————————
Write-Log ""
Write-Log "┌ DISQUES" 

foreach ($disk in $script:disks) {
    if ($disk.Size -gt 0) {
        $freeGB  = [math]::Round($disk.FreeSpace/1GB,2)
        $totalGB = [math]::Round($disk.Size/1GB,2)
        $percent = [math]::Round(($disk.FreeSpace/$disk.Size)*100,2)
        Write-Log ("| " + (Line "Disque $($disk.DeviceID)" "$freeGB / $totalGB GB ($percent`%)"))   # ———— Disque 
    }
}
Write-Log "└────────────────────────────────────────────"