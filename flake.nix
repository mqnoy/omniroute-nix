{
  description = "Nix flake for OmniRoute CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          omniroute = pkgs.callPackage ./omniroute.nix {};
          default = self.packages.${system}.omniroute;
        };

        apps = {
          omniroute = flake-utils.lib.mkApp {
            drv = self.packages.${system}.omniroute;
          };
          default = self.apps.${system}.omniroute;
        };
      }
    ) // {
      # Module for easy NixOS / Home Manager consumption
      homeManagerModules.default = { pkgs, config, lib, ... }: {
        home.packages = [ self.packages.${pkgs.system}.default ];
      };
      
      nixosModules.default = { pkgs, config, lib, ... }: {
        environment.systemPackages = [ self.packages.${pkgs.system}.default ];
      };
    };
}
