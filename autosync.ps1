param(
    [string]$Message = "Backup - autosync $(Get-Date -Format 'yyyy-MM-dd_HH:mm:ss')",
    [string]$RemoteUrl = "https://github.com/Jul-Zen/2p4s.git",
    [string]$Branch = "main"
)

Set-Location -Path $PSScriptRoot

# Prüfen, ob git verfügbar ist
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git ist nicht installiert oder nicht im PATH."
    exit 1
}

# Falls kein Repo, initialisieren und Remote setzen
if (-not (Test-Path -Path .git)) {
    Write-Output "Kein Git-Repository gefunden. Initialisiere Repo..."
    git init
    git branch -M $Branch
    git remote add origin $RemoteUrl
}
else {
    # falls kein origin, füge Remote hinzu
    $hasOrigin = (git remote get-url origin 2>$null) -ne $null
    if (-not $hasOrigin) {
        Write-Output "Remote 'origin' fehlt. Füge Remote $RemoteUrl hinzu"
        git remote add origin $RemoteUrl
    }
}

# Stage alle Änderungen
git add -A

# Prüfen, ob es etwas zu committen gibt
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Output "Keine Änderungen zum Committen."
    exit 0
}

# Commit und Push
git commit -m $Message
try {
    git push -u origin $Branch
    Write-Output "Push erfolgreich."
} catch {
    Write-Error "Push fehlgeschlagen: $_"
    exit 1
}
