param(
  [string]$OutDir = "test_reports"
)

$ErrorActionPreference = "Stop"

function Assert-CommandExists {
  param(
    [Parameter(Mandatory=$true)][string]$Name
  )

  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $cmd) {
    throw "Required command not found in PATH: $Name"
  }
}

Assert-CommandExists -Name "flutter"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptDir "..")

Push-Location $projectRoot
try {
  $outPath = Join-Path $projectRoot $OutDir
  if (-not (Test-Path $outPath)) {
    New-Item -ItemType Directory -Force -Path $outPath | Out-Null
  }

  $compilerExpandedTxt = Join-Path $outPath "flutter_test_compiler.txt"
  $compilerJsonl = Join-Path $outPath "flutter_test_compiler.jsonl"
  $compilerCountTxt = Join-Path $outPath "resumen_conteo_tests_compiler.txt"
  $phase4ExpandedTxt = Join-Path $outPath "flutter_test_phase4.txt"
  $phase4Jsonl = Join-Path $outPath "flutter_test_phase4.jsonl"
  $suiteBaseCountTxt = Join-Path $outPath "resumen_conteo_tests_suite_base.txt"
  $benchSummaryTxt = Join-Path $outPath "resumen_benchmark.txt"

  Write-Host "==> Running compiler tests (expanded)" -ForegroundColor Cyan
  flutter test test/compiler --reporter expanded 2>&1 | Tee-Object -FilePath $compilerExpandedTxt

  Write-Host "==> Running compiler tests (json)" -ForegroundColor Cyan
  flutter test test/compiler --reporter json 2>&1 | Out-File -Encoding utf8 $compilerJsonl

  $phase4TestFile = Join-Path $projectRoot "test/code_generator_phase4_test.dart"
  if (Test-Path $phase4TestFile) {
    Write-Host "==> Running Phase 4 tests (expanded)" -ForegroundColor Cyan
    flutter test test/code_generator_phase4_test.dart --reporter expanded 2>&1 | Tee-Object -FilePath $phase4ExpandedTxt

    Write-Host "==> Running Phase 4 tests (json)" -ForegroundColor Cyan
    flutter test test/code_generator_phase4_test.dart --reporter json 2>&1 | Out-File -Encoding utf8 $phase4Jsonl
  }

  $python = Get-Command python -ErrorAction SilentlyContinue
  if ($python) {
    Write-Host "==> Counting tests per file (from jsonl)" -ForegroundColor Cyan
    $pythonCountCode = @"
import sys, json, os
from collections import Counter

ROOT = os.path.normpath(os.getcwd())

def _rel(p):
    if not p:
        return p
    p2 = os.path.normpath(p)
    try:
        rel = os.path.relpath(p2, ROOT)
    except ValueError:
        rel = p2
        return rel.replace('\\', '/').replace('\\\\', '/')

def count_jsonl(path):
    suite_paths = {}
    counts = Counter()

    if not os.path.exists(path):
        return counts

    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        for raw in f:
            raw = raw.strip()
            if not raw:
                continue
            try:
                ev = json.loads(raw)
            except Exception:
                continue

            t = ev.get('type')
            if t == 'suite':
                s = ev.get('suite', {})
                suite_id = s.get('id')
                suite_paths[suite_id] = _rel(s.get('path'))
            elif t == 'testStart':
                test = ev.get('test', {})
                name = (test.get('name') or '').strip()
                if name.startswith('loading '):
                    continue

                suite_id = test.get('suiteID')
                if suite_id is None:
                    suite_id = test.get('suiteId')

                p2 = suite_paths.get(suite_id)
                if not p2:
                    p2 = '(unknown suite ' + str(suite_id) + ')'
                counts[p2] += 1

    return counts

all_files = sys.argv[1:]
final = Counter()
for p in all_files:
    final.update(count_jsonl(p))

print('TOTAL ' + str(sum(final.values())))
for p, n in sorted(final.items(), key=lambda kv: (-kv[1], kv[0] or '')):
    print(str(n).rjust(4) + '  ' + str(p))
"@
    $pythonCountCode | python - $compilerJsonl | Out-File -Encoding utf8 $compilerCountTxt

    if (Test-Path $phase4Jsonl) {
        $pythonCountCode | python - $compilerJsonl $phase4Jsonl | Out-File -Encoding utf8 $suiteBaseCountTxt
    }
  }

  Write-Host "==> Running benchmark test (filtered summary)" -ForegroundColor Cyan
  flutter test test/compiler/compiler_benchmark_test.dart --reporter expanded 2>&1 |
     Select-String -Pattern 'BENCH-|BENCH-DEBUG|Todas exitosas|Todos exitosos|\[ERROR\]|\[FATAL\]|\[3001\]|Expected:|Actual:|Some tests failed|All tests passed|Large diagrams should compile' |
    ForEach-Object { $_.Line } |
    Out-File -Encoding utf8 $benchSummaryTxt

} finally {
  Pop-Location
}
