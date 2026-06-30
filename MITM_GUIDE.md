# OmniRoute AgentBridge MITM Guide for NixOS

To get the AgentBridge MITM server working on NixOS, you need to configure a few things declaratively in your NixOS configuration. This is because NixOS has an immutable `/etc/hosts` file and handles system-wide certificate trust differently than traditional Linux distributions.

## 1. Copy the Certificate

NixOS builds run in an isolated sandbox that cannot read from your `/home/` directory. You must copy the certificate to `/etc/nixos/` first:

```bash
sudo cp ~/.omniroute/mitm/server.crt /etc/nixos/omniroute-mitm.crt
```

## 2. Update `configuration.nix`

Add the following to your `/etc/nixos/configuration.nix` to trust the MITM certificate and redirect the required IDE API domains to localhost:

```nix
  # 1. Trust the OmniRoute MITM Certificate
  security.pki.certificateFiles = [
    /etc/nixos/omniroute-mitm.crt
  ];

  # 2. Redirect IDE Agent traffic to localhost (OmniRoute MITM)
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

## 2. Apply the Configuration

Run this command in your terminal to apply the new NixOS configuration:

```bash
sudo nixos-rebuild switch
```

## 3. Start OmniRoute

Because the MITM server needs to bind to **port 443** (the standard HTTPS port), it must be run with root privileges. 

In your terminal, stop any currently running `omniroute` background processes, and run it with `sudo`:

```bash
sudo omniroute
```

## 4. Enable MITM in the Web UI

1. Open the OmniRoute Web UI at `http://localhost:20128` (or your configured port).
2. Navigate to the **AgentBridge** tab on the left sidebar.
3. Click the **Start** button to launch the MITM server.

The MITM server will now successfully intercept and route the traffic for all supported IDE agents!
