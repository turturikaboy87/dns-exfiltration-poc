# Unos putanja
$InputFile = Read-Host "Unesite putanju do input fajla (npr. C:\\Users\\Ti\\Desktop\\dns-log.txt)"
$OutputFile = Read-Host "Unesite putanju za output fajl (npr. C:\\Users\\Ti\\Desktop\\recovered.txt)"

# Provera da fajl postoji
if (-Not (Test-Path -Path $InputFile -PathType Leaf)) {
    Write-Host "[GREŠKA] Fajl ne postoji: $InputFile"
    exit
}

# Parsiranje linija i vađenje prefiksa + base64 delova
$chunks = @()
Get-Content -Path $InputFile | ForEach-Object {
    if ($_ -match '^(\d{3})\.([a-zA-Z0-9+/=]+)\.') {
        $index = [int]$matches[1]
        $chunk = $matches[2] -replace '[^a-zA-Z0-9+/]', ''
        $chunks += [PSCustomObject]@{ Index = $index; Chunk = $chunk }
    }
}

if ($chunks.Count -eq 0) {
    Write-Host "[GREŠKA] Nisu pronađeni validni chunkovi u fajlu."
    exit
}

# Grupisanje po Index i biranje najdužgeg chunka za svaki redni broj
$selected = $chunks | Group-Object Index | ForEach-Object {
    $_.Group | Sort-Object Chunk.Length -Descending | Select-Object -First 1
}

# Sortirano po redosledu
$ordered = $selected | Sort-Object Index
$base64 = ($ordered.Chunk -join "")
Write-Host "[INFO] Rekonstruisan base64 string dužine $($base64.Length)"

# Popravka paddinga
switch ($base64.Length % 4) {
    2 { $base64 += "==" }
    3 { $base64 += "=" }
    1 { $base64 = $base64.Substring(0, $base64.Length - 1) }
}

# Dekodovanje
try {
    $bytes = [Convert]::FromBase64String($base64)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    Set-Content -Path $OutputFile -Value $text -Encoding UTF8
    Write-Host "[OK] Sadržaj uspešno rekonstruisan u: $OutputFile"
} catch {
    Write-Host "[GREŠKA] Dekodovanje nije uspelo. Base64 string je nevalidan."
}