{
  description = "My programs and configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      disko,
      systems,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      perSystem = callback: nixpkgs.lib.genAttrs (import systems) (system: callback (pkgs system));
      flakePath = config: "${config.home.homeDirectory}/code/github.com/jack-kelly/nix-config";
      pkgs =
        system:
        import nixpkgs {
          inherit system;
        };
      pkgs-stable =
        system:
        import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      diskoHosts = [
        "wungus"
        "wax-quail"
      ];
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./host/${hostname}/configuration.nix
            disko.nixosModules.disko
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
          ]
          ++ nixpkgs.lib.optional (builtins.elem hostname diskoHosts) ./host/${hostname}/disko.nix
          ++ [
            (
              { config, ... }:
              {
                home-manager = {
                  extraSpecialArgs = {
                    inherit flakePath inputs outputs;
                    pkgs-stable = pkgs-stable config.nixpkgs.hostPlatform.system;
                  };
                  useGlobalPkgs = true;
                  users.jack = import ./home/${hostname}.nix;
                  sharedModules = [ stylix.homeModules.stylix ];
                };
              }
            )
          ];
        };
      mkIso =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./host/${hostname}/configuration.nix
            ./host/${hostname}/disko.nix
            disko.nixosModules.disko
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            ./modules/nixos/iso.nix
            (
              { config, ... }:
              {
                home-manager = {
                  extraSpecialArgs = {
                    inherit flakePath inputs outputs;
                    pkgs-stable = pkgs-stable config.nixpkgs.hostPlatform.system;
                  };
                  useGlobalPkgs = true;
                  users.jack = import ./home/${hostname}.nix;
                  sharedModules = [ stylix.homeModules.stylix ];
                };
              }
            )
          ];
        };
    in
    {
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = perSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = nixpkgs.lib.genAttrs [
        "wungus"
        "wax-quail"
        "ues-safe-travels"
        "hopoo"
        "bungus"
      ] mkHost;

      # Reusable overlay so consumers get `pkgs.claude-code` everywhere.
      overlays.default = final: prev: {
        claude-code = final.callPackage ./pkgs/claude-code { };
      };

      packages =
        let
          # claude-code is unfree; allow it so `nix run`/`nix profile install`
          # work without the consumer setting NIXPKGS_ALLOW_UNFREE.
          pkgsFor =
            system:
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          claudePackages = nixpkgs.lib.genAttrs (import systems) (system: {
            claude-code = (pkgsFor system).callPackage ./pkgs/claude-code { };
          });
          isoHosts = [ "wungus" ];
          isoPackages = nixpkgs.lib.listToAttrs (
            map (h: {
              name = "iso-${h}";
              value = (mkIso h).config.system.build.isoImage;
            }) isoHosts
          );
        in
        claudePackages
        // {
          x86_64-linux = claudePackages.x86_64-linux // isoPackages;
        };
    };

}
