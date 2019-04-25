docker build -t secp256k1 .
If(test-path "bin")
{
    Remove-Item -Recurse -Force "bin"
}
New-Item -ItemType Directory -path "bin"
docker run -v "$(Get-Location)/bin:/data" secp256k1