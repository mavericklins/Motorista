# Vello minimal fixer — patcha só o necessário, SEM mexer no resto.
# Uso: Abra o PowerShell na RAIZ do projeto e rode:
#   powershell -ExecutionPolicy Bypass -File .\vello_fix_minimal.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Save-Backup($path) {
  if (Test-Path $path) {
    Copy-Item $path "$($path).bak" -Force
  }
}

function Read-File($path) {
  if (-not (Test-Path $path)) { return $null }
  return Get-Content $path -Raw -Encoding UTF8
}

function Write-File($path, $content) {
  $dir = Split-Path $path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
}

# 1) main.dart — imports + const nos builders + VelloColors alias
$mainPath = ".\lib\main.dart"
$main = Read-File $mainPath
if ($null -ne $main) {
  Save-Backup $mainPath

  # Ajusta imports quebrados (sem ../)
  $main = $main -replace "^\s*import\s+['\"].\./configuracoes/configuracoes_screen\.dart['\"]\s*;", "import 'package:vello_motorista/screens/configuracoes/configuracoes_screen.dart';"
  $main = $main -replace "^\s*import\s+['\"].\./configuracoes/metas_ganhos/metas_ganhos_screen\.dart['\"]\s*;", "import 'package:vello_motorista/screens/configuracoes/metas_ganhos/metas_ganhos_screen.dart';"
  $main = $main -replace "^\s*import\s+['\"].\./historico/historico_screen\.dart['\"]\s*;", "import 'package:vello_motorista/screens/historico/historico_screen.dart';"
  $main = $main -replace "^\s*import\s+['\"].\./perfil/perfil_screen\.dart['\"]\s*;", "import 'package:vello_motorista/screens/perfil/perfil_screen.dart';"

  # Remove const em builders das 4 telas
  $main = $main -replace "=>\s*const\s+MetasGanhosScreen\(", "=> MetasGanhosScreen("
  $main = $main -replace "=>\s*const\s+ConfiguracoesScreen\(", "=> ConfiguracoesScreen("
  $main = $main -replace "=>\s*const\s+HistoricoScreen\(", "=> HistoricoScreen("
  $main = $main -replace "=>\s*const\s+PerfilScreen\(", "=> PerfilScreen("

  # Desambigua VelloColors (alias no app_colors + prefixo no uso)
  $main = $main -replace "import\s+'package:vello_motorista/constants/app_colors\.dart';", "import 'package:vello_motorista/constants/app_colors.dart' as AppC;"
  # Só prefixa quando há conflito potencial: se também há outro import de colors.dart
  if ($main -match "constants/colors\.dart") {
    $main = $main -replace r"\bVelloColors\.", "AppC.VelloColors."
  }

  Write-File $mainPath $main
}

# 2) Stubs initialize() por extensão — sem mexer nas services
$extPath = ".\lib\services\_init_extensions.dart"
$ext = @"
import 'package:vello_motorista/services/eco_drive_service.dart';
import 'package:vello_motorista/services/rotas_inteligentes_service.dart';
import 'package:vello_motorista/services/fila_virtual_service.dart';
import 'package:vello_motorista/services/assistente_voz_service.dart';
import 'package:vello_motorista/services/emergencia_service.dart';

extension EcoDriveInit on EcoDriveService {
  Future<void> initialize() async {}
}
extension RotasInit on RotasInteligentesService {
  Future<void> initialize() async {}
}
extension FilaInit on FilaVirtualService {
  Future<void> initialize() async {}
}
extension VozInit on AssistenteVozService {
  Future<void> initialize() async {}
}
extension EmergenciaInit on EmergenciaService {
  Future<void> initialize() async {}
}
"@
Save-Backup $extPath
Write-File $extPath $ext

# 3) SoundService com método estático (não quebra se já existir — só cria se faltar)
$soundPath = ".\lib\services\sound_service.dart"
$sound = Read-File $soundPath
if ($null -eq $sound) {
  $sound = @"
class SoundService {
  static Future<void> playNavigationSound() async {
    // TODO: tocar som curto se desejar (audioplayers). Por ora, NO-OP.
  }
}
"@
  Write-File $soundPath $sound
} else {
  if ($sound -notmatch "static\s+Future<void>\s+playNavigationSound\(") {
    Save-Backup $soundPath
    if ($sound -match "class\s+SoundService\s*\{") {
      $sound = $sound -replace "class\s+SoundService\s*\{", "class SoundService {\n  static Future<void> playNavigationSound() async {}\n"
    } else {
      $sound += @"

class SoundService {
  static Future<void> playNavigationSound() async {}
}
"@
    }
    Write-File $soundPath $sound
  }
}

# 4) rotas_inteligentes — força retorno double
$rotasPath = ".\lib\services\rotas_inteligentes_service.dart"
$rotas = Read-File $rotasPath
if ($null -ne $rotas) {
  Save-Backup $rotasPath
  # várias variações com/sem parênteses e espaços
  $rotas = $rotas -replace "return\s+100\s*-\s*\(?\s*tempo\s*\/\s*60\s*\)?\s*-\s*\(?\s*distancia\s*\/\s*10000\s*\)?\s*;", "return 100.0 - (tempo / 60.0) - (distancia / 10000.0);"
  Write-File $rotasPath $rotas
}

# 5) emergencia_service — adiciona campo privado se não existir
$emerPath = ".\lib\services\emergencia_service.dart"
$emer = Read-File $emerPath
if ($null -ne $emer) {
  if ($emer -notmatch "_monitoramentoAtiva") {
    Save-Backup $emerPath
    # insere após a declaração da classe
    $emer = $emer -replace "(class\s+EmergenciaService\s*\{)", "`$1`n  bool _monitoramentoAtiva = false;"
    Write-File $emerPath $emer
  }
}

Write-Host "Patch aplicado. Agora rode:" -ForegroundColor Green
Write-Host "flutter clean"
Write-Host "flutter pub get"
Write-Host "flutter run -v"
