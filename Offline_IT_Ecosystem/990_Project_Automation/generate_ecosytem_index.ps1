# File: generate_ecosystem_index.ps1
$root = "E:\NextGen\Offline_IT_Ecosystem"
$output = "E:\Codex\Docs\ECOSYSTEM_INDEX.md"

"# Offline IT Ecosystem - Full Index`n" > $output
"Generated: $(Get-Date)`n`n" >> $output

Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^\d{3}_' } | ForEach-Object {
    $manifest = "$($_.FullName)\DIRECTORY_MANIFEST.md"
    if (Test-Path $manifest) {
        $content = Get-Content $manifest -Raw
        $title = ($content -split "`n" | Select-Object -First 1) -replace '# ', ''
        "`n## [$($_.Name)]($($_.Name)/DIRECTORY_MANIFEST.md)`n" >> $output
        ($content -split "`n" | Where-Object { $_ -match '## Purpose' -or $_ -match '## Key Contents' }) >> $output
    }
}