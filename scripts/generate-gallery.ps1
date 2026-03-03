# =============================================================
#  generate-gallery.ps1  -  Iglesia Uncion con Gloria
# =============================================================
#  Uso desde la raiz del proyecto:
#    powershell -ExecutionPolicy Bypass -File scripts\generate-gallery.ps1
#
#  Que hace:
#    1. Escanea cada subcarpeta de assets/img/gallery/
#    2. Lista todas las imagenes (.jpg .jpeg .png .webp .gif)
#    3. Genera / sobreescribe assets/img/gallery/manifest.json
#
#  Para agregar fotos:
#    1. Copia la imagen a la carpeta de la categoria correcta
#    2. Ejecuta este script
#    3. Haz git push  -->  el sitio se actualiza automaticamente
# =============================================================

$ProjectRoot  = Split-Path $PSScriptRoot -Parent
$GalleryPath  = Join-Path $ProjectRoot "assets\img\gallery"
$ManifestPath = Join-Path $GalleryPath "manifest.json"

# ── Definicion de categorias ────────────────────────────────────────────────────
# Para crear una nueva categoria:
#   1. Crea la carpeta:  assets/img/gallery/<nuevo-id>/
#   2. Agrega una entrada aqui con el mismo nombre de carpeta como clave
# ─────────────────────────────────────────────────────────────────────────────────
$CategoryDefs = [ordered]@{
    "adoracion" = @{
        icon    = "fa-solid fa-hands-praying"
        bg      = "linear-gradient(135deg, #3a1b05 0%, #8B5728 60%, #C08040 100%)"
        titleEs = "Servicio de adoracion"
        titleEn = "Worship service"
    }
    "comunidad" = @{
        icon    = "fa-solid fa-people-group"
        bg      = "linear-gradient(135deg, #5C2D0A 0%, #8B5728 100%)"
        titleEs = "Comunidad"
        titleEn = "Community"
    }
    "templo" = @{
        icon    = "fa-solid fa-church"
        bg      = "linear-gradient(135deg, #8B5728 0%, #D4956A 100%)"
        titleEs = "Nuestro templo"
        titleEn = "Our sanctuary"
    }
    "jovenes" = @{
        icon    = "fa-solid fa-people-group"
        bg      = "linear-gradient(135deg, #C08040 0%, #5C2D0A 100%)"
        titleEs = "Ministerio de jovenes"
        titleEn = "Youth ministry"
    }
    "bautismos" = @{
        icon    = "fa-solid fa-droplet"
        bg      = "linear-gradient(135deg, #D4956A 0%, #8B5728 100%)"
        titleEs = "Bautismos"
        titleEn = "Baptisms"
    }
    "oracion" = @{
        icon    = "fa-solid fa-fire"
        bg      = "linear-gradient(135deg, #5C2D0A 0%, #C08040 100%)"
        titleEs = "Oracion e intercesion"
        titleEn = "Prayer & intercession"
    }
    "finca" = @{
        icon    = "fa-solid fa-tree"
        bg      = "linear-gradient(135deg, #8B5728 0%, #5C2D0A 100%)"
        titleEs = "Finca de la iglesia"
        titleEn = "Church grounds"
    }
    "ayunos" = @{
        icon    = "fa-solid fa-person-praying"
        bg      = "linear-gradient(135deg, #1A0802 0%, #4A1E0A 100%)"
        titleEs = "Ayunos congregacionales"
        titleEn = "Congregational fasts"
    }
}

$ImageExtensions = @(".jpg", ".jpeg", ".png", ".webp", ".gif")
$TotalImages     = 0
$Categories      = @()

Write-Host ""
Write-Host "=================================================" -ForegroundColor DarkYellow
Write-Host "  Generador de Galeria - Uncion con Gloria" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor DarkYellow
Write-Host ""

foreach ($CatId in $CategoryDefs.Keys) {
    $Def    = $CategoryDefs[$CatId]
    $CatDir = Join-Path $GalleryPath $CatId
    $Images = @()

    if (Test-Path $CatDir) {
        $Files = Get-ChildItem -Path $CatDir -File |
                 Where-Object { $ImageExtensions -contains $_.Extension.ToLower() } |
                 Sort-Object Name

        foreach ($File in $Files) {
            $Images += [ordered]@{
                src       = "assets/img/gallery/$CatId/$($File.Name)"
                captionEs = $Def.titleEs
                captionEn = $Def.titleEn
            }
        }
        $Count = $Files.Count
    } else {
        New-Item -ItemType Directory -Path $CatDir -Force | Out-Null
        $Count = 0
    }

    $TotalImages += $Count

    if ($Count -gt 0) {
        Write-Host ("  [OK] {0,-14} {1} imagen(es)" -f $CatId, $Count) -ForegroundColor Green
    } else {
        Write-Host ("  [  ] {0,-14} sin fotos aun" -f $CatId) -ForegroundColor DarkGray
    }

    $Categories += [ordered]@{
        id      = $CatId
        icon    = $Def.icon
        bg      = $Def.bg
        titleEs = $Def.titleEs
        titleEn = $Def.titleEn
        images  = $Images
    }
}

# ── Escribir manifest.json (UTF-8 sin BOM) ──────────────────────────────────────
$Manifest = [ordered]@{ categories = $Categories }
$Json = $Manifest | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText($ManifestPath, $Json, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "=================================================" -ForegroundColor DarkYellow
Write-Host "  manifest.json actualizado correctamente" -ForegroundColor Green
Write-Host ("  {0} categorias  |  {1} imagenes en total" -f $Categories.Count, $TotalImages) -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  Proximo paso: git add . && git push" -ForegroundColor Gray
Write-Host ""
