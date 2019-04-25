# NBitcoin.Secp256k1

## Motivation of this project

This project is meant to create a portable .NET assembly exposing the features of [secp256k1](https://github.com/bitcoin-core/secp256k1/).
Because cross-compiling the library to lot's of different plateform is difficult, never comprehensibe, and time consuming, we are taking a different approach.

Instead, we build [secp256k1](https://github.com/bitcoin-core/secp256k1/) targetting web assembly (wasm), then use a wasm to IL converter tool to build a .NET assembly.

This assembly can then just be used in .NET projects on any runtime supporting .NET Core.

## Structure

[Dockerfile](Dockerfile) is pulling a pre-build version of [wasi-sdk](https://github.com/CraneStation/wasi-sdk), and attempt to build the binary from it.

## How to build

You need to have docker installed on your system, then you can run

In powershell
```powershell
.\build.ps1
```

In bash
```bash
./build.sh
```

The binaries will be found in the `bin` folder at the root of this repository.

## Troubleshooting

It is sometimes helpful to connect inside the container to browse what is going on inside it, so after you ran the build script, you can run:

```bash
docker run secp256k1
```

# Licence

MIT