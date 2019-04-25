docker build -t secp256k1 .
If(test-path "bin")
{
    Remove-Item -Recurse -Force "bin"
    Start-Sleep -Seconds 1
}
New-Item -ItemType Directory -path "bin"
docker run -v "$(Get-Location)/bin:/build" secp256k1