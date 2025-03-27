# DNS Exfiltration PoC (PowerShell)

Ovaj PoC demonstrira kako se fajl može tiho eksfiltrirati putem DNS upita korišćenjem čistog PowerShell koda. Namenjeno isključivo za edukativne i istraživačke svrhe.

## 🧩 Komponente

- **SlanjeFajlaPrekoDNS.ps1**  
  Eksfiltraciona skripta:
- Enkoduje fajl u Base64
- Deli sadržaj na DNS-validne chunkove (do 63 karaktera)
- Svaki chunk se šalje kao `Resolve-DnsName` upit ka tvom kontrolisanom domenu (npr. preko Interactsh)

- **RekonstrukcijaFajla.ps1**  
Dekoderska skripta:
- Parsira DNS log (kao što je `dns-logovi.txt`)
- Sortira chunkove po redosledu (`001.`, `002.`, itd.)
- Sastavlja Base64 string i dekoduje nazad originalni sadržaj

## 📦 Zahtevi

- PowerShell 5+
- Pristup `Resolve-DnsName`
- [Interactsh](https://github.com/projectdiscovery/interactsh) za prijem DNS zahteva

## ⚠️ Disclaimer

> Ovaj alat služi isključivo u edukativne svrhe. Autor ne snosi odgovornost za bilo kakvu zloupotrebu.

## ✅ Primer korišćenja

```powershell
# Slanje fajla:
.\SlanjeFajlaPrekoDNS.ps1

# Nakon što preuzmeš DNS log:
.\RekonstrukcijaFajla.ps1
```
