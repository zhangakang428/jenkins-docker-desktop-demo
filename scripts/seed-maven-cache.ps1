param(
    [string]$SourceRepo = "F:\apache-maven-3.9.4\mvn_repo"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SourceRepo)) {
    throw "Maven repository not found: $SourceRepo"
}

docker volume create maven_repo | Out-Null

docker run --rm `
    -v "maven_repo:/target" `
    -v "${SourceRepo}:/source:ro" `
    alpine sh -c "cp -a /source/. /target/ && test ! -d /target/mvn_repo && ls -la /target | head"

Write-Host "Seeded Docker volume 'maven_repo' from $SourceRepo"
