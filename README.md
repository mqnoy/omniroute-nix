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

## AgentBridge MITM on NixOS

To use the AgentBridge MITM server on NixOS, you must configure certificate trust and DNS overrides declaratively in your `/etc/nixos/configuration.nix`. 

1. Copy the generated MITM certificate to your NixOS config directory (the builder cannot read from `/home/` during builds):
   ```bash
   sudo cp ~/.omniroute/mitm/server.crt /etc/nixos/omniroute-mitm.crt
   ```

2. Add the following to your `/etc/nixos/configuration.nix`:
   ```nix
     # Trust the OmniRoute MITM Certificate
     security.pki.certificateFiles = [
       /etc/nixos/omniroute-mitm.crt
     ];

     # Redirect IDE Agent traffic to localhost (OmniRoute MITM)
     networking.extraHosts = ''
       # Antigravity IDE
       127.0.0.1 daily-cloudcode-pa.googleapis.com
       127.0.0.1 cloudcode-pa.googleapis.com
       127.0.0.1 daily-cloudcode-pa.sandbox.googleapis.com
       127.0.0.1 autopush-cloudcode-pa.sandbox.googleapis.com
       
       # Kiro IDE & Claude Code
       127.0.0.1 api.anthropic.com
       
       # GitHub Copilot
       127.0.0.1 api.githubcopilot.com
       127.0.0.1 copilot-proxy.githubusercontent.com
       
       # Cursor IDE
       127.0.0.1 api2.cursor.sh
       
       # Zed
       127.0.0.1 api.zed.dev
       
       # OpenAI Codex / OpenCode
       127.0.0.1 chatgpt.com
       127.0.0.1 opencode.ai
     '';
   ```

3. Run `sudo nixos-rebuild switch`.
4. Run `omniroute` with `sudo` (since it needs to bind to port 443).
5. Open `http://localhost:20128`, navigate to **AgentBridge**, and click **Start**.
