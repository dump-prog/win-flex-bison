Set-Location -Path "$PSScriptRoot"

Write-Host "Building enhanced p9 (win_bison + win_flex + gcc)"

win_bison -d .\enhanced.y
win_flex .\enhanced.l

gcc -o enhanced.exe enhanced.tab.c lex.yy.c

if ($LASTEXITCODE -eq 0) { Write-Host "Built enhanced.exe" } else { Write-Host "Build failed" }
