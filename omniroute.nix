{ lib, buildNpmPackage, fetchurl, nodejs, pkg-config, libsecret, python3, buildFHSEnv }:

let
  version = "3.8.41";
  
  omniroute-base = buildNpmPackage rec {
    pname = "omniroute-base";
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
        cp "${./packages/omniroute/package-lock.json}" ./package-lock.json
      else
        exit 1
      fi

      if [ -f scripts/dev/tls-options.mjs ] && [ ! -f dist/tls-options.mjs ]; then
        cp scripts/dev/tls-options.mjs dist/tls-options.mjs
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
  };

in 
# Step 2: Wrap it in the FHS Environment
buildFHSEnv {
  name = "omniroute";
  
  # These packages will be available at standard Linux paths (e.g., /bin, /usr/bin)
  targetPkgs = pkgs: (with pkgs; [
    omniroute-base
    nodejs
    
    # Standard tools the setup script expects
    bash
    coreutils
    sudo
    
    # Cryptography tools for the MITM proxy
    openssl
    nss.tools 
  ]);
  
  runScript = "omniroute";
  
  meta = with lib; {
    description = "OmniRoute inside an FHS environment for MITM Proxy support.";
    homepage = "https://github.com/diegosouzapw/OmniRoute";
    mainProgram = "omniroute";
    license = licenses.mit;
  };
}