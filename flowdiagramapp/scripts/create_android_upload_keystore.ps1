Param(
  [string]$Alias = "upload",
  [string]$KeystoreFileName = "upload-keystore.jks"
)

$ErrorActionPreference = "Stop"

function Read-PlainTextPassword([string]$Prompt) {
  $secure = Read-Host -Prompt $Prompt -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try {
    return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  }
  finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) | Out-Null
  }
}

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$androidDir = Join-Path $root "android"
$appDir = Join-Path $androidDir "app"

if (!(Test-Path $androidDir)) {
  throw "No se encontró la carpeta 'android/'. Ejecuta este script desde el proyecto Flutter."
}

# Check keytool
if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
  throw "No se encontró 'keytool' en PATH. Instala/activa el JDK (Java) y vuelve a intentar."
}

$keystorePath = Join-Path $appDir $KeystoreFileName
$keyPropertiesPath = Join-Path $androidDir "key.properties"

Write-Host "Proyecto: $root"
Write-Host "Keystore (upload key): $keystorePath"
Write-Host "key.properties: $keyPropertiesPath"
Write-Host ""

if (Test-Path $keyPropertiesPath) {
  Write-Host "[INFO] Ya existe android/key.properties. Si quieres regenerar, bórralo manualmente." -ForegroundColor Yellow
}

if (Test-Path $keystorePath) {
  Write-Host "[INFO] Ya existe el keystore: $keystorePath" -ForegroundColor Yellow
} else {
  Write-Host "Creando keystore de subida (upload key)..."

  $storePass = Read-PlainTextPassword "Ingresa storePassword (se guardará en android/key.properties)"
  $keyPass = Read-PlainTextPassword "Ingresa keyPassword (si usas el mismo, repite el storePassword)"

  # Datos del certificado (puedes dejar defaults)
  $cn = Read-Host "CN (Common Name) [FlowCode]"; if ([string]::IsNullOrWhiteSpace($cn)) { $cn = "FlowCode" }
  $ou = Read-Host "OU (Org Unit) [Dev]"; if ([string]::IsNullOrWhiteSpace($ou)) { $ou = "Dev" }
  $o  = Read-Host "O (Organization) [ESCOM]"; if ([string]::IsNullOrWhiteSpace($o))  { $o  = "ESCOM" }
  $l  = Read-Host "L (City) [CDMX]"; if ([string]::IsNullOrWhiteSpace($l))  { $l  = "CDMX" }
  $s  = Read-Host "S (State) [CDMX]"; if ([string]::IsNullOrWhiteSpace($s))  { $s  = "CDMX" }
  $c  = Read-Host "C (Country) [MX]"; if ([string]::IsNullOrWhiteSpace($c))  { $c  = "MX" }

  $dname = "CN=$cn, OU=$ou, O=$o, L=$l, S=$s, C=$c"

  Push-Location $appDir
  try {
    keytool -genkeypair -v `
      -keystore $KeystoreFileName `
      -alias $Alias `
      -keyalg RSA `
      -keysize 2048 `
      -validity 10000 `
      -storepass $storePass `
      -keypass $keyPass `
      -dname $dname
  }
  finally {
    Pop-Location
  }

  Write-Host "Keystore creado." -ForegroundColor Green
}

# Create/update key.properties
if (!(Test-Path $keyPropertiesPath)) {
  $storePass2 = Read-PlainTextPassword "storePassword para escribir en key.properties"
  $keyPass2 = Read-PlainTextPassword "keyPassword para escribir en key.properties"

  @(
    "storeFile=$KeystoreFileName",
    "storePassword=$storePass2",
    "keyPassword=$keyPass2",
    "keyAlias=$Alias"
  ) | Set-Content -Encoding ASCII $keyPropertiesPath

  Write-Host "android/key.properties creado." -ForegroundColor Green
} else {
  Write-Host "[INFO] No se modificó android/key.properties porque ya existe." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Siguiente paso:" -ForegroundColor Cyan
Write-Host "  cd '$root'"
Write-Host "  flutter build appbundle --release"
Write-Host ""
Write-Host "Verificación (opcional):" -ForegroundColor Cyan
Write-Host "  jarsigner -verify -verbose -certs build\\app\\outputs\\bundle\\release\\app-release.aab | findstr /i \"CN=\""
