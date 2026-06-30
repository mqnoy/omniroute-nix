{ lib, buildNpmPackage, fetchurl, nodejs, pkg-config, libsecret, python3 }:

let
  version = "3.8.41";

  omniroute = buildNpmPackage rec {
    pname = "omniroute";
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/omniroute/-/omniroute-${version}.tgz";
      hash = "sha256-x7fMJu6kSTkMEMwtERSirqTM88GlMQkaJbpLNXSE5F4="; 
    };

    npmDepsHash = "sha256-QKa7dENZUVDG2+hlNBMViVWnK7eqxQXGVCI1afVLd3k="; 
    
    inherit nodejs;
    makeCacheWritable = true;
    npmFlags = [ "--legacy-peer-deps" ];
    
    ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PUPPETEER_SKIP_DOWNLOAD = "1";

    nativeBuildInputs = [ pkg-config python3 ];
    buildInputs = [ libsecret ];

    postPatch = ''
      if [ -f "${./packages/omniroute/package-lock.json}" ]; then
        echo "Using vendored package-lock.json"
        cp "${./packages/omniroute/package-lock.json}" ./package-lock.json
      else
        echo "No vendored package-lock.json found, creating a minimal one"
        exit 1
      fi
    '';

    dontNpmBuild = true;
    dontNpmInstall = true;

    installPhase = ''
      mkdir -p $out/lib/node_modules/omniroute
      cp -a . $out/lib/node_modules/omniroute/
      
      mkdir -p $out/bin
      ln -s $out/lib/node_modules/omniroute/bin/omniroute.mjs $out/bin/omniroute
      ln -s $out/lib/node_modules/omniroute/bin/reset-password.mjs $out/bin/omniroute-reset-password
      chmod +x $out/bin/omniroute
      chmod +x $out/bin/omniroute-reset-password
    '';

    meta = with lib; {
      description = "Unified AI router with 160+ providers, RTK+Caveman compression, auto fallback, MCP/A2A, desktop, PWA, and OpenAI-compatible APIs.";
      homepage = "https://github.com/diegosouzapw/OmniRoute";
      mainProgram = "omniroute";
      license = licenses.mit;
    };
  };
in
omniroute
