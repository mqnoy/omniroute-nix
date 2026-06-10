# omniroute Nix Packaging

Nix packaging repository for [OmniRoute](https://github.com/diegosouzapw/OmniRoute) - Unified AI router with 160+ providers.

## Building

```bash
nix-build
```

## Updating

An update script is provided to automatically fetch the latest version from npm, generate the `package-lock.json`, compute the necessary hashes, and update `omniroute.nix`:

```bash
./update.sh
```

To update to a specific version:
```bash
./update.sh <version>
```

## Usage

You can build and use it via `nix-build`:
```bash
nix-build
./result/bin/omniroute
```
