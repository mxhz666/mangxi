$log = Join-Path $PSScriptRoot 'net-log.txt'
Remove-Item $log -ErrorAction SilentlyContinue
function Log($s) { Add-Content -Path $log -Value $s -Encoding UTF8 }

Log "=== ENV PROXY ==="
Log ("HTTP_PROXY=" + $env:HTTP_PROXY)
Log ("HTTPS_PROXY=" + $env:HTTPS_PROXY)
Log ("ALL_PROXY=" + $env:ALL_PROXY)
Log ""

Log "=== TEST 1: is local proxy 127.0.0.1:50892 listening? ==="
try {
  $c = New-Object System.Net.Sockets.TcpClient
  $ar = $c.BeginConnect('127.0.0.1', 50892, $null, $null)
  if ($ar.AsyncWaitHandle.WaitOne(4000)) { $c.EndConnect($ar); Log 'proxy50892 CONNECTED (proxy is alive)' } else { Log 'proxy50892 TIMEOUT (proxy not answering)' }
  $c.Close()
} catch { Log ('proxy50892 FAIL: ' + $_.Exception.Message) }
Log ""

Log "=== TEST 2: direct TCP to github.com:443 ==="
try {
  $c = New-Object System.Net.Sockets.TcpClient
  $ar = $c.BeginConnect('github.com', 443, $null, $null)
  if ($ar.AsyncWaitHandle.WaitOne(8000)) { $c.EndConnect($ar); Log 'direct github:443 CONNECTED' } else { Log 'direct github:443 TIMEOUT' }
  $c.Close()
} catch { Log ('direct github:443 FAIL: ' + $_.Exception.Message) }
Log ""

Log "=== TEST 3: git push WITH env proxy ==="
$git = "$env:USERPROFILE\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe"
if (-not (Test-Path $git)) { $git = "git" }
try { $r1 = (& $git push 2>&1 | Out-String); Log $r1 } catch { Log ('git push(with proxy) err: ' + $_.Exception.Message) }
Log ""

Log "=== TEST 4: git push WITHOUT proxy (direct) ==="
$env:HTTP_PROXY = ''; $env:HTTPS_PROXY = ''; $env:ALL_PROXY = ''
$env:http_proxy = ''; $env:https_proxy = ''; $env:all_proxy = ''
try { $r2 = (& $git push 2>&1 | Out-String); Log $r2 } catch { Log ('git push(direct) err: ' + $_.Exception.Message) }

Log "DONE"
